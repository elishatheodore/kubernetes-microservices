#!/bin/bash

# Cluster Management Script
# This script manages multiple Kubernetes clusters

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
    print_color $BLUE "🔧 $message"
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
    local required_tools=("kubectl" "yq")
    for tool in "${required_tools[@]}"; do
        if ! command_exists "$tool"; then
            print_error "$tool is not installed. Please install it first."
            exit 1
        fi
        print_success "$tool is installed"
    done
    
    # Check if clusters file exists
    if [[ ! -f "$CLUSTERS_FILE" ]]; then
        print_error "Cluster configuration file not found: $CLUSTERS_FILE"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to list all clusters
list_clusters() {
    print_header "Available Clusters"
    
    local clusters=$(yq eval '.clusters | keys | .[]' "$CLUSTERS_FILE")
    
    if [[ -z "$clusters" ]]; then
        print_error "No clusters found in configuration"
        exit 1
    fi
    
    echo ""
    printf "%-20s %-10s %-15s %-15s %-10s\n" "CLUSTER" "TYPE" "PROVIDER" "REGION" "ENVIRONMENTS"
    echo "--------------------------------------------------------------------------------"
    
    while IFS= read -r cluster; do
        local cluster_type=$(yq eval ".clusters.$cluster.type" "$CLUSTERS_FILE")
        local cluster_provider=$(yq eval ".clusters.$cluster.provider" "$CLUSTERS_FILE")
        local cluster_region=$(yq eval ".clusters.$cluster.region" "$CLUSTERS_FILE")
        local cluster_envs=$(yq eval ".clusters.$cluster.environments | join(\",\")" "$CLUSTERS_FILE")
        
        printf "%-20s %-10s %-15s %-15s %-10s\n" "$cluster" "$cluster_type" "$cluster_provider" "$cluster_region" "$cluster_envs"
    done <<< "$clusters"
    
    echo ""
}

# Function to show cluster details
show_cluster_details() {
    local cluster=$1
    
    print_header "Cluster Details: $cluster"
    
    local cluster_config=$(yq eval ".clusters.$cluster" "$CLUSTERS_FILE")
    
    if [[ "$cluster_config" == "null" ]]; then
        print_error "Cluster '$cluster' not found"
        exit 1
    fi
    
    echo "Configuration:"
    echo "$cluster_config" | yq eval '.' - | sed 's/^/  /'
    
    echo ""
    print_info "Current Context:"
    kubectl config current-context 2>/dev/null || print_warning "No current context"
    
    echo ""
    print_info "Available Contexts:"
    kubectl config get-contexts -o name | sed 's/^/  /'
}

# Function to switch cluster context
switch_cluster() {
    local cluster=$1
    
    print_header "Switching to Cluster: $cluster"
    
    local cluster_context=$(yq eval ".clusters.$cluster.context" "$CLUSTERS_FILE")
    
    if [[ "$cluster_context" == "null" ]]; then
        print_error "Cluster context not found for '$cluster'"
        exit 1
    fi
    
    # Check if context exists
    if ! kubectl config get-contexts "$cluster_context" >/dev/null 2>&1; then
        print_error "Kubernetes context '$cluster_context' not found"
        print_info "Available contexts:"
        kubectl config get-contexts -o name | sed 's/^/  /'
        exit 1
    fi
    
    # Switch context
    kubectl config use-context "$cluster_context"
    print_success "Switched to context: $cluster_context"
    
    # Verify cluster connectivity
    if kubectl cluster-info >/dev/null 2>&1; then
        print_success "Cluster connectivity verified"
        
        # Show cluster info
        echo ""
        print_info "Cluster Information:"
        kubectl cluster-info | sed 's/^/  /'
        
        # Show nodes
        echo ""
        print_info "Nodes:"
        kubectl get nodes -o wide | sed 's/^/  /'
    else
        print_error "Cannot connect to cluster"
        exit 1
    fi
}

