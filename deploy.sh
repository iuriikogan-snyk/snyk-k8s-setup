#!/usr/bin/env bash

# **BEFORE RUNNING THIS SCRIPT CHANGE THE VARS IN setenv.sh or ensure they are available in your environment**
# Exit the script on any error, unset variable, or command failure in a pipeline.
set -xeou pipefail


# Function to print the usage information and exit the script with a non-zero status
function print_usage {
    echo "Usage: bash deploy.sh [--cluster] [--connector] [--monitor] [--demo] [--all]"
    echo "$@"
    exit 1
}

# Function to handle errors globally and print a custom error message
function handle_error {
    echo "Error on line $1"
    exit 1
}

# Trap any error and call the handle_error function
trap 'handle_error $LINENO' ERR

# Source the environment and preparation scripts
# shellcheck source=./setenv.sh
. ./setenv.sh
# shellcheck source=./scripts/prepare.sh
./scripts/prepare.sh

# Check if the correct number of arguments are provided
if [ $# -eq 0 ]; then
    print_usage @
fi

# Flag defaults (except for --all)
deploy_cluster=false
deploy_monitor=false
deploy_connector=false
deploy_demo=false

# Parse the flags
for arg in "$@"; do
    case $arg in
        --cluster)
            deploy_cluster=true
            ;;
        --demo)
            deploy_demo=true
            ;;
        --connector)
            deploy_connector=true
            ;;
        --monitor)
            deploy_monitor=true
            ;;
        --all)
            deploy_cluster=true
            deploy_demo=true
            deploy_connector=true
            deploy_monitor=true
            ;;
        *)
            echo "Invalid argument: $arg"
            print_usage
            ;;
    esac
done

# Deploy using kind if the flag is set
if $deploy_cluster; then
    if [[ ! -f "./scripts/deploy-cluster.sh" ]]; then
        echo "Error: ./scripts/deploy-cluster.sh script is missing."
        exit 1
    fi
    ./scripts/deploy-cluster.sh
fi

# Deploy the snyk-connector if the flag is set
if $deploy_connector; then
    if [[ ! -f "./scripts/deploy-connector.sh" ]]; then
        echo "Error: ./scripts/deploy-connector.sh script is missing."
        exit 1
    fi
    ./srcipts/deploy-connector.sh
fi

# Deploy the snyk-monitor if the flag is set
if $deploy_monitor; then
    if [[ ! -f "./scripts/deploy-monitor.sh" ]]; then
        echo "Error: ./scripts/deploy-monitor.sh script is missing."
        exit 1
    fi
    .scripts/deploy-monitor.sh
fi


# Deploy the demo if the flag is set
if $deploy_demo; then
    if [[ ! -f "./deploy-demo.sh" ]]; then
        echo "Error: ./deploy-demo.sh script is missing."
        exit 1
    fi
    ./deploy-demo.sh
fi