# recipes-manager-deployment

Kubernetes deployment for recipes-manager and all its micro-services.

> **Note**: These scripts and configurations are primarily designed for **testing and development** purposes. TLS certificate verification is intentionally disabled for the local registry to simplify local development workflows.

## Prerequisites

Before deploying, ensure you have the following tools installed:

- **minikube** — Kubernetes cluster for local development
- **kubectl** — Kubernetes command-line tool
- **helm** — Package manager for Kubernetes (v3+)
- **podman** or **docker** — Container engine

To verify installation:

```bash
minikube version
kubectl version --client
helm version
podman --version # or docker --version
```

## Quick Start for Local Testing

Use the provided helper scripts for rapid local testing:

```bash
# Start minikube and enable required addons
./minikube_start.sh

# Build and push all images to the local registry, then deploy
./minikube_update.sh
```

## Example Deployment on Minikube (Manual)

### Start and Deploy

1. Start Minikube

        minikube start --driver podman

1. Enable Ingress Addon

        minikube addons enable ingress

1. Enable registry addon (for local development/testing)

        minikube addons enable registry

1. Check if everything is running

        kubectl get nodes

1. Download deployment scripts by cloning this repository

        git clone https://github.com/ottenwbe/recipes-manager-deployment.git

1. Deploy with HELM

        helm install test-recipes-manager charts/recipe-manager --namespace test-recipes-manager --create-namespace -f charts/recipe-manager/values-development.yaml

### Update Deployment
        
        helm upgrade test-recipes-manager charts/recipe-manager --namespace test-recipes-manager --create-namespace -f charts/recipe-manager/values-development.yaml

### Delete Deployment

To delete HELM deployment:

        helm delete test-recipes-manager --namespace test-recipes-manager

## Accessing and Testing the Deployed Applications

### Get Service URLs

After deployment, retrieve the ingress URL:

```bash
# Get the ingress hostname or IP
kubectl get ingress -n test-recipes-manager

# For minikube, you may need to use minikube service
minikube service -n test-recipes-manager recipes-manager-ui
minikube service -n test-recipes-manager recipes-manager-api
```

Or directly with port-forward for testing:

```bash
# Frontend (UI)
kubectl port-forward -n test-recipes-manager svc/ui-service 3000:80 &
# Access at http://localhost:3000

# Backend API
kubectl port-forward -n test-recipes-manager svc/recipes-manager-api 8080:8080 &
# Access at http://localhost:8080
```

### Testing the Frontend

1. Open your browser and navigate to the UI URL (e.g., `http://localhost:3000`)
2. Verify the following:
   - Page loads without errors
   - CSS/styling is applied correctly
   - Responsive design works on different screen sizes

Check frontend logs:

```bash
kubectl logs -n test-recipes-manager -l app=recipes-manager-ui -f
```

### Testing the Backend API

#### Health Check

```bash
curl http://localhost:8080/api/v1/recipes
```

#### List Recipes

```bash
curl http://localhost:8080/api/recipes
```

#### Create a Recipe

**Note:** All configuration must use the `RECIPES_MANAGER_` prefix.

```bash
curl -X POST http://localhost:8080/api/v1/recipes \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Recipe",
    "description": "A test recipe",
    "ingredients": ["ingredient1", "ingredient2"],
    "instructions": "Mix and cook"
  }'
```

#### Check Backend Logs

```bash
kubectl logs -n test-recipes-manager -l app=recipes-manager-api -f
```

### Verify Recommender Service

#### Health Check

Test the health check via port-forward:

```bash
kubectl port-forward -n test-recipes-manager svc/recipes-manager-recommender 5000:5000 &
# Access at http://localhost:5000/api/v1/recommendation/health

curl http://localhost:5000/api/v1/recommendation/health
```

#### Check Status
Check if the pods are running:

```bash
kubectl get pods -n test-recipes-manager -l app=recipes-manager-recommender

# View logs
kubectl logs -n test-recipes-manager -l app=recipes-manager-recommender -f
```

## Local Development Notes

### TLS Verification Disabled

For local development testing, TLS certificate verification is **intentionally disabled** when interacting with the local minikube registry. This includes:

- `podman push --tls-verify=false` in build scripts
- Registry configuration allowing HTTP connections

**⚠️ Important**: Do NOT disable TLS verification in production environments. These settings are only suitable for isolated local development.

### Registry Setup

The local registry is accessed via `kubectl port-forward`, which creates a temporary tunnel to the minikube registry service. This connection is automatically cleaned up when scripts complete.
