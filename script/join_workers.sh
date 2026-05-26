#!/bin/bash

cd $(dirname $0)

function build_node {
  pushd ../$1
  ./build.sh
  ./worker.sh
  sudo ./provision.sh $2 worker.img $3
  popd
}

function add_workers {
  local address=$2
  for node in ${@:3}; do
    build_node $1 $node "192.168.64.$((address++))"
    worker_nodes+=($node)
  done
}

add_workers debian 20 a0 a1 a2

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

for worker_node in ${worker_nodes[@]}; do
  ssh -l root $worker_node "
  kubeadm join 192.168.0.64:6443 --token $token --discovery-token-ca-cert-hash sha256:$hash
  "
  kubectl wait --for create node $worker_node
done

kubectl get nodes -o wide --sort-by .metadata.creationTimestamp
