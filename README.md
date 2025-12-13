# Beads Plugin

Claude Code plugin for [beads](https://github.com/steveyegge/beads) issue tracking workflows.

## Skills

### beads-workflow

Workflow patterns for beads issue tracking:

- Session close protocol (sync and push before claiming done)
- Dependency direction ("needs" not "comes before")
- Core `bd` command reference
- Issue types and priorities
- Git worktree support

**Supplementary docs** (not loaded with skill):
- [Setup & Configuration](skills/beads-workflow/docs/setup.md) - Installation, daemon config, architecture
- [CLI Reference](skills/beads-workflow/docs/cli-reference.md) - Complete command reference

## Installation

Add to your Claude Code plugins:

```bash
# From GitHub
/plugin add chrisvaillancourt/beads-plugin

# Or clone and add locally
git clone https://github.com/chrisvaillancourt/beads-plugin.git
/plugin add /path/to/beads-plugin
```

## Usage

The skill is automatically available in Claude Code conversations when working in projects with a `.beads/` directory. Reference it with the Skill tool or it will be suggested when relevant.

## License

MIT
