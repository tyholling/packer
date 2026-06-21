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
    host="192.168.64.$((address++))"
    build_node $1 $node $host
    control_plane_nodes+=($node)
    control_plane_hosts+=($host)

    scp kubeadm/registry.yaml root@$node:/etc/kubernetes/manifests

    ssh -l root $node mkdir -p /opt/kubeadm/patches
    scp kubeadm/patches/* root@$node:/opt/kubeadm/patches/

    ssh -l root $node ip link set dev tun0 mtu 1500
  done
}

add_control centos 11 k1 k2

secret=$(kubectl get secrets -n kube-system -o json | jq -r '
[ .items[]
| select(.type == "bootstrap.kubernetes.io/token")
| select(.data."usage-bootstrap-authentication" | @base64d == "true")]
| sort_by(.data.expiration | @base64d) | last | .metadata.name
')
# echo "secret     : $secret"

token=$(kubectl get secret -n kube-system $secret -o json | jq -r '
.data | (."token-id" | @base64d) + "." + (."token-secret" | @base64d)
')
# echo "token      : $token"

hash=$(kubectl get configmap -n kube-public cluster-info -o json | jq -r '.data.kubeconfig' \
| grep certificate-authority-data | awk '{ print $2 }' | base64 -d \
| openssl x509 -pubkey | openssl rsa -pubin -outform der 2> /dev/null \
| sha256sum | awk '{ print $1 }')
# echo "hash       : $hash"

cluster_ip=$(ssh -l root cluster.lan /opt/yggdrasil/yggdrasilctl -json getself | jq -r .address)
# echo "ip address : $ip_address"

# ssh -l root cluster.lan kubeadm init phase upload-certs --upload-certs --config /opt/kubeadm/config.yaml

pubkey=$(ssh -l root $cluster_ip kubeadm init phase upload-certs --upload-certs --config /opt/kubeadm/config.yaml | tail -n1)
# echo "pubkey: $pubkey"

for node in ${control_plane_nodes[@]}; do
  ip_address="$(ssh -l root $node /opt/yggdrasil/yggdrasilctl -json getself | jq -r .address)"
  echo "ip address: $ip_address"

  # ssh -l root $node mkdir -p /opt/kubeadm
  # scp root@[$cluster_ip]:/opt/kubeadm/config.yaml root@$node:/opt/kubeadm/config.yaml

  ssh -l root $node "
  kubeadm join cluster.lan:6443 --control-plane \
  --apiserver-advertise-address $ip_address --patches /opt/kubeadm/patches \
  --certificate-key $pubkey --token $token --discovery-token-ca-cert-hash sha256:$hash
  "
  kubectl wait --for create node $node
done

kubectl get nodes -o wide --sort-by .metadata.creationTimestamp
