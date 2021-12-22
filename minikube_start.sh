#!/usr/bin/env bash

set -ex

minikube start --driver podman
minikube addons enable ingress
minikube addons enable registry

# Start the registry
docker stop minikube-reg | true
docker rm minikube-reg | true
docker run --name "minikube-reg" -d --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"
