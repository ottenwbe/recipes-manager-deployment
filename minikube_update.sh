#!/usr/bin/env bash

set -ex

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
