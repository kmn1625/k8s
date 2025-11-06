#!/bin/bash
# Run this script on ALL nodes (Master + Worker1 + Worker2)

set -e

echo "=================================================="
echo "  Kubernetes Node Preparation Script"
echo "=================================================="

# Disable swap
echo "[1/8] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Load kernel modules
echo "[2/8] Loading kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set sysctl parameters
echo "[3/8] Configuring sysctl parameters..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Install dependencies
echo "[4/8] Installing dependencies..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Install containerd
echo "[5/8] Installing containerd..."
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Enable SystemdCgroup
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repository
echo "[6/8] Adding Kubernetes repository..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
echo "[7/8] Installing kubeadm, kubelet, and kubectl..."
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet
sudo systemctl enable kubelet

echo "[8/8] Verification..."
kubeadm version
kubelet --version
kubectl version --client

echo "=================================================="
echo "  ✅ Node preparation completed successfully!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "  - If this is the MASTER node, run: 02-init-master.sh"
echo "  - If this is a WORKER node, wait for master initialization"
echo "=================================================="
