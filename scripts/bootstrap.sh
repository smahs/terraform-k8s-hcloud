#!/bin/bash
set -eux

# Utils
waitforapt(){
  while fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ; do
     echo "Waiting for other software managers to finish..." 
     sleep 1
  done
}

# Turn swap off; which should be off, but still...
swapoff -a

# Setup ufw and open common ports for both node types
waitforapt && apt -qq update && apt -qq install ufw
sed -i "s/^\([[:blank:]]*\)IPV6=.*$/\1IPV6=yes/" /etc/default/ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 10250         # kubelet
ufw allow 8285/udp      # flannel
ufw allow 8472/udp      # flannel
ufw allow 4443          # metrics-server
echo "y" | ufw enable

#######################################################

# containerd setup following:
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/

cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

waitforapt && apt -qq install -y containerd

# Configure containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

# Use systemd-cgroup driver
sed -i "s/^\([[:blank:]]*\)systemd_cgroup.*$/\1systemd_cgroup = true/" /etc/containerd/config.toml

# Restart containerd
systemctl restart containerd
systemctl enable containerd

#######################################################

# Install kubeadm and kubelet following:
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm

waitforapt && apt -qq install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
waitforapt && apt -qq update && apt -qq install -y kubelet kubeadm

cat > /etc/default/kubelet <<EOF
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd
EOF

systemctl daemon-reload
systemctl restart kubelet
