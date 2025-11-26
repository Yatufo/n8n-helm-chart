#!/bin/bash
# Script to automatically bump Helm chart version
# Usage: ./scripts/bump-version.sh [patch|minor|major] [chart-path]

set -euo pipefail

# Default to patch version bump
BUMP_TYPE="${1:-patch}"
CHART_PATH="${2:-charts/n8n}"
CHART_YAML="${CHART_PATH}/Chart.yaml"

if [[ ! -f "$CHART_YAML" ]]; then
  echo "Error: Chart.yaml not found at $CHART_YAML"
  exit 1
fi

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(patch|minor|major)$ ]]; then
  echo "Error: Bump type must be patch, minor, or major"
  exit 1
fi

# Extract current version
CURRENT_VERSION=$(grep '^version:' "$CHART_YAML" | sed 's/version: *//' | tr -d '"' | tr -d "'" | xargs)

if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Error: Could not extract current version from $CHART_YAML"
  exit 1
fi

echo "Current version: $CURRENT_VERSION" >&2

# Parse version components
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Bump version based on type
case "$BUMP_TYPE" in
  patch)
    PATCH=$((PATCH + 1))
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo "New version: $NEW_VERSION" >&2

# Update Chart.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s/^version:.*/version: ${NEW_VERSION}/" "$CHART_YAML"
else
  # Linux
  sed -i "s/^version:.*/version: ${NEW_VERSION}/" "$CHART_YAML"
fi

echo "✅ Version bumped from $CURRENT_VERSION to $NEW_VERSION in $CHART_YAML" >&2
# Output only the version number to stdout for easy capture
echo "$NEW_VERSION"

