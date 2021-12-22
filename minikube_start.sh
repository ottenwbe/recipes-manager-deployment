#!/usr/bin/env bash

set -ex

minikube start --driver podman
minikube addons enable ingress
minikube addons enable registry
