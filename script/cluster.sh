#!/bin/bash

function build_node {
  pushd $1
  ./build.sh ${@:2}
  for hostname in ${@:2}; do
    sudo ./provision.sh $hostname
    ssh $hostname bash -s < kubelet.sh
  done
  popd
}

cd ..

# control plane
build_node centos k0 k1

# zone a workers
build_node debian a0 a1

# zone b workers
build_node fedora b0 b1

# zone c workers
build_node ubuntu c0 c1
