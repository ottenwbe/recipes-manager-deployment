#!/bin/bash
# ingress_test.sh - Simple script to access Ingress in minikube with podman driver

echo "=========================================="
echo "  Ingress Access for Minikube (Podman)  "
echo "=========================================="
echo ""

NAMESPACE="test-recipes-manager"

# Check if deployment exists
if ! kubectl get ingress -n $NAMESPACE &>/dev/null; then
    echo "❌ ERROR: No Ingress found in namespace '$NAMESPACE'"
    echo "   Please run ./minikube_deploy.sh first"
    exit 1
fi

echo "✅ Ingress found in namespace: $NAMESPACE"
echo ""

# Get minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"
echo ""

# Get ingress controller NodePort
NODEPORT=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)

if [ -z "$NODEPORT" ]; then
    echo "❌ ERROR: Could not find ingress controller NodePort"
    exit 1
fi

echo "Ingress Controller NodePort: $NODEPORT"
echo ""

echo "=========================================="
echo "  ACCESS YOUR SERVICES  "
echo "=========================================="
echo ""
echo "Since you're using the podman driver, use these commands:"
echo ""
echo "1. Start a tunnel (in a separate terminal):"
echo "   minikube tunnel"
echo ""
echo "2. In another terminal, add this to /etc/hosts:"
echo "   echo \"$MINIKUBE_IP chart-example.local\" | sudo tee -a /etc/hosts"
echo ""
echo "3. Then access your services at:"
echo "   - UI:       http://chart-example.local/"
echo "   - API:      http://chart-example.local/api/v1/recipes"
echo "   - Recommender: http://chart-example.local/api/v1/recommendation/health"
echo "   - Swagger:  http://chart-example.local/swagger"
echo ""
echo "=========================================="
echo "  OR (Quick Method)  "
echo "=========================================="
echo ""
echo "Use minikube service for each service:"
echo "  minikube service -n $NAMESPACE ui-service"
echo "  minikube service -n $NAMESPACE recipes-manager-service"
echo "  minikube service -n $NAMESPACE recommendations-service"
echo ""
echo "This will open each service in your browser."
echo ""
