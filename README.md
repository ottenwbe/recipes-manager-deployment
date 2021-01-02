# recipes-manager-deployment

Kubernetes deployment for recipes-manager

## Example Deployment on Minikube

1. Start Minikube

        minikube start 
        minikube start --driver podman

1. Enable addons 

        minikube addons enable ingress

1. Check if everything is running

        kubectl get nodes

1. Download deployment scripts

1. Adapt your configuration in a file myval.yml
        
        recipesManager:
          drive:
            secrets: |
              <client secret>        
        
        

1. Deploy with HELM

        helm install test-recipes-manager charts/recipe-manager --namespace test-recipes-manager --create-namespace -f myvals.yml


        