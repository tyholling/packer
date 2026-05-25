#!/bin/bash

cd $(dirname $0)

function build_node {
  pushd ../$1
  ./build.sh
  ./worker.sh
  sudo ./provision.sh $2 worker.img $3
  popd
}

function add_control {
  local address=$2
  for node in ${@:3}; do
    host="192.168.64.$((address++))"
    build_node $1 $node $host
    control_plane_nodes+=($node)
    control_plane_hosts+=($host)

    scp kubeadm/kube-vip.yaml root@$node:/etc/kubernetes/manifests
    scp kubeadm/registry.yaml root@$node:/etc/kubernetes/manifests
    ssh -l root $node mkdir -p /opt/kubeadm/patches
    scp kubeadm/patches/* root@$node:/opt/kubeadm/patches/
  done

  for node in ${@:4}; do
    ssh -l root $node sed -i -e 's/super-admin/admin/' /etc/kubernetes/manifests/kube-vip.yaml
  done
}

function add_workers {
  local address=$2
  for node in ${@:3}; do
    build_node $1 $node "192.168.64.$((address++))"
    worker_nodes+=($node)
  done
}

add_control centos 10 k0 k1 k2
add_workers debian 20 a0 a1 a2
# add_workers fedora 30 b0 b1 b2
# add_workers ubuntu 40 c0 c1 c2

ssh -l root ${control_plane_nodes[0]} "
kubeadm init --control-plane-endpoint 192.168.64.64 \
--apiserver-advertise-address ${control_plane_hosts[0]} --patches /opt/kubeadm/patches \
--pod-network-cidr 172.20.0.0/16 --service-cidr 172.24.0.0/16
"

mkdir -p ~/.kube
scp root@${control_plane_nodes[0]}:/etc/kubernetes/admin.conf ~/.kube/config

kubectl patch -n kube-system ds/kube-proxy -p "$(jq -n '
.spec.template.spec.containers[0] |= (
.name = "kube-proxy" | .resources |= (
.limits = null | .requests = { cpu: "10m", memory: "10Mi" }
))')"

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

pubkey=$(ssh -l root ${control_plane_nodes[0]} kubeadm init phase upload-certs --upload-certs | tail -n1)

for i in ${!control_plane_nodes[@]}; do
  [[ $i -eq 0 ]] && continue
  ssh -l root ${control_plane_nodes[i]} "
  kubeadm join 192.168.64.64:6443 --control-plane \
  --apiserver-advertise-address ${control_plane_hosts[i]} --patches /opt/kubeadm/patches \
  --certificate-key $pubkey --token $token --discovery-token-ca-cert-hash sha256:$hash
  "
  kubectl wait --for create node ${control_plane_nodes[i]}
done

for worker_node in ${worker_nodes[@]}; do
  ssh -l root $worker_node "
  kubeadm join 192.168.64.64:6443 --token $token --discovery-token-ca-cert-hash sha256:$hash
  "
  kubectl wait --for create node $worker_node
done

kubectl get nodes -o wide --sort-by .metadata.creationTimestamp
