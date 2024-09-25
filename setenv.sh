#!/usr/bin/env bash

# Set the required vars here before running deploy.sh
# you can change the values here or have them available in your env prior to running the script 

# Only export if not already set (optional variables)
export CLUSTER_NAME="${CLUSTER_NAME:="dev"}"          # Default empty if not set
export SNYK_INTEGRATION_ID="${SNYK_INTEGRATION_ID:-}"
export SNYK_MONITOR_SA_TOKEN="${SNYK_MONITOR_SA_TOKEN:-}"
export SNYK_CONNECTOR_SA_TOKEN="${SNYK_CONNECTOR_SA_TOKEN:-}"
export SNYK_ORG_ID="${SNYK_ORG_ID:-}"

# Notify user of any defaults applied (except password)
echo "CLUSTER_NAME is set to '${CLUSTER_NAME}'"
echo "SNYK_MONITOR_SA_TOKEN is set"
echo "SNYK_CONNECTOR_SA_TOKEN is set"
echo "SNYK_ORG_ID is set to '${SNYK_ORG_ID}'"