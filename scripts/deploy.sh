#!/bin/bash

# Multi-Cluster Deployment Script
# This script handles deployment across multiple Kubernetes clusters and environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CLUSTERS_FILE="$PROJECT_ROOT/clusters/cluster-config.yaml"
ENVIRONMENTS_DIR="$PROJECT_ROOT/environments"
HELM_CHART_DIR="$PROJECT_ROOT/helm/camp"

# Default values
CLUSTER=""
ENVIRONMENT=""
IMAGE_TAG=""
NAMESPACE=""
DRY_RUN=false
VERBOSE=false
FORCE=false
GITOPS=false

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print header
print_header() {
    local message=$1
    echo ""
    print_color $BLUE "🚀 $message"
    echo "================================================================"
}

# Function to print success
print_success() {
    local message=$1
    print_color $GREEN "✅ $message"
}

# Function to print warning
print_warning() {
    local message=$1
    print_color $YELLOW "⚠️  $message"
}

# Function to print error
print_error() {
    local message=$1
    print_color $RED "❌ $message"
}

# Function to print info
print_info() {
    local message=$1
    print_color $CYAN "ℹ️  $message"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check required tools
    local required_tools=("kubectl" "helm" "yq")
    for tool in "${required_tools[@]}"; do
        if ! command_exists "$tool"; then
            print_error "$tool is not installed. Please install it first."
            exit 1
        fi
        print_success "$tool is installed"
    done
    
    # Check if files exist
    local required_files=("$CLUSTERS_FILE" "$HELM_CHART_DIR/Chart.yaml")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file not found: $file"
            exit 1
        fi
        print_success "Found: $file"
    done
    
    # Check if environment file exists
    local env_file="$ENVIRONMENTS_DIR/values-${ENVIRONMENT}.yaml"
    if [[ ! -f "$env_file" ]]; then
        print_error "Environment file not found: $env_file"
        print_info "Available environments:"
        ls -1 "$ENVIRONMENTS_DIR"/values-*.yaml | sed 's/.*values-\(.*\)\.yaml/  - \1/'
        exit 1
    fi
    print_success "Found environment file: $env_file"
    
    print_success "Prerequisites check passed"
}

# Function to load cluster configuration
load_cluster_config() {
    print_header "Loading Cluster Configuration"
    
    if [[ ! -f "$CLUSTERS_FILE" ]]; then
        print_error "Cluster configuration file not found: $CLUSTERS_FILE"
        exit 1
    fi
    
    # Load cluster configuration
    CLUSTER_CONFIG=$(yq eval ".clusters.$CLUSTER" "$CLUSTERS_FILE")
    if [[ "$CLUSTER_CONFIG" == "null" ]]; then
        print_error "Cluster '$CLUSTER' not found in configuration"
        print_info "Available clusters:"
        yq eval '.clusters | keys | .[]' "$CLUSTERS_FILE" | sed 's/^/  - /'
        exit 1
    fi
    
    # Extract cluster details
    CLUSTER_TYPE=$(echo "$CLUSTER_CONFIG" | yq eval '.type' -)
    CLUSTER_PROVIDER=$(echo "$CLUSTER_CONFIG" | yq eval '.provider' -)
    CLUSTER_REGION=$(echo "$CLUSTER_CONFIG" | yq eval '.region' -)
    CLUSTER_CONTEXT=$(echo "$CLUSTER_CONFIG" | yq eval '.context' -)
    CLUSTER_NAMESPACE=$(echo "$CLUSTER_CONFIG" | yq eval '.namespace' -)
    
    # Use provided namespace or default
    NAMESPACE=${NAMESPACE:-$CLUSTER_NAMESPACE}
    
    # Check if environment is supported by cluster
    local supported_envs=$(echo "$CLUSTER_CONFIG" | yq eval '.environments[]' -)
    if ! echo "$supported_envs" | grep -q "^${ENVIRONMENT}$"; then
        print_error "Environment '$ENVIRONMENT' not supported by cluster '$CLUSTER'"
        print_info "Supported environments:"
        echo "$supported_envs" | sed 's/^/  - /'
        exit 1
    fi
    
    print_success "Cluster configuration loaded"
    print_info "Cluster: $CLUSTER ($CLUSTER_TYPE/$CLUSTER_PROVIDER)"
    print_info "Region: $CLUSTER_REGION"
    print_info "Context: $CLUSTER_CONTEXT"
    print_info "Namespace: $NAMESPACE"
    print_info "Environment: $ENVIRONMENT"
}

# Function to switch cluster context
switch_cluster_context() {
    print_header "Switching Cluster Context"
    
    # Check if context exists
    if ! kubectl config get-contexts "$CLUSTER_CONTEXT" >/dev/null 2>&1; then
        print_error "Kubernetes context '$CLUSTER_CONTEXT' not found"
        print_info "Available contexts:"
        kubectl config get-contexts -o name | sed 's/^/  /'
        exit 1
    fi
    
    # Switch context
    kubectl config use-context "$CLUSTER_CONTEXT"
    print_success "Switched to context: $CLUSTER_CONTEXT"
    
    # Verify cluster connectivity
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_error "Cannot connect to cluster"
        exit 1
    fi
    
    print_success "Cluster connectivity verified"
}

