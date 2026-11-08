#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-test-recipes-manager}"
LOCAL_PORT="${1:-8080}"
INGRESS_NAME="recipes-manager-ingress"
CONTROLLER_NAMESPACE="ingress-nginx"
CONTROLLER_SERVICE="ingress-nginx-controller"

if ! kubectl -n "$NAMESPACE" get ingress "$INGRESS_NAME" >/dev/null 2>&1; then
    echo "Ingress '$INGRESS_NAME' was not found in namespace '$NAMESPACE'." >&2
    echo "Deploy the Helm chart before starting ingress access." >&2
    exit 1
fi

kubectl -n "$CONTROLLER_NAMESPACE" rollout status \
    deployment/ingress-nginx-controller --timeout=30s

echo "Ingress is available at http://localhost:${LOCAL_PORT}"
echo "  UI:           http://localhost:${LOCAL_PORT}/"
echo "  API:          http://localhost:${LOCAL_PORT}/api/v1/recipes"
echo "  Recommender:  http://localhost:${LOCAL_PORT}/api/v1/recommendation/health"
echo "  Swagger:      http://localhost:${LOCAL_PORT}/swagger/index.html"
echo
echo "Keep this process running while using the URLs. Press Ctrl-C to stop."

exec kubectl -n "$CONTROLLER_NAMESPACE" port-forward \
    --address 127.0.0.1 \
    "service/${CONTROLLER_SERVICE}" \
    "${LOCAL_PORT}:80"
