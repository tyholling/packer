#!/bin/bash

function build_nodes {
  pushd ../$1
  ./build.sh ${@:3}
  address=$2
  for hostname in ${@:3}; do
    sudo ./provision.sh $hostname $((address++))
  done
  for hostname in ${@:3}; do
    ssh $hostname bash -s < kubelet.sh &
  done
  wait
  popd
}

function control_plane {
  build_nodes $@
  control_plane_nodes+=(${@:3})

  for s in ${@:3}; do
    scp kubeadm/kube-vip.yaml $s:/etc/kubernetes/manifests
    ssh $s mkdir -p /opt/kubeadm/patches
    scp kubeadm/patches/* $s:/opt/kubeadm/patches/*
    ssh $s kubeadm config images pull &
  done
  wait

  for s in ${@:4}; do
    ssh $s sed -i s/super-admin/admin/g /etc/kubernetes/manifests/kube-vip.yaml
  done
}

function worker_nodes {
  build_nodes $@
  worker_nodes+=(${@:3})
}

control_plane centos 10 k0 k1 k2

worker_nodes debian 20 a0 a1 a2

# worker_nodes fedora 30 b0 b1 b2

# worker_nodes ubuntu 40 c0 c1 c2

ssh ${control_plane_nodes[0]} "
kubeadm init --patches /opt/kubeadm/patches \
--control-plane-endpoint 192.168.64.64 \
--pod-network-cidr 172.20.0.0/16 --service-cidr 172.24.0.0/16
"

mkdir -p ~/.kube/config
scp ${control_plane_nodes[0]}:/etc/kubernetes/admin.conf ~/.kube/config

secret=$(kubectl get secrets -n kube-system -o json | jq -r '
[ .items[]
| select(.type == "bootstrap.kubernetes.io/token")
| select(.data."usage-bootstrap-authentication" | @base64d == "true")]
| sort_by(.data.expiration | @base64d) | reverse | first | .metadata.name
')
echo "secret:  $secret"

token=$(kubectl get secret -n kube-system $secret -o json | jq -r '
( .data."token-id" | @base64d ) + "." + ( .data."token-secret" | @base64d )
')
echo "token:   $token"

hash=$(kubectl get configmap -n kube-public cluster-info -o json | jq -r '.data.kubeconfig' \
| grep certificate-authority-data | awk '{ print $2 }' | base64 -d \
| openssl x509 -pubkey | openssl rsa -pubin -outform der 2> /dev/null \
| sha256sum | awk '{ print $1 }')
echo "sha256:  $hash"

pubkey=$(ssh ${control_plane_nodes[0]} kubeadm init phase upload-certs --upload-certs | tail -n1)
echo "pubkey:  $pubkey"

for control_plane_node in ${control_plane_nodes[@]:1}; do
  ssh $control_plane_node "
  kubeadm join 192.168.64.64:6443 --control-plane --patches /opt/kubeadm/patches \
  --token $token --discovery-token-ca-cert-hash sha256:$hash --certificate-key $pubkey
  "
  kubectl wait --for create node $control_plane_node
done

for worker_node in ${worker_nodes[@]}; do
  ssh $worker_node "
  kubeadm join 192.168.64.64:6443 --token $token --discovery-token-ca-cert-hash sha256:$hash
  "
  kubectl wait --for create node $worker_node
done

kubectl get nodes -o wide
