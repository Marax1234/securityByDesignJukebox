#!/bin/bash
set -euo pipefail

echo "🚀 Starting Jukebox Deployment to Minikube..."

# -----------------------------
# Minikube starten
# -----------------------------
echo "📦 Starting Minikube..."
minikube start --cpus=2 --memory=4096

# -----------------------------
# Warten bis API-Server bereit ist
# -----------------------------
echo "⏳ Waiting for Kubernetes API server..."
until kubectl get nodes >/dev/null 2>&1; do
  sleep 2
done
echo "✅ API server ready"

# -----------------------------
# Minikube Addons aktivieren
# -----------------------------
echo "🔧 Enabling Minikube addons..."
minikube addons enable storage-provisioner || true
minikube addons enable default-storageclass || true

# -----------------------------
# Warten auf Default StorageClass
# -----------------------------
echo "⏳ Waiting for default StorageClass..."
until kubectl get storageclass | awk '$2=="(default)" {found=1} END {exit !found}'; do
  sleep 2
done
echo "✅ Default StorageClass ready"

# -----------------------------
# Docker-Umgebung setzen
# -----------------------------
echo "🐳 Setting Docker environment..."
eval "$(minikube docker-env)"

# -----------------------------
# Docker-Image bauen
# -----------------------------
echo "🔨 Building Docker image..."
docker build -t ghcr.io/jan-01/jukebox:latest .

# -----------------------------
# Image verifizieren
# -----------------------------
echo "🔍 Verifying image exists in Minikube..."
docker image inspect ghcr.io/jan-01/jukebox:latest >/dev/null
echo "✅ Image found!"

# -----------------------------
# Kubernetes-Ressourcen deployen
# -----------------------------
echo "☸️  Creating Kubernetes resources..."
kubectl apply -f infrastructure/k8s/namespace.yaml
kubectl apply -f infrastructure/k8s/postgres-secret.yaml
kubectl apply -f infrastructure/k8s/postgres-pvc.yaml
kubectl apply -f infrastructure/k8s/pvc.yaml
kubectl apply -f infrastructure/k8s/postgres-deployment.yaml
kubectl apply -f infrastructure/k8s/postgres-service.yaml

# -----------------------------
# Warten auf PostgreSQL
# -----------------------------
echo "⏳ Waiting for PostgreSQL to be ready..."
kubectl wait \
  --for=condition=ready \
  pod -l app=postgres \
  -n jukebox \
  --timeout=180s

# -----------------------------
# Jukebox deployen
# -----------------------------
echo "🎵 Deploying Jukebox app..."
kubectl apply -f infrastructure/k8s/deployment.yaml
kubectl apply -f infrastructure/k8s/service.yaml

# -----------------------------
# Warten auf Jukebox
# -----------------------------
echo "⏳ Waiting for Jukebox to be ready..."
kubectl wait \
  --for=condition=ready \
  pod -l app=jukebox \
  -n jukebox \
  --timeout=180s

# -----------------------------
# Deployment-Status ausgeben
# -----------------------------
echo "✅ Deployment complete!"
kubectl get all -n jukebox

echo ""
echo "🌐 Access your app:"
minikube service jukebox-service -n jukebox --url
