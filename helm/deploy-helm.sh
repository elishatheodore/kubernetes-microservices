#!/bin/bash

# Helm Deployment Script for CAMP Platform
# This script deploys the Cloud Asset Management Platform using Helm

set -e

# Configuration
CHART_NAME="camp"
RELEASE_NAME="camp-release"
NAMESPACE="camp"
CHART_PATH="./helm/camp"
VALUES_FILE="${CHART_PATH}/values.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_color $BLUE "🔍 Checking prerequisites..."
    
    if ! command_exists helm; then
        print_color $RED "❌ Helm not found. Please install Helm first."
        exit 1
    fi
    
    if ! command_exists kubectl; then
        print_color $RED "❌ kubectl not found. Please install kubectl first."
        exit 1
    fi
    
    # Check if cluster is accessible
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_color $RED "❌ Cannot connect to Kubernetes cluster."
        exit 1
    fi
    
    print_color $GREEN "✅ Prerequisites check passed"
}

# Function to create namespace
create_namespace() {
    print_color $BLUE "📂 Creating namespace: $NAMESPACE"
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    print_color $GREEN "✅ Namespace created/verified"
}

# Function to add Helm repositories (if needed)
add_repos() {
    print_color $BLUE "📦 Adding Helm repositories..."
    
    # Add common repositories if needed
    # helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    # helm repo add jetstack https://charts.jetstack.io
    # helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    
    # Update repositories
    helm repo update
    
    print_color $GREEN "✅ Helm repositories updated"
}

# Function to install/upgrade the chart
deploy_chart() {
    print_color $BLUE "🚀 Deploying CAMP platform..."
    
    # Check if release exists
    if helm status $RELEASE_NAME -n $NAMESPACE >/dev/null 2>&1; then
        print_color $YELLOW "🔄 Release exists. Upgrading..."
        helm upgrade $RELEASE_NAME $CHART_PATH \
            --namespace $NAMESPACE \
            --values $VALUES_FILE \
            --wait \
            --timeout 10m
    else
        print_color $GREEN "🆕 Installing new release..."
        helm install $RELEASE_NAME $CHART_PATH \
            --namespace $NAMESPACE \
            --create-namespace \
            --values $VALUES_FILE \
            --wait \
            --timeout 10m
    fi
    
    print_color $GREEN "✅ Chart deployed successfully"
}

# Function to show deployment status
show_status() {
    print_color $BLUE "📊 Deployment status:"
    echo ""
    
    # Show Helm release status
    print_color $YELLOW "Helm Release:"
    helm status $RELEASE_NAME -n $NAMESPACE
    
    echo ""
    # Show pods
    print_color $YELLOW "Pods:"
    kubectl get pods -n $NAMESPACE -o wide
    
    echo ""
    # Show services
    print_color $YELLOW "Services:"
    kubectl get services -n $NAMESPACE
    
    echo ""
    # Show ingress
    print_color $YELLOW "Ingress:"
    kubectl get ingress -n $NAMESPACE
    
    echo ""
    # Show PVCs
    print_color $YELLOW "Persistent Volume Claims:"
    kubectl get pvc -n $NAMESPACE
}

