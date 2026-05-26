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
  host="192.168.64.$2"
  node=$3
  build_node $1 $node $host

  scp kubeadm/kube-vip.yaml root@$node:/etc/kubernetes/manifests
  scp kubeadm/registry.yaml root@$node:/etc/kubernetes/manifests

  ssh -l root $node mkdir -p /opt/kubeadm/patches
  scp kubeadm/patches/* root@$node:/opt/kubeadm/patches/
}

add_control centos 10 k0

ssh -l root $node "
kubeadm init --control-plane-endpoint 192.168.0.64 --apiserver-advertise-address $host \
--patches /opt/kubeadm/patches --pod-network-cidr 172.20.0.0/16 --service-cidr 172.24.0.0/16
"

mkdir -p ~/.kube
scp root@$node:/etc/kubernetes/admin.conf ~/.kube/config

kubectl patch -n kube-system ds/kube-proxy -p "$(jq -n '
.spec.template.spec.containers[0] |= (
.name = "kube-proxy" | .resources |= (
.limits = null | .requests = { cpu: "10m", memory: "10Mi" }
))')"

kubectl get nodes -o wide
