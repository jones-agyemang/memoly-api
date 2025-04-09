#!/bin/bash

set -e

RELEASE_NAME="memoly-api"
NAMESPACE="memoly"
IMAGE_NAME="memoly-api"
TAG="latest"

echo "🔧 Switching Docker CLI to Minikube..."
eval $(minikube docker-env)

echo "🐳 Building Docker image: $IMAGE_NAME:$TAG ..."
docker build -t $IMAGE_NAME:$TAG .

echo "🧹 Uninstalling old Helm release (if exists)..."
helm uninstall $RELEASE_NAME --namespace $NAMESPACE || true

echo "🚮 Cleaning up secrets and namespace..."
kubectl delete secret $RELEASE_NAME --namespace default --ignore-not-found
kubectl delete secret $RELEASE_NAME --namespace $NAMESPACE --ignore-not-found
kubectl delete namespace $NAMESPACE --ignore-not-found
kubectl create namespace $NAMESPACE

echo "🚀 Installing Helm chart into '$NAMESPACE'..."
helm upgrade $RELEASE_NAME ./memoly-api-chart \
  --install \
  --namespace $NAMESPACE \
  --create-namespace

echo "⏳ Waiting for Rails app to be ready..."
kubectl rollout status deployment/$RELEASE_NAME -n $NAMESPACE

run_rails_job() {
  local job_name=$1
  local command=$2

  echo "🛠 Running Rails job: $job_name"
  kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: $job_name
  namespace: $NAMESPACE
spec:
  template:
    spec:
      containers:
      - name: $job_name
        image: $IMAGE_NAME:$TAG
        command: ["bundle", "exec", "rails", "$command"]
        envFrom:
        - secretRef:
            name: $RELEASE_NAME
      restartPolicy: Never
  backoffLimit: 1
EOF

  echo "⏳ Waiting for job '$job_name' to complete..."
  kubectl wait --for=condition=complete --timeout=120s job/$job_name -n $NAMESPACE || {
    echo "❌ Job '$job_name' failed. Logs:"
    kubectl logs job/$job_name -n $NAMESPACE
    exit 1
  }

  echo "🧽 Cleaning up job '$job_name'..."
  kubectl delete job $job_name -n $NAMESPACE
}

# Step 1: db:create
# run_rails_job "db-create" "db:create"

# Step 2: db:migrate
# run_rails_job "db-migrate" "db:migrate"

echo "✅ Deployment + DB setup complete!"
kubectl get pods -n $NAMESPACE
kubectl get svc -n $NAMESPACE