#!/bin/bash

# Day 60 Capstone Deployment Script
# Deploys WordPress + MySQL stack on Kubernetes

set -e  # Exit on error

NAMESPACE="capstone"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Day 60 Capstone: WordPress + MySQL"
echo "=========================================="
echo ""

# Step 1: Create namespace
echo "[1/5] Creating namespace..."
kubectl apply -f "$SCRIPT_DIR/01-namespace.yaml"
kubectl config set-context --current --namespace=$NAMESPACE
echo "✓ Namespace created"
echo ""

# Step 2: Create secrets
echo "[2/5] Creating MySQL secrets..."
kubectl apply -f "$SCRIPT_DIR/02-mysql-secret.yaml"
echo "✓ Secrets created"
echo ""

# Step 3: Deploy MySQL
echo "[3/5] Deploying MySQL (Headless Service + StatefulSet)..."
kubectl apply -f "$SCRIPT_DIR/03-mysql-headless-service.yaml"
kubectl apply -f "$SCRIPT_DIR/04-mysql-statefulset.yaml"

echo "⏳ Waiting for MySQL to be ready (this may take 30-60 seconds)..."
kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=300s 2>/dev/null || {
  echo "⚠️  MySQL pod is starting. Check with: kubectl logs mysql-0 -n $NAMESPACE"
  echo "⏳ Waiting a bit more..."
  sleep 30
}
echo "✓ MySQL is ready"
echo ""

# Step 4: Deploy WordPress
echo "[4/5] Deploying WordPress (ConfigMap + Deployment + Service + HPA)..."
kubectl apply -f "$SCRIPT_DIR/05-wordpress-configmap.yaml"
kubectl apply -f "$SCRIPT_DIR/06-wordpress-deployment.yaml"
kubectl apply -f "$SCRIPT_DIR/07-wordpress-service.yaml"
kubectl apply -f "$SCRIPT_DIR/08-wordpress-hpa.yaml"

echo "⏳ Waiting for WordPress pods to be ready (this may take 30-60 seconds)..."
kubectl wait --for=condition=ready pod -l app=wordpress -n $NAMESPACE --timeout=300s 2>/dev/null || {
  echo "⚠️  WordPress pods are starting. Check with: kubectl logs deployment/wordpress -n $NAMESPACE"
  echo "⏳ Waiting a bit more..."
  sleep 30
}
echo "✓ WordPress is ready"
echo ""

# Step 5: Summary
echo "[5/5] Deployment Summary"
echo "=========================================="
echo ""
echo "✓ All resources deployed successfully!"
echo ""
echo "Deployed resources:"
kubectl get all -n $NAMESPACE
echo ""
echo "=========================================="
echo "Next steps:"
echo "=========================================="
echo ""
echo "1. Wait for all pods to be Running (1/1):"
echo "   kubectl get pods -n $NAMESPACE --watch"
echo ""
echo "2. Access WordPress:"
echo "   • Minikube:   minikube service wordpress -n $NAMESPACE"
echo "   • Kind:       kubectl port-forward svc/wordpress 8080:80 -n $NAMESPACE"
echo "   • Direct:     http://<node-ip>:30080"
echo ""
echo "3. Complete WordPress setup wizard"
echo ""
echo "4. Test self-healing:"
echo "   kubectl delete pod <wordpress-pod> -n $NAMESPACE"
echo "   (Watch Deployment recreate it)"
echo ""
echo "5. Clean up when done:"
echo "   kubectl delete namespace $NAMESPACE"
echo "   kubectl config set-context --current --namespace=default"
echo ""
