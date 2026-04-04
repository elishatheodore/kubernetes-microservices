#!/bin/bash

# AKS Deployment Script for CAMP Platform
# This script deploys the Cloud Asset Management Platform to AKS

set -e

# Configuration
NAMESPACE="camp"
CLUSTER_NAME="camp-aks-cluster"
RESOURCE_GROUP="camp-rg"
LOCATION="eastus"
DNS_NAME="camp.yourdomain.com"  # Update this with your actual domain

echo "🚀 Deploying CAMP Platform to AKS..."
echo "Cluster: $CLUSTER_NAME"
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "Namespace: $NAMESPACE"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "🔍 Checking prerequisites..."
if ! command_exists az; then
    echo "❌ Azure CLI not found. Please install it first."
    exit 1
fi

if ! command_exists kubectl; then
    echo "❌ kubectl not found. Please install it first."
    exit 1
fi

# Check Azure login
echo "🔐 Checking Azure authentication..."
if ! az account show >/dev/null 2>&1; then
    echo "❌ Not logged into Azure. Please run 'az login' first."
    exit 1
fi

# Create resource group if it doesn't exist
echo "📦 Creating resource group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --tags "project=camp" "environment=production" || echo "Resource group already exists"

# Create AKS cluster if it doesn't exist
echo "🔧 Creating AKS cluster..."
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 3 \
    --node-vm-size Standard_B2s \
    --enable-cluster-autoscaler \
    --min-count 2 \
    --max-count 5 \
    --network-plugin azure \
    --network-policy azure \
    --enable-addons monitoring \
    --attach-acr $ACR_NAME \
    --generate-ssh-keys || echo "AKS cluster already exists"

# Get cluster credentials
echo "🔑 Getting AKS credentials..."
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --overwrite-existing

# Verify cluster connection
echo "✅ Verifying cluster connection..."
kubectl cluster-info

# Create namespace
echo "📂 Creating namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Apply all manifests
echo "🚀 Applying Kubernetes manifests..."
kubectl apply -k .

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/camp-backend -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/camp-web -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/camp-auth -n $NAMESPACE

# Get ingress IP
echo "🌐 Getting ingress IP..."
INGRESS_IP=""
while [ -z "$INGRESS_IP" ]; do
    echo "Waiting for ingress IP..."
    INGRESS_IP=$(kubectl get ingress camp-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -z "$INGRESS_IP" ]; then
        sleep 10
    fi
done

echo "✅ Ingress IP: $INGRESS_IP"

# Show status
echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📊 Deployment Status:"
kubectl get pods -n $NAMESPACE
echo ""
echo "🌐 Access URLs:"
echo "   - Main Application: http://$INGRESS_IP"
echo "   - Auth Frontend: http://$INGRESS_IP/auth"
echo "   - Backend API: http://$INGRESS_IP/api"
echo "   - API Documentation: http://$INGRESS_IP/api/docs"
echo ""
echo "📋 Useful Commands:"
echo "   - View logs: kubectl logs -f deployment/camp-backend -n $NAMESPACE"
echo "   - Get pods: kubectl get pods -n $NAMESPACE"
echo "   - Get services: kubectl get services -n $NAMESPACE"
echo "   - Scale deployment: kubectl scale deployment camp-backend --replicas=3 -n $NAMESPACE"
echo ""
echo "🔧 To update the deployment:"
echo "   kubectl apply -k ."
echo ""
echo "🗑️  To cleanup:"
echo "   kubectl delete namespace $NAMESPACE"
echo "   az group delete --name $RESOURCE_GROUP --yes"
