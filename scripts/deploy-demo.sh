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

# echo $DOCKERHUB_PASSWORD | docker login --username "$DOCKERHUB_USERNAME" --password-stdin

# # Build the demo application
# docker build . -t "$DOCKERHUB_USERNAME"/nodejs-goof:linux-arm64 --platform=linux/arm64

# # Monitor the container with the correct tags
# snyk monitor "$DOCKERHUB_USERNAME"/nodejs-goof:linux-arm64 --platform=linux/arm64 --tags=

# Deploy the demo application
cat << EOL | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: nodejs-goof 
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-goof 
  namespace: nodejs-goof 
spec:
  selector:
    matchLabels:
      app: nodejs-goof 
  template:
    metadata:
      labels:        
        app: nodejs-goof 
    spec:
      containers:
      - name: nodejs-goof 
        image: ${DOCKERHUB_USERNAME}/nodejs-goof:linux-arm64
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-goof 
  namespace: nodejs-goof
  labels:
    app: nodejs-goof 
spec:
  type: ClusterIP
  ports:
    - port: 1337
      targetPort: 3000
      protocol: TCP
  selector:
    app: nodejs-goof 
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name:  nodejs-goof-ingress
  namespace: nodejs-goof
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nodejs-goof 
            port:
              number: 1337
EOL

cat << EOL | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: nodejs-goof-internal
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-goof-internal
  namespace: nodejs-goof-internal
spec:
  selector:
    matchLabels:  
      app: nodejs-goof-internal
  template:
    metadata:
      labels:
        app: nodejs-goof-internal
    spec:
      containers:
      - name: nodejs-goof-internal
        image: ${DOCKERHUB_USERNAME}/nodejs-goof:linux-arm64
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 3000
EOL

echo 'waiting for nodejs-goof pods to become ready....'
kubectl wait --for=condition=ready pod -l app=nodejs-goof -n nodejs-goof --timeout=90s