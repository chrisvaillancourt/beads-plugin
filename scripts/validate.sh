#!/usr/bin/env bash
set -euo pipefail

# Validate plugin structure and content
#
# Checks:
#   1. plugin.json is valid JSON with required fields
#   2. SKILL.md exists and has valid front matter
#   3. All reference files exist
#   4. Links in SKILL.md to references are valid
#
# Exit codes:
#   0 - All validations passed
#   1 - Validation failed

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

log_pass() { echo -e "${GREEN}✓${NC} $1"; }
log_fail() { echo -e "${RED}✗${NC} $1"; ((ERRORS++)); }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }
log_info() { echo -e "  $1"; }

echo "========================================="
echo "Validating beads-skill plugin"
echo "========================================="
echo ""

# -----------------------------------------------------------------------------
# 1. Validate plugin.json
# -----------------------------------------------------------------------------
echo "Checking plugin.json..."

PLUGIN_JSON="$PROJECT_ROOT/.claude-plugin/plugin.json"

if [ ! -f "$PLUGIN_JSON" ]; then
    log_fail "plugin.json not found at $PLUGIN_JSON"
else
    # Check valid JSON
    if ! jq empty "$PLUGIN_JSON" 2>/dev/null; then
        log_fail "plugin.json is not valid JSON"
    else
        log_pass "plugin.json is valid JSON"

        # Check required fields
        for field in name version description; do
            value=$(jq -r ".$field // empty" "$PLUGIN_JSON")
            if [ -z "$value" ]; then
                log_fail "plugin.json missing required field: $field"
            else
                log_pass "plugin.json has $field: $value"
            fi
        done

        # Check upstream tracking
        upstream_version=$(jq -r '.upstream.version // empty' "$PLUGIN_JSON")
        if [ -z "$upstream_version" ]; then
            log_warn "plugin.json missing upstream.version (can't track drift)"
        else
            log_pass "plugin.json tracks upstream version: $upstream_version"
        fi
    fi
fi

# -----------------------------------------------------------------------------
# 2. Validate SKILL.md
# -----------------------------------------------------------------------------
echo ""
echo "Checking SKILL.md..."

SKILL_MD="$PROJECT_ROOT/skills/beads/SKILL.md"

if [ ! -f "$SKILL_MD" ]; then
    log_fail "SKILL.md not found at $SKILL_MD"
else
    log_pass "SKILL.md exists"

    # Check file has content
    line_count=$(wc -l < "$SKILL_MD" | tr -d ' ')
    if [ "$line_count" -lt 100 ]; then
        log_warn "SKILL.md seems short ($line_count lines)"
    else
        log_pass "SKILL.md has $line_count lines"
    fi

    # Check front matter exists
    if head -1 "$SKILL_MD" | grep -q "^---"; then
        log_pass "SKILL.md has front matter"

        # Extract and validate front matter (between first and second ---)
        front_matter=$(awk '/^---$/{if(++n==2)exit}n==1' "$SKILL_MD")

        # Check for name field
        if echo "$front_matter" | grep -q "^name:"; then
            skill_name=$(echo "$front_matter" | grep "^name:" | sed 's/name:[[:space:]]*//')
            log_pass "SKILL.md has name: $skill_name"
        else
            log_fail "SKILL.md front matter missing 'name' field"
        fi

        # Check for description field
        if echo "$front_matter" | grep -q "^description:"; then
            log_pass "SKILL.md has description"
        else
            log_fail "SKILL.md front matter missing 'description' field"
        fi
    else
        log_fail "SKILL.md missing front matter (should start with ---)"
    fi
fi

# -----------------------------------------------------------------------------
# 3. Validate reference files
# -----------------------------------------------------------------------------
echo ""
echo "Checking reference files..."

REFS_DIR="$PROJECT_ROOT/skills/beads/references"

if [ ! -d "$REFS_DIR" ]; then
    log_fail "References directory not found at $REFS_DIR"
else
    ref_count=$(find "$REFS_DIR" -name "*.md" | wc -l | tr -d ' ')
    if [ "$ref_count" -eq 0 ]; then
        log_fail "No reference files found in $REFS_DIR"
    else
        log_pass "Found $ref_count reference files"

        # List each reference file
        for ref_file in "$REFS_DIR"/*.md; do
            [ -e "$ref_file" ] || continue
            filename=$(basename "$ref_file")
            file_lines=$(wc -l < "$ref_file" | tr -d ' ')
            if [ "$file_lines" -lt 10 ]; then
                log_warn "$filename seems short ($file_lines lines)"
            else
                log_pass "$filename ($file_lines lines)"
            fi
        done
    fi
fi

# -----------------------------------------------------------------------------
# 4. Validate internal links
# -----------------------------------------------------------------------------
echo ""
echo "Checking internal links in SKILL.md..."

if [ -f "$SKILL_MD" ]; then
    # Extract markdown links to references/ - capture just the path
    # Pattern: [text](references/FILE.md) or [text](references/FILE.md#anchor)
    links=$(grep -oE '\(references/[^)]+\)' "$SKILL_MD" 2>/dev/null | sed 's/[()]//g' | sed 's/#.*//' | sort -u || true)

    if [ -z "$links" ]; then
        log_warn "No links to references/ found in SKILL.md"
    else
        link_count=$(echo "$links" | wc -l | tr -d ' ')
        log_info "Found $link_count unique links to references/"

        # Check each link
        broken=0
        while IFS= read -r path; do
            [ -z "$path" ] && continue
            full_path="$PROJECT_ROOT/skills/beads/$path"

            if [ ! -f "$full_path" ]; then
                log_fail "Broken link: $path"
                ((broken++))
            fi
        done <<< "$links"

        if [ "$broken" -eq 0 ]; then
            log_pass "All internal links valid"
        fi
    fi
fi

# -----------------------------------------------------------------------------
# 5. Check for required files
# -----------------------------------------------------------------------------
echo ""
echo "Checking required project files..."

required_files=(
    "README.md"
    "AGENTS.md"
    "CLAUDE.md"
    "scripts/sync-upstream.sh"
)

for file in "${required_files[@]}"; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        log_pass "$file exists"
    else
        log_fail "$file missing"
    fi
done

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "========================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}Validation passed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}$WARNINGS warning(s)${NC}"
    fi
    exit 0
else
    echo -e "${RED}Validation failed: $ERRORS error(s)${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}$WARNINGS warning(s)${NC}"
    fi
    exit 1
fi
