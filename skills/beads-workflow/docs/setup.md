# Beads Setup and Configuration

This document covers installation, initialization, and configuration of [beads](https://github.com/steveyegge/beads) (`bd` command). This is reference material - see [SKILL.md](../SKILL.md) for the workflow patterns.

## Installation

```bash
# macOS
brew install steveyegge/tap/bd

# Or via curl
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/install.sh | bash
```

## Initialize in a Project

```bash
cd your-project
bd init
```

This creates:
- `.beads/` directory with database and config
- Git hooks for synchronization

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   bd commands   │────▶│  SQLite Database │────▶│  issues.jsonl   │
│  (create, etc)  │     │   (.beads/*.db)  │     │  (git-tracked)  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                               ▲                        │
                               │                        ▼
                        ┌──────────────┐         ┌─────────────┐
                        │    Daemon    │         │  Git Hooks  │
                        │ (background) │         │ (pre-commit)│
                        └──────────────┘         └─────────────┘
```

### How It Works

1. Issues are stored in a SQLite database (`.beads/*.db`)
2. Changes automatically export to `.beads/issues.jsonl` (git-tracked)
3. Git hooks ensure JSONL stays in sync with commits
4. A background daemon handles real-time synchronization

## Daemon Configuration

### Daemon Modes

| Mode | Sync Latency | CPU Usage | Best For |
|------|--------------|-----------|----------|
| **Polling** (default) | ~5 seconds | Higher | Compatibility |
| **Event-driven** | < 500ms | ~60% less | Performance |

Event-driven mode uses platform-native file watching (FSEvents on macOS, inotify on Linux).

### Starting the Daemon

```bash
# Basic (polling mode)
bd daemon --start

# Event-driven mode (recommended for local dev)
BEADS_DAEMON_MODE=events bd daemon --start

# With auto-commit and auto-push
BEADS_DAEMON_MODE=events bd daemon --start --auto-commit --auto-push
```

### Daemon Flags

| Flag | Purpose |
|------|---------|
| `--auto-commit` | Automatically commit beads changes |
| `--auto-push` | Automatically push commits |
| `--interval` | Sync check interval (default: 5s) |
| `--foreground` | Run in foreground (for systemd) |

### Daemon Management

```bash
bd daemons list --json        # List running daemons
bd daemons health --json      # Check daemon health
bd daemons stop /path --json  # Stop daemon for workspace
bd daemons restart <pid>      # Restart by PID
bd daemons logs /path -n 100  # View logs
bd daemons killall --json     # Stop all daemons
```

### When to Avoid Event-Driven Mode

- Network filesystems (NFS, SMB)
- Container environments
- Resource-constrained systems

Set `BEADS_WATCHER_FALLBACK=true` (default) to fall back to polling if file watching fails.

## Commit Workflows

### Option 1: Sync Branch (Team Projects)

Best for teams where issue changes should be reviewed or kept separate from code.

**Configuration** (`.beads/config.yaml`):
```yaml
sync-branch: "beads-sync"
```

**How it works:**
1. Issue changes commit to `beads-sync` branch
2. Daemon pushes `beads-sync` to remote
3. Merge to main via PR or `bd sync`

**Pros:**
- Issue changes can be code-reviewed
- Avoids conflicts in multi-developer environments
- Clear separation of concerns

**Cons:**
- Extra branch to manage
- Requires manual merge or `bd sync`

### Option 2: Direct Commit (Solo Projects)

Best for solo developers who want simplicity.

**Configuration** (`.beads/config.yaml`):
```yaml
# sync-branch: "beads-sync"  # Commented out or removed
```

**How it works:**
1. Pre-commit hook auto-stages `.beads/*.jsonl` files
2. Issue changes commit alongside your code changes
3. Single branch, single workflow

**Pros:**
- Simpler workflow
- Issue changes always in sync with code
- No extra branches

**Cons:**
- Less control over when issue changes are committed
- Not ideal for teams

## Git Hooks

Beads installs three git hooks:

| Hook | Purpose |
|------|---------|
| **pre-commit** | Flushes pending changes to JSONL, auto-stages beads files (if no sync-branch) |
| **post-merge** | Imports JSONL changes after `git pull` or merge |
| **pre-push** | Exports database to JSONL before push |

### Pre-Commit Hook Behavior

- **With sync-branch**: Skips auto-staging (changes go to sync branch)
- **Without sync-branch**: Auto-stages all `.beads/*.jsonl` files

Verify hooks are installed:
```bash
bd doctor
```

## Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `BEADS_DAEMON_MODE` | `poll` or `events` | `poll` |
| `BEADS_AUTO_START_DAEMON` | Auto-start daemon | `true` |
| `BEADS_NO_DAEMON` | Disable daemon | `false` |
| `BEADS_SYNC_BRANCH` | Override sync branch | - |
| `BEADS_WATCHER_FALLBACK` | Fall back to polling | `true` |

## Config File

Location: `.beads/config.yaml`

Key settings:
```yaml
# Sync branch for team collaboration
sync-branch: "beads-sync"

# Issue prefix (auto-detected from directory name)
# issue-prefix: "myproject"

# Disable daemon
# no-daemon: false
```

### Database Config

View/set via CLI:
```bash
bd config list
bd config set <key> <value>
bd config get <key>
```

## Troubleshooting

### Check Health

```bash
bd doctor
bd doctor --fix  # Auto-fix issues
```

### Common Issues

**Daemon not running:**
```bash
bd daemon --start
```

**Stale daemon after upgrade:**
```bash
bd daemons killall
bd daemon --start
```

**Changes not committing:**
1. Check if sync-branch is configured
2. Verify git hooks are installed: `bd doctor`
3. Check daemon status: `bd daemon --status`

**JSONL out of sync:**
```bash
bd sync --flush-only  # Force export to JSONL
```

**Database feels stale after pull:**
```bash
bd sync  # Triggers auto-import if JSONL is newer
```

## Git Worktrees

Daemon mode doesn't work correctly with git worktrees due to shared `.git` directories. Use:

```bash
BEADS_NO_DAEMON=1 bd <command>
# Or
bd --no-daemon <command>
```

## Claude Code Integration

Claude Code uses `bd` commands directly via the CLI. The session start hook (`bd prime`) injects workflow context into Claude's system prompt automatically when a `.beads/` directory is detected.

Beads deliberately uses CLI + hooks instead of MCP servers for context efficiency (~1-2k tokens vs 10-50k for MCP tool schemas).

## Resources

- [Beads GitHub](https://github.com/steveyegge/beads)
- [Full Documentation](https://github.com/steveyegge/beads/tree/main/docs)
- [Daemon Guide](https://github.com/steveyegge/beads/blob/main/docs/DAEMON.md)
- [Claude Integration](https://github.com/steveyegge/beads/blob/main/docs/CLAUDE_INTEGRATION.md)
