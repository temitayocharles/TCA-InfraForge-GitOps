#!/bin/bash

# 🚀 TCA-InfraForge Quick Deploy Script
# Usage: ./scripts/quick-deploy.sh [duration_minutes] [mode]
#
# This script triggers GitHub Actions deployment with your preferred settings.

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
DURATION="${1:-0}"  # Default to permanent
MODE="${2:-development}"

echo -e "${BLUE}🚀 TCA-InfraForge Quick Deploy${NC}"
echo "==============================="
echo ""
echo "🎯 Configuration:"
echo "  Duration: ${DURATION} minutes $([ "$DURATION" = "0" ] && echo "(permanent)" || echo "")"
echo "  Mode: $MODE"
echo ""

# Check if GitHub CLI is available
if ! command -v gh &> /dev/null; then
  echo -e "${YELLOW}💡 GitHub CLI not found. Manual deployment steps:${NC}"
  echo ""
  echo "1. Go to: https://github.com/$(git config remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
  echo "2. Click: '🚀 TCA-InfraForge Development Platform'"
  echo "3. Click: 'Run workflow'"
  echo "4. Set duration to: $DURATION minutes"
  echo "5. Set mode to: $MODE"
  echo "6. Click: 'Run workflow'"
  echo ""
  exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Not in a git repository"
  exit 1
fi

echo -e "${GREEN}🚀 Triggering GitHub Actions deployment...${NC}"

# Trigger the workflow
gh workflow run "deploy-argocd.yml" \
  --field duration_minutes="$DURATION" \
  --field platform_mode="$MODE"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Deployment triggered successfully!${NC}"
  echo ""
  echo "📊 Monitor progress:"
  echo "  gh workflow list"
  echo "  gh run watch"
  echo ""
  echo "🌐 Or visit: https://github.com/$(git config remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
else
  echo "❌ Failed to trigger deployment"
  exit 1
fi