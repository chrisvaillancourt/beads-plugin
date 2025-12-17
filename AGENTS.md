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

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
