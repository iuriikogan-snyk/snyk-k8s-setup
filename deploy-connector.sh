#!/usr/bin/env bash

set -ou pipefail

# **BEFORE RUNNING THIS SCRIPT CHANGE THE VARS IN setenv.sh or ensure they are available in your environment**
# Exit the script on any error, unset variable, or command failure in a pipeline.

IFS=$'\t\n'

# Function to print the usage information and exit the script with a non-zero status
function print_usage {
    echo "Usage: bash deploy-connector.sh"
    echo "$*"
    exit 1
}

# Function to handle errors globally and print a custom error message
function handle_error {
    echo "Error on line $1"
    exit 1
}

if [[ -z "${SNYK_CONNECTOR_SA_TOKEN:-}" ]]; then
    read -p -s -r SNYK_CONNECTOR_SA_TOKEN 
    export SNYK_CONNECTOR_SA_TOKEN
    echo "SNYK_CONNECTOR_SA_TOKEN is set"
fi

# Deploy the snyk-connector

kubectl create ns snyk-connector

kubectl create secret generic snyk-connector-secret -n snyk-connector --from-literal=snykServiceAccountToken="$SNYK_CONNECTOR_SA_TOKEN"

helm repo add kubernetes-scanner https://snyk.github.io/kubernetes-scanner
helm repo update

helm upgrade --install snyk-connector -n snyk-connector \
	--set "secretName=snyk-connector-secret" \
	--set "config.clusterName=dev" \
	--set "config.routes[0].organizationID=${SNYK_ORG_ID}" \
	--set "config.routes[0].clusterScopedResources=true" \
	--set "config.routes[0].namespaces[0]=*"  \
	kubernetes-scanner/kubernetes-scanner

echo 'waiting for kubernetes-connector pods to become ready....'
kubectl -n snyk-connector wait --for=condition=ready pod -l app.kubernetes.io/name=kubernetes-scanner --timeout=90s
