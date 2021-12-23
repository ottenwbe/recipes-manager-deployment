# recipes-manager-deployment

Kubernetes deployment for recipes-manager and all it's micro-services.

## Example Deployment on Minikube

### Start and Deploy

1. Start Minikube

        minikube start 
        # minikube start --driver podman # alternative driver

1. Enable Ingress Addon

        minikube addons enable       ingress

1. (Optional) Enable registry, e.g., for testing

        minikube addons enable       registry
        docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"   


1. Check if everything is running

        kubectl get nodes

1. Download deployment scripts by cloning this repository

        git clone https://github.com/ottenwbe/recipes-manager-deployment.git

1. Adapt your configuration in a yaml file, i.e., myval.yml
        
        recipesManager:
          drive:
            secrets: |
              <client secret>        
        
1. Deploy with HELM

        helm install test-recipes-manager charts/recipe-manager --namespace test-recipes-manager --create-namespace -f myvals.yml

### Update Deployment
        
1. Change the configruation yaml file
1. Upgrade HELM deployment

        helm upgrade test-recipes-manager charts/recipe-manager --namespace test-recipes-manager --create-namespace -f myvals.yml

### Delete Deployment

To delete HELM deployment

        helm delete test-recipes-manager --namespace test-recipes-manager
