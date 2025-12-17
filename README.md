# Beads Skill (No MCP)

Thin wrapper around the [official beads skill](https://github.com/steveyegge/beads/tree/main/skills/beads) for Claude Code users who want the comprehensive skill without the MCP server overhead.

## Why This Exists

The official beads plugin includes both a skill AND an MCP server. If you:

- Already have `bd` installed via Homebrew
- Want the comprehensive skill guidance
- Don't want MCP protocol overhead (~10-50k tokens vs ~1-2k for CLI)

This plugin provides just the skill.

## What's Included

| Content | Source |
|---------|--------|
| `skills/beads/SKILL.md` | [Official skill](https://github.com/steveyegge/beads/blob/main/skills/beads/SKILL.md) |
| `skills/beads/references/` | [Official references](https://github.com/steveyegge/beads/tree/main/skills/beads/references) |

The skill covers:
- bd vs TodoWrite decision framework
- Compaction survival strategies
- Session start/end protocols
- Progress checkpointing triggers
- Field usage (notes, design, acceptance-criteria)
- Dependency patterns
- Issue creation guidelines

## Installation

```bash
# Install beads CLI first (if not already)
brew tap steveyegge/beads
brew install bd

# Install this plugin
/plugin add chrisvaillancourt/beads-plugin
```

## Recommended: Also Install Hooks

For best results, also install the official hooks which run `bd prime` for dynamic context:

```bash
bd setup claude
```

The hooks provide dynamic project-specific context, while this skill provides comprehensive reference documentation.

## Updating

This plugin mirrors the official beads skill. To update when beads releases new versions:

```bash
# Check current version
cat .claude-plugin/plugin.json | grep upstream -A3

# Update (manual process for now)
cd /path/to/beads-plugin
./scripts/sync-upstream.sh  # TODO: create this script
```

## Upstream

- **Source:** https://github.com/steveyegge/beads/tree/main/skills/beads
- **Version:** 0.30.2
- **License:** MIT (same as upstream)

## See Also

- [beads repo](https://github.com/steveyegge/beads) - The official beads project
- [bd setup claude](https://github.com/steveyegge/beads/blob/main/docs/INSTALLING.md) - Official hooks setup
- [beads MCP plugin](https://github.com/steveyegge/beads/tree/main/.claude-plugin) - Full plugin with MCP (if you want that)
