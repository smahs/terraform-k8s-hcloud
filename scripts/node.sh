#!/bin/bash
set -eux

# Set up ufw for worker ports
ufw allow 30000:32767/tcp     # nodeport services
echo "y" | ufw reset

eval "$(cat /tmp/kubeadm_join)"
systemctl restart kubelet
systemctl enable kubelet
