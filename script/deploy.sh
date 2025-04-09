#!/bin/bash

set -e

RELEASE_NAME="memoly-api"
NAMESPACE="memoly"
IMAGE_NAME="memoly-api"
TAG="latest"

echo "🔧 Switching Docker CLI to Minikube..."
eval $(minikube docker-env)

echo "🐳 Rebuilding Docker image: $IMAGE_NAME:$TAG ..."
docker build -t $IMAGE_NAME:$TAG .

echo "🚀 Upgrading Helm release in '$NAMESPACE'..."
helm upgrade $RELEASE_NAME ./memoly-api-chart \
  --install \
  --namespace $NAMESPACE \
  --create-namespace \
  --wait

echo "⏳ Waiting for app rollout to complete..."
kubectl rollout status deployment/$RELEASE_NAME -n $NAMESPACE

echo "✅ Redeployment complete!"
kubectl get pods -n $NAMESPACE
kubectl get svc -n $NAMESPACE
