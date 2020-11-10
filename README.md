# k8s-distrib via Raspian

K8S distribution
to prepare each RPi:
This script will install containerd and kubeadmin, disable swap 
```
curl -sL https://raw.githubusercontent.com/obeyler/k8s-distrib/master/prepare.sh | sudo sh
```
L'usage  de Rapsberry pi au minimum en version 3 ou plus est nécessaire pour être sur de l'ARM64.

# Installation k8s-distrib sur base ubuntu server ARM64
installation de l'OS en utilisant le Raspberry Pi Imager sur les differentes cartes SD mon choix va se porter sur l'Ubuntu Server 20.04.1 LTS 64bit (RPi3/4)

- Raspberry Pi Imager as a deb package: https://downloads.raspberrypi.org/imager/imager_amd64.deb
- Raspberry Pi Imager for Windows: https://downloads.raspberrypi.org/imager/imager.exe
- Raspberry Pi Imager for macOS: https://downloads.raspberrypi.org/imager/imager.dmg

Pour se connecter le login/mot de passe par défaut va être ubuntu/ubuntu. Au premier démarage il est demander de le changer.

# Changer le hostname 
pour refleter le comportement nous allons changer le nom de chaque machine
changer le `/etc/hostname`

# Changer l'IP en ip fixe
rajout du fichier `/etc/netplan/00-installer-config.yaml`
avec ce contenu pour l'IP `192.168.0.101` par exemple
```
network:
  ethernets:
    eth0:
      dhcp4: false
      addresses:
      - 192.168.0.101/24
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
  version: 2
```
rajout du fichier `/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg`
avec ce contenu 
```
network: {config: disabled}
```
# Se faciliter la vie avec le ssh
```
ssh-copy-id ubuntu@192.168.0.100
```
# Ajout des cgroups
à la fin du fichier `/boot/firmware/cmdline.txt`
rajouter : `group_enable=cpuset cgroup_enable=memory cgroup_memory=1`

# Ajout de docker
```
sudo -i
apt-get update && sudo apt-get install -y apt-transport-https curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
apt-get update && sudo apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2
 sudo add-apt-repository \
  "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

apt-get upgrade
apt-get update && sudo apt-get install -y   containerd.io=1.2.13-2   docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)   docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl restart docker
```

# Permettre le routage du trafic par les IpTable 
```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

# Ajout de kubeadm, kubelet kubectl
```
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
# Usage de kubeadm
```
kubeadm init
```
# Ajout de la couche CNI 
Installation du reseau weavenet:
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
