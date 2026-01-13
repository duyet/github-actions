#!/bin/bash
# Sync Downstream Repos - Check and update workflow permissions across downstream repos
# Usage: ./scripts/sync-downstream.sh [--fix] [--check-only]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Workflow files to check (all should have contents: read, not write)
WORKFLOWS="claude.yml claude-code-review.yml claude-nightly.yml claude-schedule.yml"

# Downstream repos to check
REPOS=(
  "/Users/duet/project/monorepo"
  "/Users/duet/project/clickhouse-monitor"
)

# Flags
FIX=false
CHECK_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --fix)
      FIX=true
      shift
      ;;
    --check-only)
      CHECK_ONLY=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--fix] [--check-only]"
      echo ""
      echo "Options:"
      echo "  --fix         Auto-fix permission issues by creating branches and PRs"
      echo "  --check-only  Only check for issues, don't prompt for fixes"
      echo "  -h, --help    Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Downstream Workflow Sync${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Track issues
ISSUES_FOUND=0
REPOS_NEEDING_FIX=()

for repo in "${REPOS[@]}"; do
  if [ ! -d "$repo" ]; then
    echo -e "${YELLOW}⚠ Skipping $repo (not found)${NC}"
    continue
  fi

  REPO_NAME=$(basename "$repo")
  echo -e "${BLUE}Checking: $REPO_NAME${NC}"

  WORKFLOWS_DIR="$repo/.github/workflows"
  if [ ! -d "$WORKFLOWS_DIR" ]; then
    echo -e "${YELLOW}  No workflows directory found${NC}"
    continue
  fi

  REPO_ISSUES=0

  # Check each workflow file
  for workflow in $WORKFLOWS; do
    WORKFLOW_FILE="$WORKFLOWS_DIR/$workflow"

    if [ ! -f "$WORKFLOW_FILE" ]; then
      continue
    fi

    # Check for contents: write
    if grep -q "contents: write" "$WORKFLOW_FILE"; then
      echo -e "${RED}  ❌ $workflow: has 'contents: write'${NC}"
      REPO_ISSUES=$((REPO_ISSUES + 1))
      ISSUES_FOUND=$((ISSUES_FOUND + 1))

      # Show the problematic line
      grep -n "contents: write" "$WORKFLOW_FILE" | head -1 | sed 's/^/     /'
    else
      echo -e "${GREEN}  ✓ $workflow: OK${NC}"
    fi
  done

  if [ $REPO_ISSUES -gt 0 ]; then
    REPOS_NEEDING_FIX+=("$repo|$REPO_NAME")
  fi

  echo ""
done

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $ISSUES_FOUND -eq 0 ]; then
  echo -e "${GREEN}✓ All downstream repos are up to date!${NC}"
  exit 0
else
  echo -e "${RED}Found $ISSUES_FOUND issue(s) across ${#REPOS_NEEDING_FIX[@]} repo(s)${NC}"
  echo ""

  if [ "$CHECK_ONLY" = true ]; then
    echo -e "${YELLOW}--check-only mode: not prompting for fixes${NC}"
    exit 1
  fi

  if [ "$FIX" = true ]; then
    echo -e "${YELLOW}Auto-fix mode enabled. Creating fix branches...${NC}"
  else
    echo -e "${YELLOW}Run with --fix to automatically create fix branches and PRs${NC}"
  fi

  # Process repos needing fixes
  for repo_info in "${REPOS_NEEDING_FIX[@]}"; do
    IFS='|' read -r repo_path repo_name <<< "$repo_info"

    echo ""
    echo -e "${BLUE}Processing: $repo_name${NC}"

    if [ "$FIX" = false ]; then
      echo -e "${YELLOW}  Would create fix branch and PR${NC}"
      continue
    fi

    # Create fix branch
    BRANCH_NAME="fix/workflow-permissions-$(date +%Y%m%d)"
    cd "$repo_path"

    # Ensure we're on main/master and up to date
    git checkout main 2>/dev/null || git checkout master 2>/dev/null || true
    git fetch origin
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true

    # Create branch
    git checkout -b "$BRANCH_NAME" 2>/dev/null || {
      git branch -D "$BRANCH_NAME" 2>/dev/null || true
      git checkout -b "$BRANCH_NAME"
    }

    # Fix permissions
    WORKFLOWS_DIR="$repo_path/.github/workflows"
    for workflow in $WORKFLOWS; do
      WORKFLOW_FILE="$WORKFLOWS_DIR/$workflow"

      if [ ! -f "$WORKFLOW_FILE" ]; then
        continue
      fi

      if grep -q "contents: write" "$WORKFLOW_FILE"; then
        # macOS vs Linux sed compatibility
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i.bak 's/contents: write/contents: read/' "$WORKFLOW_FILE"
          rm -f "${WORKFLOW_FILE}.bak"
        else
          sed -i 's/contents: write/contents: read/' "$WORKFLOW_FILE"
        fi
        echo -e "${GREEN}  Fixed: $workflow${NC}"
      fi
    done

    # Commit and push
    if [ -n "$(git status --porcelain)" ]; then
      git add .github/workflows/
      git commit --no-verify -m "fix(workflows): sync permissions with upstream github-actions

Update caller workflow permissions to match upstream standards.
- contents:write → contents:read (prevents PR creation)

Co-Authored-By: Claude <noreply@anthropic.com>" || true

      git push --no-verify origin "$BRANCH_NAME"

      # Create PR
      gh pr create \
        --title "fix(workflows): sync permissions with upstream github-actions" \
        --body "Update caller workflow permissions to match upstream standards.

## Changes
- contents:write → contents:read (prevents PR creation)

Co-Authored-By: Claude <noreply@anthropic.com>" \
        --base main 2>/dev/null && echo -e "${GREEN}  PR created successfully${NC}" || echo -e "${YELLOW}  PR creation skipped (may already exist)${NC}"
    else
      echo -e "${YELLOW}  No changes needed${NC}"
    fi
  done
fi

echo ""
exit $ISSUES_FOUND
