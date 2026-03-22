#!/usr/bin/env bash

set -ex

minikube delete --all --purge || true
podman rm -f minikube || true
podman volume rm minikube || true
minikube config set rootless true
minikube start --driver podman --container-runtime=containerd --extra-config=kubelet.cgroup-driver=systemd --delete-on-failure

# Verify cluster health before attempting addons
minikube status

minikube addons enable ingress
minikube addons enable registry

# Start the registry
podman stop minikube-reg || true

podman rm minikube-reg || true
REGISTRY_PORT=$(podman port minikube 5000 | awk -F: '{print $NF}')
podman run --name "minikube-reg" -d --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:127.0.0.1:$REGISTRY_PORT"
