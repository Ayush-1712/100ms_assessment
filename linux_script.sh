#!/bin/bash

set -e

check_and_install() {
    local cmd=$1
    local package=$2
    if ! command -v "$cmd" &>/dev/null; then
        echo "$cmd not found. Installing $package..."
        sudo apt-get update
        sudo apt-get install -y "$package"
    else
        echo "$cmd is already installed."
    fi
}

echo "Checking for Minikube..."
if ! command -v minikube &>/dev/null; then
    echo "Minikube not found. Installing..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
else
    echo "Minikube is already installed."
fi

echo "Checking for kubectl..."
check_and_install kubectl kubectl

echo "Starting Minikube..."
minikube start --driver=docker

echo "Configuring kubectl to use Minikube..."
kubectl config use-context minikube

echo "Checking Minikube status..."
minikube status

echo "Deploying Flask app to Minikube..."
if [ ! -f "flask_deployment.yaml" ] || [ ! -f "flask_service.yaml" ]; then
    echo "Error: YAML files flask_deployment.yaml or flask_service.yaml not found."
    exit 1
fi

kubectl apply -f flask_deployment.yaml
kubectl apply -f flask_service.yaml

echo "Verifying deployment..."
kubectl get pods
kubectl get services

echo "Flask app has been deployed successfully."
