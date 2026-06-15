#!/bin/bash

cd $(dirname $0)

function build_node {
  pushd ../$1
  ./build.sh
  ./worker.sh
  ./provision.sh $2 worker.img $3
  popd
}

function add_control {
  local address=$2
  for node in ${@:3}; do
    host="192.168.0.$((address++))"
    build_node $1 $node $host
    control_plane_nodes+=($node)
    control_plane_hosts+=($host)

    scp kubeadm/kube-vip.yaml root@$node:/etc/kubernetes/manifests
    scp kubeadm/registry.yaml root@$node:/etc/kubernetes/manifests
    ssh -l root $node mkdir -p /opt/kubeadm/patches
    scp kubeadm/patches/* root@$node:/opt/kubeadm/patches/

    ssh -l root $node sed -i -e 's/super-admin/admin/' /etc/kubernetes/manifests/kube-vip.yaml
  done
}

add_control centos 11 k1 k2

secret=$(kubectl get secrets -n kube-system -o json | jq -r '
[ .items[]
| select(.type == "bootstrap.kubernetes.io/token")
| select(.data."usage-bootstrap-authentication" | @base64d == "true")]
| sort_by(.data.expiration | @base64d) | last | .metadata.name
')

token=$(kubectl get secret -n kube-system $secret -o json | jq -r '
.data | (."token-id" | @base64d) + "." + (."token-secret" | @base64d)
')

hash=$(kubectl get configmap -n kube-public cluster-info -o json | jq -r '.data.kubeconfig' \
| grep certificate-authority-data | awk '{ print $2 }' | base64 -d \
| openssl x509 -pubkey | openssl rsa -pubin -outform der 2> /dev/null \
| sha256sum | awk '{ print $1 }')

pubkey=$(ssh -l root 192.168.0.64 kubeadm init phase upload-certs --upload-certs | tail -n1)

for i in ${!control_plane_nodes[@]}; do
  ssh -l root ${control_plane_nodes[i]} "
  kubeadm join 192.168.0.64:6443 --control-plane \
  --apiserver-advertise-address ${control_plane_hosts[i]} --patches /opt/kubeadm/patches \
  --certificate-key $pubkey --token $token --discovery-token-ca-cert-hash sha256:$hash
  "
  kubectl wait --for create node ${control_plane_nodes[i]}
done

kubectl get nodes -o wide --sort-by .metadata.creationTimestamp
