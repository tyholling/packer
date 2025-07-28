#!/bin/bash

for s in $@; do
  scp kubeadm/kube-vip.yaml $s:/etc/kubernetes/manifests
  ssh $s mkdir -p /opt/kubeadm/patches
  scp kubeadm/patches/* $s:/opt/kubeadm/patches/*
  ssh $s kubeadm config images pull
done

for s in ${@:2}; do
  ssh $s sed -i s/super-admin/admin/g /etc/kubernetes/manifests/kube-vip.yaml
done
