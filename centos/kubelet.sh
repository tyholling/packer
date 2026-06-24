#!/bin/bash

# load kernel modules

cat << eof > /etc/modules-load.d/kubernetes.conf
br_netfilter
overlay
eof
modprobe br_netfilter overlay

# set kernel parameters

cat << eof > /etc/sysctl.d/kubernetes.conf
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
eof
sysctl --system

# install yggdrasil

dnf install -y golang tar

curl -Ls -o /tmp/yggdrasil.tar.gz \
https://github.com/yggdrasil-network/yggdrasil-go/releases/download/v0.5.13/yggdrasil-0.5.13-vendored.tar.gz
mkdir -p /opt/yggdrasil
tar xf /tmp/yggdrasil.tar.gz -C /opt/yggdrasil

pushd /opt/yggdrasil
./build
popd

cat << eof > /etc/systemd/system/yggdrasil.service
[Service]
ExecStart=/opt/yggdrasil/yggdrasil -useconf /etc/yggdrasil.conf

[Install]
WantedBy=multi-user.target
eof
systemctl enable yggdrasil

# install cri-o

CRIO_VERSION=v1.36
cat << eof > /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/rpm/repodata/repomd.xml.key
eof

dnf install -y cri-o
systemctl enable --now crio

# install kubernetes

KUBERNETES_VERSION=v1.36
cat << eof > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/repodata/repomd.xml.key
eof

dnf install -y kubeadm kubelet kubectl kubernetes-cni
systemctl enable kubelet
kubeadm config images pull
