#!/bin/bash

# AKS Cleanup Script for CAMP Platform
# This script removes all CAMP resources from AKS

set -e

# Configuration
NAMESPACE="camp"
CLUSTER_NAME="camp-aks-cluster"
RESOURCE_GROUP="camp-rg"

echo "🗑️  Cleaning up CAMP Platform from AKS..."
echo "Namespace: $NAMESPACE"
echo "Cluster: $CLUSTER_NAME"
echo "Resource Group: $RESOURCE_GROUP"
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

# Get cluster credentials
echo "🔑 Getting AKS credentials..."
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --overwrite-existing

# Delete namespace (this will delete all resources in the namespace)
echo "🗑️  Deleting namespace and all resources..."
kubectl delete namespace $NAMESPACE --ignore-not-found=true

# Optional: Delete the entire resource group
read -p "Do you want to delete the entire resource group '$RESOURCE_GROUP'? This will delete the AKS cluster and all resources. (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Deleting resource group..."
    az group delete --name $RESOURCE_GROUP --yes
    echo "✅ Resource group deleted"
else
    echo "ℹ️  Only namespace deleted. AKS cluster and resource group remain."
fi

echo ""
echo "🎉 Cleanup completed!"
echo ""
echo "📋 Verification:"
echo "   - Check namespaces: kubectl get namespaces"
echo "   - Check resource groups: az group list"
echo ""
echo "🔧 To redeploy:"
echo "   ./deploy.sh"
