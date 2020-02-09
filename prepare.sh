#!/bin/sh

sudo dphys-swapfile swapoff && \
sudo dphys-swapfile uninstall && \
sudo update-rc.d dphys-swapfile remove


# This installs the base instructions up to the point of joining / creating a cluster
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update -q && \
  sudo apt-get install -qy kubeadm
  
 # add this line to /boot/cmdline.txt :
 # cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory

sudo curl https://download.docker.com/linux/raspbian/gpg | sudo apt-key add - && \
  echo "deb https://download.docker.com/linux/raspbian/ stretch stable" | sudo tee /etc/apt/sources.list.d/docker.list && \
  sudo apt-get update -q && \
  sudo apt-get install -qy docker

sudo systemctl start docker.service

sudo kubeadm config images pull 

sudo docker pull k8s.gcr.io/coredns:1.6.5
sudo docker pull docker.io/weaveworks/weave-npc:2.6.0

sudo kubeadm init
  
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
