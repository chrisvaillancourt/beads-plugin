#!/usr/bin/env bash
set -euo pipefail

# Sync beads skill from upstream steveyegge/beads repo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$PROJECT_ROOT/skills/beads"
REFS_DIR="$SKILL_DIR/references"

UPSTREAM_BASE="https://raw.githubusercontent.com/steveyegge/beads/main/skills/beads"

echo "Syncing beads skill from upstream..."

# Get current beads version
VERSION=$(bd version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
echo "Local bd version: $VERSION"

# Create directories if needed
mkdir -p "$REFS_DIR"

# Download main skill file
echo "Downloading SKILL.md..."
curl -sL "$UPSTREAM_BASE/SKILL.md" -o "$SKILL_DIR/SKILL.md"

# Download reference files
REFS=(
  "BOUNDARIES.md"
  "CLI_REFERENCE.md"
  "DEPENDENCIES.md"
  "ISSUE_CREATION.md"
  "RESUMABILITY.md"
  "STATIC_DATA.md"
  "WORKFLOWS.md"
)

echo "Downloading reference files..."
for ref in "${REFS[@]}"; do
  echo "  - $ref"
  curl -sL "$UPSTREAM_BASE/references/$ref" -o "$REFS_DIR/$ref"
done

# Update version in plugin.json
if command -v jq &> /dev/null; then
  echo "Updating plugin.json version to $VERSION..."
  tmp=$(mktemp)
  jq --arg v "$VERSION" '.version = $v | .upstream.version = $v' "$PROJECT_ROOT/.claude-plugin/plugin.json" > "$tmp"
  mv "$tmp" "$PROJECT_ROOT/.claude-plugin/plugin.json"
else
  echo "Warning: jq not installed, skipping plugin.json version update"
fi

echo ""
echo "Sync complete!"
echo "  SKILL.md: $(wc -l < "$SKILL_DIR/SKILL.md") lines"
echo "  References: ${#REFS[@]} files"
echo ""
echo "Next steps:"
echo "  git add ."
echo "  git commit -m 'chore: sync with beads v$VERSION'"
echo "  git push"