# Function to create namespace
create_namespace() {
    print_header "Creating Namespace"
    
    # Create namespace if it doesn't exist
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    print_success "Namespace '$NAMESPACE' created/verified"
}

# Function to validate Helm chart
validate_helm_chart() {
    print_header "Validating Helm Chart"
    
    # Lint the chart
    if ! helm lint "$HELM_CHART_DIR"; then
        print_error "Helm chart validation failed"
        exit 1
    fi
    
    print_success "Helm chart validation passed"
}

# Function to build deployment values
build_deployment_values() {
    print_header "Building Deployment Values"
    
    local env_file="$ENVIRONMENTS_DIR/values-${ENVIRONMENT}.yaml"
    local temp_values_file="/tmp/camp-deployment-values.yaml"
    
    # Start with base values
    if [[ -f "$HELM_CHART_DIR/values.yaml" ]]; then
        cp "$HELM_CHART_DIR/values.yaml" "$temp_values_file"
    else
        echo "" > "$temp_values_file"
    fi
    
    # Merge environment-specific values
    yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' "$temp_values_file" "$env_file" > "${temp_values_file}.merged"
    mv "${temp_values_file}.merged" "$temp_values_file"
    
    # Override with command-line parameters
    if [[ -n "$IMAGE_TAG" ]]; then
        yq eval ".image.tag = \"$IMAGE_TAG\"" "$temp_values_file" > "${temp_values_file}.tag"
        mv "${temp_values_file}.tag" "$temp_values_file"
    fi
    
    # Add cluster-specific values
    if [[ "$CLUSTER_TYPE" == "managed" ]]; then
        yq eval '.global.clusterType = "managed"' "$temp_values_file" > "${temp_values_file}.cluster"
        mv "${temp_values_file}.cluster" "$temp_values_file"
    fi
    
    # Set namespace in values
    yq eval ".global.namespace = \"$NAMESPACE\"" "$temp_values_file" > "${temp_values_file}.ns"
    mv "${temp_values_file}.ns" "$temp_values_file"
    
    print_success "Deployment values built"
    if [[ "$VERBOSE" == true ]]; then
        print_info "Generated values:"
        cat "$temp_values_file"
    fi
    
    echo "$temp_values_file"
}

# Function to deploy with Helm
deploy_helm() {
    print_header "Deploying with Helm"
    
    local values_file=$1
    local release_name="camp-${ENVIRONMENT}"
    
    # Check if release exists
    if helm status "$release_name" -n "$NAMESPACE" >/dev/null 2>&1; then
        if [[ "$FORCE" == true ]]; then
            print_warning "Release exists. Force upgrading..."
            helm upgrade "$release_name" "$HELM_CHART_DIR" \
                --namespace "$NAMESPACE" \
                --values "$values_file" \
                --force \
                --wait \
                --timeout 10m
        else
            print_warning "Release exists. Upgrading..."
            helm upgrade "$release_name" "$HELM_CHART_DIR" \
                --namespace "$NAMESPACE" \
                --values "$values_file" \
                --wait \
                --timeout 10m
        fi
    else
        print_info "Installing new release..."
        helm install "$release_name" "$HELM_CHART_DIR" \
            --namespace "$NAMESPACE" \
            --create-namespace \
            --values "$values_file" \
            --wait \
            --timeout 10m
    fi
    
    print_success "Helm deployment completed"
}

# Function to show deployment status
show_deployment_status() {
    print_header "Deployment Status"
    
    local release_name="camp-${ENVIRONMENT}"
    
    # Show Helm release status
    print_info "Helm Release Status:"
    helm status "$release_name" -n "$NAMESPACE"
    
    echo ""
    # Show pods
    print_info "Pods:"
    kubectl get pods -n "$NAMESPACE" -o wide
    
    echo ""
    # Show services
    print_info "Services:"
    kubectl get services -n "$NAMESPACE"
    
    echo ""
    # Show ingress
    print_info "Ingress:"
    kubectl get ingress -n "$NAMESPACE"
    
    echo ""
    # Show PVCs
    print_info "Persistent Volume Claims:"
    kubectl get pvc -n "$NAMESPACE"
}

