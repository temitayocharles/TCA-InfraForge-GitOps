#!/bin/bash

# 🧹 TCA-InfraForge Cluster Cleanup Script
# Usage: ./scripts/cleanup-cluster.sh [--force]
#
# This script safely destroys your permanent cluster when you're done with it.

set -e

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default cluster name (matches GitHub Actions)
CLUSTER_NAME="${CLUSTER_NAME:-tca-infraforge-demo}"
FORCE_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --force)
      FORCE_MODE=true
      shift
      ;;
    --help)
      echo "🧹 TCA-InfraForge Cluster Cleanup Script"
      echo ""
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --force     Skip confirmation prompts"
      echo "  --help      Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                    # Interactive cleanup"
      echo "  $0 --force          # Force cleanup without prompts"
      exit 0
      ;;
    *)
      echo "❌ Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}🧹 TCA-InfraForge Cluster Cleanup${NC}"
echo "=================================="
echo ""

# Check if we're in the right directory
if [[ ! -f "terraform/main.tf" ]]; then
  echo -e "${RED}❌ Error: terraform/main.tf not found${NC}"
  echo "Please run this script from the TCA-InfraForge root directory"
  exit 1
fi

# Check if cluster exists
echo -e "${BLUE}🔍 Checking cluster status...${NC}"
if ! docker ps --format "table {{.Names}}" | grep -q "$CLUSTER_NAME"; then
  echo -e "${YELLOW}⚠️  No cluster named '$CLUSTER_NAME' found${NC}"
  echo "The cluster might already be destroyed or running with a different name."
  echo ""
  echo "🐳 Current Docker containers:"
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(kind|k8s)" || echo "  No Kubernetes containers found"
  
  if [[ "$FORCE_MODE" == false ]]; then
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${YELLOW}🛑 Cleanup cancelled${NC}"
      exit 0
    fi
  fi
fi

# Show what will be cleaned up
echo -e "${YELLOW}🎯 Cleanup Plan:${NC}"
echo "  • Destroy Kind cluster: $CLUSTER_NAME"
echo "  • Clean up Docker containers and networks"
echo "  • Remove temporary Terraform state"
echo "  • Kill any running port-forward processes"
echo ""

# Confirmation (unless --force)
if [[ "$FORCE_MODE" == false ]]; then
  echo -e "${RED}⚠️  This will permanently destroy your cluster!${NC}"
  echo "   All running applications and data will be lost."
  echo ""
  read -p "Are you sure you want to continue? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🛑 Cleanup cancelled${NC}"
    exit 0
  fi
  echo ""
fi

echo -e "${GREEN}🚀 Starting cleanup...${NC}"
echo ""

# Kill any port-forwarding processes
echo -e "${BLUE}🔌 Stopping port-forward processes...${NC}"
pkill -f "kubectl.*port-forward" || echo "  No port-forward processes found"

# Change to terraform directory
cd terraform

# Initialize Terraform (in case it's not initialized)
echo -e "${BLUE}🏗️  Initializing Terraform...${NC}"
terraform init -input=false

# Destroy infrastructure with Terraform
echo -e "${BLUE}💥 Destroying infrastructure...${NC}"
if terraform destroy -auto-approve -var="cluster_name=$CLUSTER_NAME"; then
  echo -e "${GREEN}✅ Terraform destroy completed successfully${NC}"
else
  echo -e "${YELLOW}⚠️  Terraform destroy had issues, continuing with manual cleanup...${NC}"
fi

# Manual cleanup in case Terraform missed something
echo -e "${BLUE}🧹 Manual cleanup of Docker resources...${NC}"

# Delete the Kind cluster directly
if command -v kind &> /dev/null; then
  echo "  Deleting Kind cluster: $CLUSTER_NAME"
  kind delete cluster --name "$CLUSTER_NAME" 2>/dev/null || echo "    Cluster not found or already deleted"
else
  echo "  Kind not found, skipping cluster deletion"
fi

# Clean up any remaining containers
echo "  Cleaning up Docker containers..."
docker ps -a --format "table {{.Names}}" | grep -E "(kind|$CLUSTER_NAME)" | while read -r container; do
  if [[ "$container" != "NAMES" ]]; then
    echo "    Removing container: $container"
    docker rm -f "$container" 2>/dev/null || true
  fi
done

# Clean up networks
echo "  Cleaning up Docker networks..."
docker network ls --format "table {{.Name}}" | grep -E "(kind|$CLUSTER_NAME)" | while read -r network; do
  if [[ "$network" != "NAME" ]]; then
    echo "    Removing network: $network"
    docker network rm "$network" 2>/dev/null || true
  fi
done

# Clean up volumes
echo "  Cleaning up Docker volumes..."
docker volume ls --format "table {{.Name}}" | grep -E "(kind|$CLUSTER_NAME)" | while read -r volume; do
  if [[ "$volume" != "NAME" ]]; then
    echo "    Removing volume: $volume"
    docker volume rm "$volume" 2>/dev/null || true
  fi
done

# Clean up Terraform state files (optional)
echo -e "${BLUE}📁 Cleaning up temporary files...${NC}"
rm -f terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
rm -rf .terraform/

echo ""
echo -e "${GREEN}🎉 Cleanup completed successfully!${NC}"
echo ""
echo -e "${BLUE}📊 Verification:${NC}"
echo "  Remaining Docker containers:"
if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(kind|$CLUSTER_NAME)"; then
  echo -e "${YELLOW}    ⚠️  Some containers might still be running${NC}"
else
  echo -e "${GREEN}    ✅ No related containers found${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Ready for next deployment!${NC}"
echo "  To redeploy: Go to GitHub Actions → Run '🚀 TCA-InfraForge Development Platform'"
echo ""
echo -e "${YELLOW}💡 Pro Tip:${NC} Your Git repository is unchanged - all configurations are preserved!"