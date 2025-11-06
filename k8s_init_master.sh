#!/bin/bash
# Run this script ONLY on the MASTER node

set -e

echo "=================================================="
echo "  Kubernetes Master Initialization"
echo "=================================================="

# Get the IP address of the master node
MASTER_IP=$(hostname -I | awk '{print $1}')
echo "Master Node IP: $MASTER_IP"
echo ""

# Initialize the cluster
echo "[1/4] Initializing Kubernetes cluster..."
sudo kubeadm init \
  --apiserver-advertise-address=$MASTER_IP \
  --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=NumCPU

# Setup kubeconfig for current user
echo "[2/4] Setting up kubeconfig..."
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel CNI
echo "[3/4] Installing Flannel CNI plugin..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Wait for cluster to be ready
echo "[4/4] Waiting for cluster to be ready..."
sleep 30

echo ""
echo "=================================================="
echo "  ✅ Master node initialized successfully!"
echo "=================================================="
echo ""
kubectl get nodes
echo ""

# Generate join command
echo "=================================================="
echo "  WORKER NODE JOIN COMMAND"
echo "=================================================="
echo ""
echo "Run this command on BOTH worker nodes:"
echo ""
sudo kubeadm token create --print-join-command
echo ""
echo "=================================================="
echo ""
echo "Save this command! You'll need it to join worker nodes."
echo "=================================================="