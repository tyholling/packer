#!/bin/bash

cd $(dirname $0)

function build_node {
  pushd ../$1
  ./build.sh
  ./worker.sh
  ./provision.sh $2 worker.img $3
  popd
}

function add_workers {
  local address=$2
  for node in ${@:3}; do
    host="192.168.64.$((address++))"
    build_node $1 $node $host
    worker_nodes+=($node)
    worker_hosts+=($host)
  done
}

add_workers centos 20 a0 a1 a2

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

for i in ${!worker_nodes[@]}; do
  node=${worker_nodes[i]}
  host=${worker_hosts[i]}

ip_address="$(ssh -l root $node /opt/yggdrasil/yggdrasilctl -json getself | jq -r .address)"
cat << eof > /tmp/kubeadm-join-workers.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: JoinConfiguration
nodeRegistration:
  kubeletExtraArgs:
  - name: node-ip
    value: "$ip_address,$host"
discovery:
  bootstrapToken:
    token: "$token"
    apiServerEndpoint: "cluster.lan:6443"
    caCertHashes:
    - "sha256:$hash"
eof

  ssh -l root $node mkdir -p /opt/kubeadm
  scp /tmp/kubeadm-join-workers.yaml root@$node:/opt/kubeadm/join-config.yaml

  ssh -l root $node nmcli con mod lo +ipv6.routes "'fd64:20::/108 ::'"

  ssh -l root $node kubeadm join --config /opt/kubeadm/join-config.yaml
  kubectl wait --for create node $node
done

kubectl get nodes -o wide --sort-by .metadata.creationTimestamp
