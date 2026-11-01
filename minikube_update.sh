#!/usr/bin/env bash

set -ex

pushd .
cd ../recipes-manager-ui
./scripts/docker.sh build --type dev
minikube image load ottenwbe/recipes-manager-ui:development
popd

pushd .
cd ../recipes-manager-recommender/
./make_docker_for_minikube.sh
minikube image load ottenwbe/recipes-manager-recommender:development
popd

pushd .
cd ../recipes-manager
make docker-dev
minikube image load ottenwbe/recipes-manager:development
popd
