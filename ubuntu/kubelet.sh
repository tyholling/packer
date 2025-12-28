#!/bin/bash

# load kernel modules

cat << eof > /etc/modules-load.d/kubernetes.conf
br_netfilter
overlay
eof
modprobe br_netfilter overlay

# set kernel parameters

cat << eof > /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
eof
sysctl --system

# install cri-o

apt-get install -y software-properties-common curl

CRIO_VERSION=v1.35
curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
cat << eof > /etc/apt/sources.list.d/cri-o.list
deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] \
https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /
eof

apt-get update
apt-get install -y cri-o
systemctl enable --now crio

# install kubernetes

KUBERNETES_VERSION=v1.35
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
cat << eof > /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /
eof

apt-get update
apt-get install -y kubeadm kubelet kubectl kubernetes-cni
systemctl enable kubelet
