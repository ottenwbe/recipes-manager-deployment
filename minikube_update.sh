#!/usr/bin/env bash
# Build and load all Docker images into minikube with timestamped tags
# This ensures unique images and prevents caching issues

set -ex

# Generate timestamp for unique image tags
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
DEV_TAG="development-$TIMESTAMP"

echo "=== Building Images with Tag: $DEV_TAG ==="

# Clean environment first
echo "Cleaning environment..."
./minikube_clean.sh

# Build and load UI image
echo "Building and loading UI image..."
pushd .
cd ../recipes-manager-ui
./scripts/docker.sh build --type dev --tag "$DEV_TAG" --skip-validation
# Use podman save and pipe to minikube image load since we're using podman
podman save docker.io/ottenwbe/recipes-manager-ui:$DEV_TAG | minikube image load -
popd

# Build and load Recommender image
echo "Building and loading Recommender image..."
pushd .
cd ../recipes-manager-recommender/
# Pass timestamp tag to build script
TAG="$DEV_TAG" ./make_docker_for_minikube.sh
# Use podman save and pipe to minikube image load
podman save docker.io/ottenwbe/recipes-manager-recommender:$DEV_TAG | minikube image load -
popd

# Build and load Backend image
echo "Building and loading Backend image..."
pushd .
cd ../recipes-manager
# Pass timestamp tag to make
TAG="$DEV_TAG" make docker-dev
# Use podman save and pipe to minikube image load
podman save docker.io/ottenwbe/recipes-manager:$DEV_TAG | minikube image load -
popd

echo "=== All images built and loaded with tag: $DEV_TAG ==="
echo ""
echo "To deploy with Helm, use:"
echo "  helm upgrade test-recipes-manager charts/recipe-manager \\"
echo "    --namespace test-recipes-manager \\"
echo "    --set ui.image.tag=$DEV_TAG \\"
echo "    --set recipesManager.image.tag=$DEV_TAG \\"
echo "    --set recommender.image.tag=$DEV_TAG \\"
echo "    -f charts/recipe-manager/values-development.yaml"
