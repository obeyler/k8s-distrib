#!/bin/sh
# This installs the base instructions up to the point of joining / creating a cluster

sudo dphys-swapfile swapoff && \
  sudo dphys-swapfile uninstall && \
  sudo update-rc.d dphys-swapfile remove
  
 
# Install containerd
## Set up the repository
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

### Addapt repository.
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

## Install containerd
apt-get update && apt-get install -qy containerd.io kubeadm

# Configure containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

echo Adding " cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt

orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt
sed -i -e 's/systemd_cgroup = false/systemd_cgroup = true/g' /etc/containerd/config.toml

# Restart containerd
systemctl restart containerd
