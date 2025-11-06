#!/bin/bash
# Run this script on WORKER nodes (Worker1 and Worker2)

set -e

echo "=================================================="
echo "  Join Worker Node to Kubernetes Cluster"
echo "=================================================="
echo ""
echo "⚠️  IMPORTANT: Replace the command below with the actual"
echo "   join command from your master node output!"
echo ""
echo "Example format:"
echo "sudo kubeadm join <MASTER-IP>:6443 --token <TOKEN> \\"
echo "    --discovery-token-ca-cert-hash sha256:<HASH>"
echo ""
echo "=================================================="
echo ""

# REPLACE THIS LINE with your actual join command from master
# Example:
# sudo kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
#     --discovery-token-ca-cert-hash sha256:1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef

echo "After running the join command, verify on master with:"
echo "  kubectl get nodes"
echo ""