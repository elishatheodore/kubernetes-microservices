#!/bin/bash

# Make all scripts executable
# This script ensures all deployment and management scripts have proper permissions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔧 Making scripts executable..."

# Make all shell scripts executable
find "$PROJECT_ROOT" -name "*.sh" -type f -exec chmod +x {} \;

echo -e "${GREEN}✅ All scripts are now executable${NC}"

# List the main scripts
echo ""
echo "📋 Main deployment scripts:"
echo "  - scripts/deploy.sh           # Multi-cluster deployment"
echo "  - scripts/cluster-manager.sh  # Cluster management"
echo "  - scripts/make-executable.sh  # This script"
echo "  - helm/deploy-helm.sh         # Helm deployment"
echo "  - k8s/deploy.sh               # AKS deployment"
echo "  - k8s/cleanup.sh              # AKS cleanup"

echo ""
echo -e "${YELLOW}🚀 You can now run the deployment scripts:${NC}"
echo "  ./scripts/deploy.sh -c local-dev -e dev"
echo "  ./scripts/cluster-manager.sh list"
