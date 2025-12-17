# Agent Instructions

## Project Overview

This is a **thin wrapper** around the [official beads skill](https://github.com/steveyegge/beads/tree/main/skills/beads) for Claude Code users who want the skill without MCP overhead.

## Repository Structure

```
.claude-plugin/
  plugin.json           # Plugin metadata with upstream version tracking
skills/
  beads/
    SKILL.md            # Official skill (mirrored from upstream)
    references/         # Reference docs (mirrored from upstream)
scripts/
  sync-upstream.sh      # Script to update from upstream
```

## Maintenance

This repo mirrors content from `steveyegge/beads/skills/beads/`. When beads releases updates:

```bash
./scripts/sync-upstream.sh
```

This downloads the latest skill and reference files, then updates the version in plugin.json.

## What NOT to Do

- Don't modify `skills/beads/SKILL.md` directly - it will be overwritten on sync
- Don't add custom content to `skills/beads/references/` - same reason

## Git Workflow

```bash
# After syncing upstream
git add .
git commit -m "chore: sync with beads v0.X.Y"
git push
```
