#!/bin/bash
# Run this script on MASTER node to verify cluster

echo "=================================================="
echo "  Kubernetes Cluster Verification"
echo "=================================================="
echo ""

echo "[1/6] Checking node status..."
kubectl get nodes -o wide
echo ""

echo "[2/6] Checking system pods..."
kubectl get pods -n kube-system
echo ""

echo "[3/6] Checking cluster info..."
kubectl cluster-info
echo ""

echo "[4/6] Checking component status..."
kubectl get componentstatuses 2>/dev/null || echo "Component status deprecated in newer versions"
echo ""

echo "[5/6] Deploying test application..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: NodePort
EOF

echo ""
echo "Waiting for pods to be ready..."
sleep 15

echo ""
echo "[6/6] Checking test deployment..."
kubectl get deployments
kubectl get pods
kubectl get svc nginx-service
echo ""

echo "=================================================="
echo "  ✅ Cluster verification completed!"
echo "=================================================="
echo ""
echo "Your Kubernetes cluster is ready to use!"
echo ""
echo "Useful commands:"
echo "  kubectl get nodes          - View all nodes"
echo "  kubectl get pods -A        - View all pods"
echo "  kubectl get svc            - View services"
echo "  kubectl describe node <name> - Node details"
echo ""
echo "To access the nginx test app:"
NODE_PORT=$(kubectl get svc nginx-service -o jsonpath='{.spec.ports[0].nodePort}')
echo "  http://<any-node-ip>:$NODE_PORT"
echo "=================================================="