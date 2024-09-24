#!/usr/bin/env bash

set -ou pipefail
IFS=$'\t\n'

# Function to print the usage information and exit the script with a non-zero status
function print_usage {
    echo "Usage: bash deploy-demo.sh"
    echo "$*"
    exit 1
}

# Function to handle errors globally and print a custom error message
function handle_error {
    echo "Error on line $1"
    exit 1
}

# Deploy the demo application

kubectl apply -f ./manifests/

echo 'waiting for juice-shop pods to become ready....'
kubectl wait --for=condition=ready pod -l app=juice-shop -n juice-shop --timeout=90s

echo 'You can access juice-shop at: '"$(kubectl get ingress -n juice-shop -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')"