# Function to get access URLs
get_access_urls() {
    print_header "Access URLs"
    
    # Try to get ingress information
    local ingress_host=""
    local ingress_ip=""
    
    if kubectl get ingress -n "$NAMESPACE" >/dev/null 2>&1; then
        ingress_host=$(kubectl get ingress -n "$NAMESPACE" -o jsonpath='{.items[0].spec.rules[0].host}' 2>/dev/null || echo "")
        ingress_ip=$(kubectl get ingress -n "$NAMESPACE" -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    fi
    
    if [[ -n "$ingress_host" ]]; then
        print_success "Application URLs:"
        echo "  - Main Application: https://$ingress_host"
        echo "  - Auth Frontend: https://$ingress_host/auth"
        echo "  - Backend API: https://$ingress_host/api"
        echo "  - API Documentation: https://$ingress_host/api/docs"
    elif [[ -n "$ingress_ip" ]]; then
        print_success "Application URLs:"
        echo "  - Main Application: http://$ingress_ip"
        echo "  - Auth Frontend: http://$ingress_ip/auth"
        echo "  - Backend API: http://$ingress_ip/api"
        echo "  - API Documentation: http://$ingress_ip/api/docs"
    else
        print_warning "Ingress not ready or not configured"
        print_info "Use port-forwarding to access the application:"
        echo "  kubectl port-forward svc/camp-${ENVIRONMENT}-web-service 8080:80 -n $NAMESPACE"
        echo "  Then access: http://localhost:8080"
    fi
    
    # Show default credentials
    print_info "Default Credentials:"
    echo "  Username: admin"
    echo "  Password: admin123 (change in production)"
}

# Function to show help
show_help() {
    echo "Multi-Cluster Deployment Script for CAMP Platform"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Required Options:"
    echo "  -c, --cluster CLUSTER     Target cluster name"
    echo "  -e, --environment ENV     Target environment (dev, staging, prod)"
    echo ""
    echo "Optional Options:"
    echo "  -t, --tag TAG             Docker image tag to deploy"
    echo "  -n, --namespace NAMESPACE Kubernetes namespace (overrides cluster default)"
    echo "  -d, --dry-run             Show what would be deployed without actually deploying"
    echo "  -f, --force               Force upgrade even if release exists"
    echo "  -v, --verbose             Enable verbose output"
    echo "  -g, --gitops              Enable GitOps mode (if supported by cluster)"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  # Deploy to local development"
    echo "  $0 -c local-dev -e dev"
    echo ""
    echo "  # Deploy to staging with specific image tag"
    echo "  $0 -c aks-staging -e staging -t v1.0.0"
    echo ""
    echo "  # Deploy to production with force upgrade"
    echo "  $0 -c aks-prod -e prod -t v1.0.0 -f"
    echo ""
    echo "  # Dry run to preview deployment"
    echo "  $0 -c aks-prod -e prod --dry-run"
    echo ""
    echo "Available Clusters:"
    yq eval '.clusters | keys | .[]' "$CLUSTERS_FILE" 2>/dev/null | sed 's/^/  - /' || echo "  (cluster config not found)"
}

# Function to cleanup
cleanup() {
    if [[ -f "$temp_values_file" ]]; then
        rm -f "$temp_values_file"
    fi
}

# Main function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--cluster)
                CLUSTER="$2"
                shift 2
                ;;
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -t|--tag)
                IMAGE_TAG="$2"
                shift 2
                ;;
            -n|--namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -g|--gitops)
                GITOPS=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$CLUSTER" ]]; then
        print_error "Cluster is required. Use -c or --cluster"
        show_help
        exit 1
    fi
    
    if [[ -z "$ENVIRONMENT" ]]; then
        print_error "Environment is required. Use -e or --environment"
        show_help
        exit 1
    fi
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Print banner
    echo ""
    print_color $PURPLE "🚀 CAMP Multi-Cluster Deployment"
    echo "================================================================"
    print_info "Cluster: $CLUSTER"
    print_info "Environment: $ENVIRONMENT"
    print_info "Image Tag: ${IMAGE_TAG:-latest}"
    print_info "Namespace: ${NAMESPACE:-default}"
    print_info "Dry Run: $DRY_RUN"
    echo ""
    
    # Main deployment flow
    check_prerequisites
    load_cluster_config
    switch_cluster_context
    create_namespace
    validate_helm_chart
    
    # Build deployment values
    temp_values_file=$(build_deployment_values)
    
    # Handle dry run
    if [[ "$DRY_RUN" == true ]]; then
        print_header "Dry Run Mode"
        print_info "Previewing deployment manifests:"
        helm template "camp-${ENVIRONMENT}" "$HELM_CHART_DIR" \
            --namespace "$NAMESPACE" \
            --values "$temp_values_file"
        exit 0
    fi
    
    # Deploy
    deploy_helm "$temp_values_file"
    show_deployment_status
    get_access_urls
    
    # Handle GitOps if enabled
    if [[ "$GITOPS" == true ]]; then
        print_header "GitOps Integration"
        print_info "GitOps is enabled for this cluster"
        print_info "The deployment will be synchronized by GitOps controller"
        print_info "Check your GitOps tool (ArgoCD/Flux) for sync status"
    fi
    
    print_success "Deployment completed successfully!"
}

# Run main function with all arguments
main "$@"
