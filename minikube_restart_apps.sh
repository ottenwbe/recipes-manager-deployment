#!/usr/bin/env bash

set -ex

kubectl rollout restart deployment.apps/recipe-manager --namespace=recipes-manager
kubectl rollout restart deployment.apps/recipes-manager-ui-app --namespace=recipes-manager
kubectl rollout restart deployment.apps/recipes-recommendation-app --namespace=recipes-manager
