#!/bin/bash
set -eux

# Set up ufw for master ports
ufw allow 6443              # kube-apiserver
ufw allow 2379:2380/tcp     # etcd api
ufw allow 10251             # kube-scheduler
ufw allow 10252             # kube-controller-manager
echo "y" | ufw reset

# Initialize Cluster
if [[ -n "$FEATURE_GATES" ]]
then
  kubeadm init --pod-network-cidr=10.244.0.0/16 \
      --ignore-preflight-errors=NumCPU --feature-gates "$FEATURE_GATES"
else
  kubeadm init  --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU
fi

systemctl restart kubelet
systemctl enable kubelet

# used to join nodes to the cluster
kubeadm token create --print-join-command > /tmp/kubeadm_join

mkdir -p "$HOME/.kube"
cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
