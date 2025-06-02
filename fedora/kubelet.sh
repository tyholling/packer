#!/bin/bash

# disable swap

swapoff -a
dnf remove -y zram-generator

# disable selinux

setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# disable firewall

systemctl disable --now firewalld

# configure dns

systemctl disable --now systemd-resolved
ln -fs /run/systemd/resolve/resolv.conf /etc/resolv.conf

# load kernel modules

cat << eof > /etc/modules-load.d/kubernetes.conf
br_netfilter
overlay
eof
systemctl restart systemd-modules-load

# configure kernel parameters

cat << eof > /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
eof
sysctl --system

# install cri-o

CRIO_VERSION=v1.32
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

KUBERNETES_VERSION=v1.32
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
