#!/usr/bin/env bash
# Deployment script that uses the latest built images with timestamped tags
# This script should be run after minikube_update.sh

set -e

echo "=== Finding Latest Timestamped Images ==="

# Function to find all timestamped tags
get_timestamped_tags() {
    minikube image ls | grep -E "ottenwbe.*:development-[0-9]{8}-[0-9]{6}" | while read -r line; do
        echo "$line" | cut -d: -f2
    done | sort -r
}

# Get all timestamped tags and find the latest
TAG_ONLY=$(get_timestamped_tags | head -1)

if [ -z "$TAG_ONLY" ]; then
    echo "Error: No timestamped images found in minikube."
    echo ""
    echo "Available ottenwbe images:"
    minikube image ls | grep ottenwbe || echo "  (none)"
    echo ""
    echo "Please run minikube_update.sh first to build and load images."
    exit 1
fi

echo "Found timestamped tag: $TAG_ONLY"

# Verify all three required images exist with this tag
echo "Verifying all service images exist..."
MISSING_IMAGES=0
for service in "recipes-manager-ui" "recipes-manager" "recipes-manager-recommender"; do
    if minikube image ls | grep -q "ottenwbe/$service:$TAG_ONLY"; then
        echo "  ✓ ottenwbe/$service:$TAG_ONLY"
    else
        echo "  ✗ ottenwbe/$service:$TAG_ONLY (MISSING)"
        MISSING_IMAGES=$((MISSING_IMAGES + 1))
    fi
done

if [ $MISSING_IMAGES -gt 0 ]; then
    echo ""
    echo "Error: $MISSING_IMAGES required images are missing."
    echo "Please run minikube_update.sh to build and load all images."
    exit 1
fi

echo ""
echo "=== Deploying with Helm ==="
echo "Using tag: $TAG_ONLY"

# Deploy with Helm using the timestamped tag
helm upgrade test-recipes-manager charts/recipe-manager \
    --namespace test-recipes-manager \
    --create-namespace \
    --install \
    --set ui.image.tag="$TAG_ONLY" \
    --set recipesManager.image.tag="$TAG_ONLY" \
    --set recommender.image.tag="$TAG_ONLY" \
    -f charts/recipe-manager/values-development.yaml

echo ""
echo "=== Deployment complete ==="
echo ""
echo "To access the services:"
echo "  UI:       minikube service -n test-recipes-manager ui-service"
echo "  Backend:  minikube service -n test-recipes-manager recipes-manager-service"
echo "  Recommender: minikube service -n test-recipes-manager recommendations-service"
echo ""
echo "Or use port-forwarding:"
echo "  kubectl port-forward -n test-recipes-manager svc/ui-service 3000:80"
echo "  kubectl port-forward -n test-recipes-manager svc/recipes-manager-service 8080:8080"
echo "  kubectl port-forward -n test-recipes-manager svc/recommendations-service 5001:5000"
