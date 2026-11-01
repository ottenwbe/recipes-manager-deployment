#!/usr/bin/env bash

set -ex

if [ "$1" == "--clean" ]; then
    minikube delete --all --purge || true
fi

minikube config set rootless true
minikube start --driver podman --container-runtime=containerd

minikube addons enable ingress
minikube addons enable registry
