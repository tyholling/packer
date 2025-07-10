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

# zone a
build_node centos a0 a1

# zone b
build_node debian b0 b1

# zone c
build_node fedora c0 c1

# zone d
build_node ubuntu d0 d1
