#!/usr/bin/env bash
# Clean script to remove old images and caches before building
# This prevents issues with outdated cached images in minikube

set -ex

echo "=== Cleaning Environment ==="

# Clean minikube images
echo "Cleaning minikube images..."
minikube image rm ottenwbe/recipes-manager-ui:development 2>/dev/null || true
minikube image rm ottenwbe/recipes-manager-recommender:development 2>/dev/null || true
minikube image rm ottenwbe/recipes-manager:development 2>/dev/null || true

# Clean local Docker/Podman images
echo "Cleaning local container images..."
podman rmi ottenwbe/recipes-manager-ui:development 2>/dev/null || true
podman rmi ottenwbe/recipes-manager-recommender:development 2>/dev/null || true
podman rmi ottenwbe/recipes-manager:development 2>/dev/null || true

# Clean UI dependencies
echo "Cleaning UI node_modules..."
cd "${0%/*}/../recipes-manager-ui" || exit 1
rm -rf node_modules

# Clean recommender Python cache
echo "Cleaning recommender Python cache..."
cd "${0%/*}/../recipes-manager-recommender" || exit 1
rm -rf __pycache__ analyzer/__pycache__

# Clean backend build artifacts
echo "Cleaning backend build artifacts..."
cd "${0%/*}/../recipes-manager" || exit 1
rm -rf recipes-manager

echo "=== Environment cleaned successfully ==="
