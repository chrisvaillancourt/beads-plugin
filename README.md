# Beads Plugin

Custom Claude Code plugin that provides [beads](https://github.com/steveyegge/beads) workflow patterns as a skill.

> **⚠️ Recommendation: Use the official hooks instead**
>
> Beads has built-in Claude Code integration via `bd setup claude` that installs hooks running `bd prime`. This approach is superior because:
> - **Dynamic**: Generates context based on your actual project state
> - **Conditional**: Only injects tokens when `.beads/` directory exists
> - **Adaptive**: Adjusts output for MCP mode, branch type, etc.
>
> See [Official Integration](#official-integration-recommended) below.

## What is this?

This is a **custom Claude Code plugin** that provides a **skill** teaching Claude about beads issue tracking workflows. Skills are model-invoked capabilities that package expertise and workflow guidance.

### When to Use This Plugin

This skill-based approach is **not recommended** for most users. Consider it only if:

- You don't want to install global hooks in `~/.claude/settings.json`
- You prefer model-invoked skills over automatic hook injection
- You want to learn about beads workflow without having beads installed

### Official Integration (Recommended)

The beads project provides built-in Claude Code integration:

```bash
# Install beads hooks (recommended approach)
bd setup claude

# Verify installation
bd doctor
```

This installs `SessionStart` and `PreCompact` hooks that run `bd prime`, which:
1. Checks if current directory has `.beads/` - exits silently if not
2. Generates ~1-2k tokens of dynamic workflow context if it is
3. Re-injects context before compaction so Claude doesn't forget

### How This Plugin Differs

| Aspect | Official Hooks (`bd prime`) | This Plugin (skill) |
|--------|----------------------------|---------------------|
| **Trigger** | Automatic at session start | Model-invoked (Claude decides) |
| **Detection** | Checks `.beads/` directory | Relies on description matching |
| **Context** | Dynamic (knows your issues) | Static (same content always) |
| **Adapts to** | MCP mode, branch type | Nothing |
| **Token cost when not relevant** | Zero (silent exit) | Zero (not loaded) |

### Relationship to Other Beads Integrations

- **`bd setup claude`** (hooks): Recommended. Dynamic context injection via `bd prime`
- **Official MCP plugin**: Optional. Provides slash commands (`/bd-ready`, `/bd-create`) and MCP tools
- **This plugin** (skill): Alternative for users who prefer skills over hooks

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
