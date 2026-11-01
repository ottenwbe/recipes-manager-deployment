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

### Access services through Ingress

With the Podman driver, the Minikube node IP is not necessarily reachable
directly from the host. Start a local forward to the Ingress controller:

```bash
./ingress_test.sh
```

Keep the command running, then open `http://localhost:8080`. The same Ingress
routes the API at `/api`, the recommender at
`/api/v1/recommendation`, and Swagger at `/swagger`.

The Minikube startup script limits the local Ingress controller to one Nginx
worker to avoid exhausting the Podman container's process limit.

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

### Kubernetes API Deprecation Warnings

When using minikube with Kubernetes v1.33+, you may see deprecation warnings like:
```
W1101 14:42:20.988287 warnings.go:70] v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
```

These warnings are **harmless** and come from Kubernetes internally when it auto-creates Endpoints resources for Services. The `v1` Endpoints API is deprecated in favor of `discovery.k8s.io/v1` EndpointSlice, but both coexist in modern Kubernetes versions. The Helm chart has been updated to use current API versions (e.g., `autoscaling/v2` instead of `autoscaling/v2beta1`).

### Registry Setup

The local registry is accessed via `kubectl port-forward`, which creates a temporary tunnel to the minikube registry service. This connection is automatically cleaned up when scripts complete.

### Disclaimer

This repository is mainly for learning and testing. However, feel free to contribute if you are interested.

AI Agents helped to support with updating the latest changes.