# Function to get access URLs
get_access_urls() {
    print_color $BLUE "🌐 Getting access URLs..."
    
    # Try to get ingress IP
    INGRESS_IP=""
    INGRESS_HOST=""
    
    if kubectl get ingress camp-release -n $NAMESPACE >/dev/null 2>&1; then
        INGRESS_HOST=$(kubectl get ingress camp-release -n $NAMESPACE -o jsonpath='{.spec.rules[0].host}' 2>/dev/null || echo "")
        INGRESS_IP=$(kubectl get ingress camp-release -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    fi
    
    echo ""
    print_color $GREEN "🎉 Deployment completed successfully!"
    echo ""
    
    if [ -n "$INGRESS_HOST" ]; then
        print_color $GREEN "📋 Access URLs:"
        echo "   - Main Application: https://$INGRESS_HOST"
        echo "   - Auth Frontend: https://$INGRESS_HOST/auth"
        echo "   - Backend API: https://$INGRESS_HOST/api"
        echo "   - API Documentation: https://$INGRESS_HOST/api/docs"
    elif [ -n "$INGRESS_IP" ]; then
        print_color $GREEN "📋 Access URLs:"
        echo "   - Main Application: http://$INGRESS_IP"
        echo "   - Auth Frontend: http://$INGRESS_IP/auth"
        echo "   - Backend API: http://$INGRESS_IP/api"
        echo "   - API Documentation: http://$INGRESS_IP/api/docs"
    else
        print_color $YELLOW "⚠️  Ingress not ready or not configured"
        echo "   Use port-forwarding to access the application:"
        echo "   kubectl port-forward svc/camp-release-web-service 8080:80 -n $NAMESPACE"
        echo "   Then access: http://localhost:8080"
    fi
    
    echo ""
    print_color $YELLOW "🔐 Default Credentials:"
    echo "   Username: admin"
    echo "   Password: admin123"
    echo ""
    print_color $YELLOW "📊 Useful Commands:"
    echo "   - View logs: kubectl logs -f deployment/camp-release-backend -n $NAMESPACE"
    echo "   - Get pods: kubectl get pods -n $NAMESPACE"
    echo "   - Get services: kubectl get services -n $NAMESPACE"
    echo "   - Scale deployment: kubectl scale deployment camp-release-backend --replicas=3 -n $NAMESPACE"
    echo "   - Helm status: helm status $RELEASE_NAME -n $NAMESPACE"
}

# Function to show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -d, --debug    Enable debug mode"
    echo "  -f, --file     Custom values file (default: $VALUES_FILE)"
    echo "  -n, --namespace Custom namespace (default: $NAMESPACE)"
    echo "  -r, --release  Custom release name (default: $RELEASE_NAME)"
    echo "  --dry-run      Show what would be deployed without actually deploying"
    echo "  --uninstall    Uninstall the release"
    echo ""
    echo "Examples:"
    echo "  $0                           # Deploy with default settings"
    echo "  $0 -f prod-values.yaml      # Deploy with production values"
    echo "  $0 --dry-run                # Preview deployment"
    echo "  $0 --uninstall              # Remove deployment"
}

# Main function
main() {
    local DEBUG=false
    local DRY_RUN=false
    local UNINSTALL=false
    local CUSTOM_VALUES_FILE=""
    local CUSTOM_NAMESPACE=""
    local CUSTOM_RELEASE=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--debug)
                DEBUG=true
                shift
                ;;
            -f|--file)
                CUSTOM_VALUES_FILE="$2"
                shift 2
                ;;
            -n|--namespace)
                CUSTOM_NAMESPACE="$2"
                shift 2
                ;;
            -r|--release)
                CUSTOM_RELEASE="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --uninstall)
                UNINSTALL=true
                shift
                ;;
            *)
                print_color $RED "❌ Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Update variables with custom values
    if [ -n "$CUSTOM_VALUES_FILE" ]; then
        VALUES_FILE="$CUSTOM_VALUES_FILE"
    fi
    if [ -n "$CUSTOM_NAMESPACE" ]; then
        NAMESPACE="$CUSTOM_NAMESPACE"
    fi
    if [ -n "$CUSTOM_RELEASE" ]; then
        RELEASE_NAME="$CUSTOM_RELEASE"
    fi
    
    # Print configuration
    print_color $BLUE "🔧 Configuration:"
    echo "   Release Name: $RELEASE_NAME"
    echo "   Namespace: $NAMESPACE"
    echo "   Chart Path: $CHART_PATH"
    echo "   Values File: $VALUES_FILE"
    echo "   Debug Mode: $DEBUG"
    echo "   Dry Run: $DRY_RUN"
    echo ""
    
    # Handle uninstall
    if [ "$UNINSTALL" = true ]; then
        print_color $YELLOW "🗑️  Uninstalling release: $RELEASE_NAME"
        helm uninstall $RELEASE_NAME -n $NAMESPACE
        print_color $GREEN "✅ Release uninstalled"
        exit 0
    fi
    
    # Handle dry run
    if [ "$DRY_RUN" = true ]; then
        print_color $BLUE "🔍 Dry run mode - showing what would be deployed:"
        helm template $RELEASE_NAME $CHART_PATH \
            --namespace $NAMESPACE \
            --values $VALUES_FILE
        exit 0
    fi
    
    # Main deployment flow
    check_prerequisites
    add_repos
    create_namespace
    deploy_chart
    show_status
    get_access_urls
}

# Run main function with all arguments
main "$@"