# Function to test cluster connectivity
test_cluster() {
    local cluster=$1
    
    print_header "Testing Cluster Connectivity: $cluster"
    
    local cluster_context=$(yq eval ".clusters.$cluster.context" "$CLUSTERS_FILE")
    
    if [[ "$cluster_context" == "null" ]]; then
        print_error "Cluster context not found for '$cluster'"
        exit 1
    fi
    
    # Save current context
    local current_context=$(kubectl config current-context 2>/dev/null || echo "")
    
    # Switch to target context
    if kubectl config get-contexts "$cluster_context" >/dev/null 2>&1; then
        kubectl config use-context "$cluster_context"
        
        # Test connectivity
        if kubectl cluster-info >/dev/null 2>&1; then
            print_success "✅ Cluster connectivity: OK"
            
            # Test API server
            local api_server=$(kubectl config view --minify -o jsonpath='{.clusters[?(@.name == "'"$cluster_context"'")].cluster.server}')
            print_info "API Server: $api_server"
            
            # Test node connectivity
            local node_count=$(kubectl get nodes --no-headers | wc -l)
            print_info "Nodes: $node_count"
            
            # Test namespace creation
            local test_namespace="camp-test-$(date +%s)"
            if kubectl create namespace "$test_namespace" --dry-run=client >/dev/null 2>&1; then
                print_success "✅ Namespace creation: OK"
            else
                print_error "❌ Namespace creation: FAILED"
            fi
            
            # Test pod creation
            if kubectl run test-pod --image=busybox --command -- sleep 1 --dry-run=client -o yaml >/dev/null 2>&1; then
                print_success "✅ Pod creation: OK"
            else
                print_error "❌ Pod creation: FAILED"
            fi
            
            # Test service creation
            if kubectl create service clusterip test-service --tcp=80:80 --dry-run=client -o yaml >/dev/null 2>&1; then
                print_success "✅ Service creation: OK"
            else
                print_error "❌ Service creation: FAILED"
            fi
            
            # Test storage
            local storage_classes=$(kubectl get storageclass --no-headers | wc -l)
            print_info "Storage Classes: $storage_classes"
            if [[ $storage_classes -gt 0 ]]; then
                print_success "✅ Storage: OK"
            else
                print_warning "⚠️  No storage classes found"
            fi
            
            # Test ingress
            local ingress_classes=$(kubectl get ingressclass --no-headers 2>/dev/null | wc -l)
            print_info "Ingress Classes: $ingress_classes"
            if [[ $ingress_classes -gt 0 ]]; then
                print_success "✅ Ingress: OK"
            else
                print_warning "⚠️  No ingress classes found"
            fi
            
        else
            print_error "❌ Cluster connectivity: FAILED"
        fi
        
        # Restore original context
        if [[ -n "$current_context" ]]; then
            kubectl config use-context "$current_context"
        fi
    else
        print_error "❌ Context '$cluster_context' not found"
    fi
}

# Function to validate cluster configuration
validate_cluster_config() {
    print_header "Validating Cluster Configuration"
    
    local clusters=$(yq eval '.clusters | keys | .[]' "$CLUSTERS_FILE")
    local errors=0
    
    while IFS= read -r cluster; do
        echo "Validating cluster: $cluster"
        
        # Check required fields
        local required_fields=("type" "provider" "region" "context" "namespace" "environments")
        for field in "${required_fields[@]}"; do
            local value=$(yq eval ".clusters.$cluster.$field" "$CLUSTERS_FILE")
            if [[ "$value" == "null" ]]; then
                print_error "  Missing required field: $field"
                ((errors++))
            fi
        done
        
        # Check if context exists
        local context=$(yq eval ".clusters.$cluster.context" "$CLUSTERS_FILE")
        if ! kubectl config get-contexts "$context" >/dev/null 2>&1; then
            print_warning "  Context '$context' not found in kubeconfig"
        fi
        
        # Check environment files
        local environments=$(yq eval ".clusters.$cluster.environments[]" "$CLUSTERS_FILE")
        while IFS= read -r env; do
            local env_file="$PROJECT_ROOT/environments/values-${env}.yaml"
            if [[ ! -f "$env_file" ]]; then
                print_error "  Environment file not found: $env_file"
                ((errors++))
            fi
        done <<< "$environments"
        
        if [[ $errors -eq 0 ]]; then
            print_success "  ✅ Cluster configuration is valid"
        else
            print_error "  ❌ Cluster configuration has $errors errors"
        fi
        
        echo ""
    done <<< "$clusters"
    
    if [[ $errors -eq 0 ]]; then
        print_success "All cluster configurations are valid"
    else
        print_error "Found $errors configuration errors"
        exit 1
    fi
}

