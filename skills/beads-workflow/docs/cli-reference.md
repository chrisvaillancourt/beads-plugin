# Beads CLI Reference

Complete command reference for the `bd` CLI. See [SKILL.md](../SKILL.md) for workflow patterns.

## Global Flags

These flags work with any command:

| Flag | Purpose |
|------|---------|
| `--json` | Output JSON (required for agent operations) |
| `--no-daemon` | Disable daemon for this command |
| `--no-auto-flush` | Skip automatic export to JSONL |
| `--no-auto-import` | Skip automatic import from JSONL |
| `--sandbox` | Disable daemon, auto-flush, and auto-import |
| `--allow-stale` | Bypass staleness checks |
| `--db /path` | Use specific database file |
| `--actor <name>` | Set actor name for operations |

## Discovery Commands

### Find Ready Work

```bash
bd ready --json                    # Unblocked issues
```

### Find Stale Issues

```bash
bd stale --days 30 --json          # Not updated in 30 days
bd stale --days 90 --status in_progress --json
bd stale --limit 20 --json
```

### System Info

```bash
bd info --json                     # Database path, daemon status, config
bd info --schema --json            # Database schema version
```

### List Issues

```bash
bd list --json                     # All issues
bd list --status open --json       # By status
bd list --priority 1 --json        # By priority
bd list --type bug --json          # By type
bd list --assignee alice --json    # By assignee
```

#### Filtering Options

**Status/Priority/Type:**
```bash
bd list --status open --priority 1 --json
bd list --priority-min 0 --priority-max 1 --json
```

**Labels (AND - all required):**
```bash
bd list --label bug,critical --json
```

**Labels (OR - any match):**
```bash
bd list --label-any frontend,backend --json
```

**Text Search:**
```bash
bd list --title "auth" --json           # Exact title
bd list --title-contains "auth" --json  # Title contains
bd list --desc-contains "implement" --json
bd list --notes-contains "TODO" --json
```

**Date Ranges (YYYY-MM-DD or RFC3339):**
```bash
bd list --created-after 2024-01-01 --json
bd list --created-before 2024-12-31 --json
bd list --updated-after 2024-06-01 --json
bd list --closed-after 2024-01-01 --json
```

**Empty/Null Checks:**
```bash
bd list --empty-description --json
bd list --no-assignee --json
bd list --no-labels --json
```

**By ID:**
```bash
bd list --id bd-123,bd-456 --json
```

### Show Issue Details

```bash
bd show <id> --json
bd show <id1> <id2> --json         # Multiple issues
```

## Issue Management

### Create Issues

```bash
bd create "Title" --json
bd create "Title" -t bug -p 1 --json
bd create "Title" -t task -d "Description" --json
bd create "Title" -l backend,urgent --json
bd create "Title" --deps discovered-from:<parent-id> --json
bd create "Title" --id custom-100 --json   # Explicit ID
bd create -f feature-plan.md --json        # From file
```

**Type flags:** `-t` or `--type`
- `bug` - Defects
- `feature` - New functionality
- `task` - General work
- `epic` - Large features with subtasks
- `chore` - Maintenance

**Priority flags:** `-p` or `--priority`
- `0` - Critical
- `1` - High
- `2` - Medium (default)
- `3` - Low
- `4` - Backlog

**Other flags:**
- `-d` or `--description` - Issue description
- `-l` or `--labels` - Comma-separated labels
- `--deps` - Dependencies (e.g., `discovered-from:<id>`)

### Update Issues

```bash
bd update <id> --status in_progress --json
bd update <id> --priority 1 --json
bd update <id> --assignee alice --json
bd update <id1> <id2> --status in_progress --json   # Batch
```

**Status values:** `open`, `in_progress`, `blocked`, `closed`

### Close/Reopen Issues

```bash
bd close <id> --json
bd close <id> --reason "Implemented and tested" --json
bd close <id1> <id2> <id3> --reason "Batch completion" --json
bd reopen <id> --reason "Reopening for fixes" --json
```

### Edit Issues (Interactive - Human Only)

```bash
bd edit <id>              # Full edit in $EDITOR
bd edit <id> --title      # Edit title only
bd edit <id> --design     # Edit design field
bd edit <id> --notes      # Edit notes
bd edit <id> --acceptance # Edit acceptance criteria
```

Note: `bd edit` is intentionally not available via MCP server.

## Dependencies

### Add Dependencies

```bash
bd dep add <issue> <depends-on>              # issue DEPENDS ON depends-on
bd dep add <issue> <parent> --type discovered-from
```

**Direction reminder:** `bd dep add A B` means "A depends on B" (A needs B to be done first).

### View Dependencies

```bash
bd dep tree <id>           # Visualize hierarchy
bd blocked --json          # Show blocked issues
```

### Dependency Types

- `blocks` - Hard dependency (affects ready queue)
- `related` - Soft relationship
- `parent-child` - Epic/subtask hierarchies
- `discovered-from` - Tracks where issues were found

## Labels

```bash
bd label add <id> <label> --json
bd label add <id1> <id2> urgent --json     # Batch
bd label remove <id> <label> --json
bd label list <id> --json
bd label list-all --json                    # All labels with counts
```

## Sync and Maintenance

### Sync

```bash
bd sync                    # Full sync (export, commit, pull, import, push)
bd sync --status           # Check sync status
bd sync --flush-only       # Export to JSONL only
```

### Import/Export

```bash
bd import -i .beads/issues.jsonl --dry-run
bd import -i .beads/issues.jsonl
bd import -i issues.jsonl --dedupe-after
bd import -i issues.jsonl --orphan-handling allow|resurrect|skip|strict
bd export -o issues.jsonl --json
```

### Duplicates

```bash
bd duplicates --json
bd duplicates --auto-merge
bd duplicates --dry-run
bd merge <source-id> --into <target-id> --json
bd merge bd-42 bd-43 --into bd-41 --dry-run
```

### Cleanup

```bash
bd cleanup --dry-run --json            # Preview
bd cleanup --force --json              # Delete closed issues
bd cleanup --older-than 30 --force     # Closed > 30 days
bd cleanup --older-than 90 --cascade --force  # Include dependencies
```

### Compaction

```bash
bd compact --analyze --json
bd compact --analyze --tier 1 --limit 10 --json
bd compact --apply --id bd-42 --summary summary.txt
bd compact --stats --json
bd compact --auto --dry-run --all
bd restore <id>                        # Restore compacted issue
```

### Health Check

```bash
bd doctor                  # Check for issues
bd doctor --fix            # Auto-fix issues
```

### Database Migration

```bash
bd migrate --dry-run
bd migrate
bd migrate --cleanup --yes
bd migrate --inspect --json
```

### Rename Prefix

```bash
bd rename-prefix kw- --dry-run
bd rename-prefix kw- --json
```

## Configuration

```bash
bd config list
bd config get <key>
bd config set <key> <value>
```

## Common Agent Workflows

### Claim and Complete

```bash
bd ready --json
bd update bd-42 --status in_progress --json
# ... do work ...
bd close bd-42 --reason "Implemented and tested" --json
bd sync
```

### Discover and Link

```bash
bd create "Found bug during implementation" -t bug -p 1 --deps discovered-from:bd-100 --json
```

### Batch Operations

```bash
bd update bd-41 bd-42 bd-43 --priority 0 --json
bd close bd-41 bd-42 bd-43 --reason "Batch completion" --json
bd label add bd-41 bd-42 bd-43 urgent --json
```

### Session End

```bash
bd sync   # CRITICAL - always run before ending session
```
