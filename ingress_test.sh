#!/bin/bash
# ingress_test.sh - Access your deployment via Ingress in minikube
# For podman driver, we need to use minikube tunnel + /etc/hosts

echo "=== Ingress Access for Minikube (Podman Driver) ==="
echo ""

NAMESPACE="test-recipes-manager"
HOST="chart-example.local"

# Check if deployment exists
if ! kubectl get ingress -n $NAMESPACE &>/dev/null; then
    echo "❌ Error: No Ingress found in namespace '$NAMESPACE'"
    echo "   Please run ./minikube_deploy.sh first"
    exit 1
fi

echo "✅ Found Ingress in namespace: $NAMESPACE"
echo ""

# Get minikube IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"
echo ""

# Check if host is in /etc/hosts
if ! grep -q "$HOST" /etc/hosts; then
    echo "Adding $HOST to /etc/hosts..."
    echo "$MINIKUBE_IP $HOST" | sudo tee -a /etc/hosts > /dev/null
    echo "✅ Added: $MINIKUBE_IP $HOST"
else
    echo "✅ Host $HOST already configured in /etc/hosts"
fi

echo ""
echo "=== Starting minikube tunnel (requires sudo) ==="
echo "You'll need to enter your sudo password..."
echo ""

# Start tunnel with sudo
sudo minikube tunnel > /tmp/minikube-tunnel.log 2>&1 &
TUNNEL_PID=$!
sleep 8

echo "✅ Tunnel started (PID: $TUNNEL_PID)"
echo ""

# Test connectivity
echo "=== Testing Services ==="
echo ""

SERVICES=(
    "UI:http://$HOST/"
    "Backend API:http://$HOST/api/v1/recipes"
    "Recommender:http://$HOST/api/v1/recommendation/health"
    "Swagger:http://$HOST/swagger"
)

for service in "${SERVICES[@]}"; do
    IFS=':' read -r name url <<< "$service"
    echo -n "Testing $name... "
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "$url" 2>/dev/null || echo "timeout")
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "201" ]; then
        echo "✅ (HTTP $STATUS)"
    else
        echo "❌ (HTTP $STATUS)"
    fi
done

echo ""
echo "=== Access URLs ==="
echo ""
echo "You can now access:"
echo "  - UI:       http://$HOST/"
echo "  - API:      http://$HOST/api/v1/recipes"
echo "  - Recommender: http://$HOST/api/v1/recommendation/health"
echo "  - Swagger:  http://$HOST/swagger"
echo ""
echo "=== Tunnel Info ==="
echo "Tunnel is running in background (PID: $TUNNEL_PID)"
echo "To stop the tunnel: sudo kill $TUNNEL_PID"
echo ""
echo "Note: Keep this terminal open. Press Ctrl+C to stop."

# Keep running until user stops
wait