# Function to show cluster status
show_cluster_status() {
    local cluster=$1
    
    print_header "Cluster Status: $cluster"
    
    local cluster_context=$(yq eval ".clusters.$cluster.context" "$CLUSTERS_FILE")
    
    if [[ "$cluster_context" == "null" ]]; then
        print_error "Cluster context not found for '$cluster'"
        exit 1
    fi
    
    # Save current context
    local current_context=$(kubectl config current-context 2>/dev/null || echo "")
    
    # Switch to target context
    if kubectl config get-contexts "$cluster_context" >/dev/null 2>&1; then
        kubectl config use-context "$cluster_context"
        
        # Show cluster status
        print_info "Cluster Information:"
        kubectl cluster-info | sed 's/^/  /'
        
        echo ""
        print_info "Resource Usage:"
        echo "  Nodes:"
        kubectl top nodes 2>/dev/null | sed 's/^/    /' || print_warning "    Metrics server not available"
        
        echo "  Pods:"
        kubectl top pods --all-namespaces 2>/dev/null | head -10 | sed 's/^/    /' || print_warning "    Metrics server not available"
        
        echo ""
        print_info "Namespaces:"
        kubectl get namespaces | sed 's/^/  /'
        
        echo ""
        print_info "Storage Classes:"
        kubectl get storageclass | sed 's/^/  /'
        
        echo ""
        print_info "Ingress Classes:"
        kubectl get ingressclass 2>/dev/null | sed 's/^/  /' || print_warning "  No ingress classes found"
        
        # Restore original context
        if [[ -n "$current_context" ]]; then
            kubectl config use-context "$current_context"
        fi
    else
        print_error "Context '$cluster_context' not found"
    fi
}

# Function to show help
show_help() {
    echo "Cluster Management Script for CAMP Platform"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  list                    List all available clusters"
    echo "  details CLUSTER         Show detailed information about a cluster"
    echo "  switch CLUSTER          Switch to a specific cluster context"
    echo "  test CLUSTER            Test connectivity to a cluster"
    echo "  status CLUSTER          Show current status of a cluster"
    echo "  validate                Validate all cluster configurations"
    echo "  help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 list                 List all clusters"
    echo "  $0 details aks-prod     Show details of production cluster"
    echo "  $0 switch local-dev      Switch to local development cluster"
    echo "  $0 test aks-staging     Test staging cluster connectivity"
    echo "  $0 status aks-prod       Show production cluster status"
    echo "  $0 validate             Validate all configurations"
}

# Main function
main() {
    # Check if clusters file exists
    if [[ ! -f "$CLUSTERS_FILE" ]]; then
        print_error "Cluster configuration file not found: $CLUSTERS_FILE"
        exit 1
    fi
    
    # Parse command
    case "${1:-help}" in
        list)
            check_prerequisites
            list_clusters
            ;;
        details)
            if [[ -z "$2" ]]; then
                print_error "Cluster name is required"
                show_help
                exit 1
            fi
            check_prerequisites
            show_cluster_details "$2"
            ;;
        switch)
            if [[ -z "$2" ]]; then
                print_error "Cluster name is required"
                show_help
                exit 1
            fi
            check_prerequisites
            switch_cluster "$2"
            ;;
        test)
            if [[ -z "$2" ]]; then
                print_error "Cluster name is required"
                show_help
                exit 1
            fi
            check_prerequisites
            test_cluster "$2"
            ;;
        status)
            if [[ -z "$2" ]]; then
                print_error "Cluster name is required"
                show_help
                exit 1
            fi
            check_prerequisites
            show_cluster_status "$2"
            ;;
        validate)
            check_prerequisites
            validate_cluster_config
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
