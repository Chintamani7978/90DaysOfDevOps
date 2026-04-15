#!/bin/bash

# Day 60 Capstone Cleanup Script
# Removes all WordPress + MySQL resources from Kubernetes

set -e

NAMESPACE="capstone"

echo "=========================================="
echo "Day 60 Capstone Cleanup"
echo "=========================================="
echo ""

# Confirm deletion
read -p "⚠️  This will delete the '$NAMESPACE' namespace and all resources in it. Continue? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Cleanup cancelled."
  exit 1
fi

echo "Deleting namespace '$NAMESPACE'..."
kubectl delete namespace $NAMESPACE --ignore-not-found=true

echo "✓ Cleanup complete"
echo ""
echo "Resetting default namespace..."
kubectl config set-context --current --namespace=default
echo "✓ Default namespace set"
echo ""

echo "Verification:"
kubectl get namespaces | grep capstone || echo "✓ 'capstone' namespace successfully removed"
echo ""
echo "All resources have been deleted."
