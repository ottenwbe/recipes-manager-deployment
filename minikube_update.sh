#!/usr/bin/env bash

set -ex

# Start the registry
docker rm minikube-reg | true
docker run --name "minikube-reg" -d --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"

pushd .
cd ../recipes-manager-ui
./scripts/make_docker_for_minikube.sh
popd

pushd .
cd ../recipes-manager-ai/
./make_docker_for_minikube.sh
popd

pushd .
cd ../recipes-manager
DOCKER_REGISTRY=localhost:5000 make docker-dev && DOCKER_REGISTRY=localhost:5000 make docker-push-dev
popd
