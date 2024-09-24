#!/usr/bin/env bash

set -ou pipefail
# Exit the script on any error, unset variable, or command failure in a pipeline.

# **BEFORE RUNNING THIS SCRIPT CHANGE THE VARS IN setenv.sh or ensure SNYK_MONITOR_SA_TOKEN are available in your environment**

# Function to print the usage information and exit the script with a non-zero status
function print_usage {
    echo "Usage: bash deploy-monitor.sh --SNYK_MONITOR_SA_TOKEN"
    echo "$*"
    exit 1
}

# Function to handle errors globally and print a custom error message
function handle_error {
    echo "Error on line $1"
    exit 1
}

if [[ -z "$SNYK_MONITOR_SA_TOKEN" ]]; then
    read -p -s -r SNYK_MONITOR_SA_TOKEN
    export SNYK_MONITOR_SA_TOKEN
    echo "SNYK_MONITOR_SA_TOKEN is set"
fi

# Deploy the snyk-connector

kubectl create ns snyk-monitor

kubectl create secret generic snyk-monitor-secret -n snyk-monitor --from-literal=snykServiceAccountToken="$SNYK_MONITOR_SA_TOKEN"

helm repo add snyk-monitor https://snyk.github.io/snyk-monitor
helm repo update

helm upgrade --install snyk-monitor -n snyk-monitor \
	--set "secretName=snyk-monitor-secret" \
	--set "config.clusterName=dev" \
	--set "config.routes[0].organizationID=${SNYK_ORG_ID}" \
	--set "config.routes[0].clusterScopedResources=true" \
	--set "config.routes[0].namespaces[0]=*"  \
	snyk-monitor/snyk-monitor

echo 'waiting for snyk-monitor pods to become ready....'
kubectl -n snyk-monitor wait --for=condition=ready pod -l app.kubernetes.io/name=snyk-monitor --timeout=90s
