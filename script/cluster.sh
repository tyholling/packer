#!/bin/bash

function build_node {
  pushd $1
  ./build.sh ${@:3}
  address=$2
  for hostname in ${@:3}; do
    sudo ./provision.sh $hostname $((address++))
    ssh $hostname bash -s < kubelet.sh
  done
  popd
}

cd ..

# control plane
build_node centos 10 k0 k1 k2

# zone a
build_node debian 20 a0 a1 a2

# zone b
build_node fedora 30 b0 b1 b2

# zone c
build_node ubuntu 40 c0 c1 c2
