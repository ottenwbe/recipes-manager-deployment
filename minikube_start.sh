#!/usr/bin/env bash

set -ex

if [ "${1:-}" == "--clean" ]; then
    minikube delete --all --purge || true
fi

minikube config set rootless true
minikube start --driver podman --container-runtime=containerd

minikube addons enable ingress
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=120s
kubectl -n ingress-nginx patch configmap ingress-nginx-controller --type merge -p '{"data":{"worker-processes":"1"}}'
kubectl -n ingress-nginx rollout restart deployment/ingress-nginx-controller
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=120s

minikube addons enable registry
