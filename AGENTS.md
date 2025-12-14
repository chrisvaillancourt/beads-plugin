# Agent instructions
This file provides guidance to agents when working with code in this repository.

## Project Overview
This is a **Claude Code plugin** that provides a skill teaching Claude about beads issue tracking workflows. It's a skill-based plugin (not an MCP server), meaning it packages workflow knowledge and best practices rather than providing executable tools.

**Important context:** The official beads project recommends using `bd setup claude` which installs hooks that run `bd prime` for dynamic context injection. That approach is superior because:
- `bd prime` checks for `.beads/` directory and exits silently if not found (no wasted tokens)
- It generates dynamic context based on actual project state
- It adapts to MCP mode, branch type, etc.

This skill-based plugin is an **alternative** for users who prefer skills over hooks, or want to learn about beads without installing hooks globally.

**Key distinction:** This is separate from the [official beads plugin](https://github.com/steveyegge/beads/blob/main/docs/PLUGIN.md), which is an MCP server providing slash commands (`/bd-init`, `/bd-ready`, etc.).

## Repository Structure
```
.claude-plugin/
  plugin.json          # Plugin metadata for Claude Code
skills/
  beads-workflow/
    SKILL.md           # Main skill file with workflow patterns
    docs/
      setup.md         # Installation and daemon configuration
      cli-reference.md # Complete bd command reference
```

## Core Architecture
This plugin follows the Claude Code skills pattern:

- **Plugin manifest**: `.claude-plugin/plugin.json` defines metadata
- **Skill file**: `skills/beads-workflow/SKILL.md` contains the workflow guidance that Claude reads when working in beads projects
- **Supporting docs**: Additional documentation in `docs/` directory (not loaded with skill, reference only)

The skill is **model-invoked** - Claude automatically uses it when working in projects with a `.beads/` directory.

## Working with Skill Files
When editing `skills/beads-workflow/SKILL.md`:

1. **Front matter is critical**: The `name` and `description` fields control when Claude invokes the skill
2. **Description must be specific**: It determines auto-discovery - be precise about when to use the skill
3. **Use tables and checklists**: Skills benefit from scannable formats
4. **Include anti-patterns**: "Common Mistakes" and "Red Flags" sections prevent errors
5. **Convention over configuration**: Document the `--json` flag convention for agent operations

## Testing Changes
After modifying the skill:

1. Reload the plugin: `/plugin reload beads-plugin` (or restart Claude Code)
2. Test in a project with a `.beads/` directory to verify auto-invocation
3. Check that the skill description triggers in relevant contexts

## Git Workflow
Follow conventional commits style (see recent commits):
- `docs:` for documentation changes
- `feat:` for new skill content
- `refactor:` for restructuring
- `chore:` for maintenance

## Beads Integration
This repository itself can use beads for task tracking. If `.beads/` directory exists, use the skill's own guidance for managing issues.

## Recommendations for Using Beads in Other Projects

If you want to use beads in your own projects (not this skill), see the example template at [examples/AGENTS-beads-template.md](examples/AGENTS-beads-template.md).

### Quick Setup

```bash
# 1. Initialize beads in your project
bd init                    # or bd init --team for collaboration

# 2. Install Claude hooks (one-time, global)
bd setup claude

# 3. Verify
bd doctor
```

### Minimal AGENTS.md Addition

For most projects, add only this to your AGENTS.md:

```markdown
## Issue Tracking

This project uses [beads](https://github.com/steveyegge/beads) (`bd` command).

Run `bd onboard` on first session.

**Session end:** Always run `bd sync && git push` before claiming done.
```

The `bd prime` hooks handle workflow injection automatically. Only add more documentation if agents consistently forget steps or your project has custom conventions.
