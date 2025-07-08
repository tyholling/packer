#!/bin/bash

function build_node {
  pushd $1
  # packer build -var output_directory=$2 $1.pkr.hcl
  packer build $1.pkr.hcl
  sudo ./provision.sh $2
  ssh $2 bash -s < kubelet.sh
  popd
}

cd ..

# control plane
build_node centos centos

# zone a workers
build_node debian debian

# zone b workers
build_node fedora fedora

# zone c workers
build_node ubuntu ubuntu
