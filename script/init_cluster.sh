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
  host="192.168.64.$2"
  node=$3
  build_node $1 $node $host

  scp kubeadm/registry.yaml root@$node:/etc/kubernetes/manifests

  ssh -l root $node mkdir -p /opt/kubeadm
}

add_control centos 10 k0

ssh -l root $node nmcli con mod lo +ipv6.routes "'fd64:20::/108 ::'"

ip_address="$(ssh -l root $node /opt/yggdrasil/yggdrasilctl -json getself | jq -r .address)"

echo "$ip_address cluster.lan" >> /opt/homebrew/etc/dnsmasq.hosts
sudo brew services restart dnsmasq

cat << eof > /tmp/kubeadm-init-config.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
controlPlaneEndpoint: "cluster.lan:6443"
networking:
  podSubnet: "fd64:10::/48,172.20.0.0/16"
  serviceSubnet: "fd64:20::/108,172.24.0.0/16"
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "$ip_address"
nodeRegistration:
  kubeletExtraArgs:
  - name: node-ip
    value: "$ip_address,$host"
eof
scp /tmp/kubeadm-init-config.yaml root@$node:/opt/kubeadm/init-config.yaml

ssh -l root $node kubeadm init --config /opt/kubeadm/init-config.yaml

mkdir -p ~/.kube
scp root@$node:/etc/kubernetes/admin.conf ~/.kube/config

kubectl patch -n kube-system ds/kube-proxy -p "$(jq -n '
.spec.template.spec.containers[0] |= (
.name = "kube-proxy" | .resources |= (
.limits = null | .requests = { cpu: "10m", memory: "10Mi" }
))')"

kubectl get nodes -o wide
