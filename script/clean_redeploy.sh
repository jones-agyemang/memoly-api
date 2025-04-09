#!/bin/bash

set -e

RELEASE_NAME="memoly-api"
NAMESPACE="memoly"

echo "🚨 Deleting old Helm release (if exists)..."
helm uninstall $RELEASE_NAME --namespace $NAMESPACE || true

echo "🧹 Cleaning up conflicting resources in default namespace..."
kubectl delete secret $RELEASE_NAME --namespace default --ignore-not-found
kubectl delete secret $RELEASE_NAME --namespace $NAMESPACE --ignore-not-found

echo "🔁 Recreating namespace (if needed)..."
kubectl delete namespace $NAMESPACE --ignore-not-found
kubectl create namespace $NAMESPACE

echo "📦 Installing Helm release into namespace '$NAMESPACE'..."
helm upgrade $RELEASE_NAME ./memoly-api-chart \
  --install \
  --namespace $NAMESPACE \
  --create-namespace

echo "✅ Done! Resources deployed cleanly into namespace '$NAMESPACE'."