# AGENTS.md Template for Projects Using Beads

This is an example template for adding beads guidance to your project's AGENTS.md file. Copy the sections you need.

---

## How to Use This Template

### Start Minimal

Begin with only the **Minimal Version** below. The `bd prime` hooks (installed via `bd setup claude`) already inject comprehensive workflow context at session start. You don't need to duplicate it.

### Expand If Needed

Add more sections only if you observe agents:
- Forgetting to sync/push at session end
- Creating issues without descriptions
- Getting dependency direction wrong
- Missing project-specific conventions

### When to Reduce

If `bd prime` is working well and agents follow the workflow correctly, you can trim your AGENTS.md back to the minimal version. Less documentation = less noise = better agent focus.

---

## Minimal Version (Recommended Start)

```markdown
## Issue Tracking

This project uses [beads](https://github.com/steveyegge/beads) (`bd` command).

Run `bd onboard` on first session.

**Session end:** Always run `bd sync && git push` before claiming done.
```

---

## Standard Version (If Agents Need More Guidance)

```markdown
## Issue Tracking (Beads)

This project uses [beads](https://github.com/steveyegge/beads) for issue tracking.

### First Session
Run `bd onboard` to learn the workflow.

### Session Start
```bash
bd ready --json           # Find unblocked work
bd show <id> --json       # Review issue details before starting
```

### During Work
```bash
bd update <id> --status=in_progress --json   # Claim work
bd create "Title" -t task -d "Description" --deps discovered-from:<parent-id> --json  # Log discovered work
bd close <id> --reason="Done" --json         # Complete work
```

### Session End Protocol (CRITICAL)
**Work is NOT done until pushed.** Before claiming "complete" or "done":
```bash
bd sync && git push
```
Skipping this = losing work.

### Conventions
- Always use `--json` flag for reliable parsing
- Always include `--description` when creating issues
- Link discovered work with `--deps discovered-from:<parent-id>`
```

---

## Comprehensive Version (If Agents Consistently Struggle)

Only use this if agents repeatedly make mistakes despite the standard version.

```markdown
## Issue Tracking (Beads)

This project uses [beads](https://github.com/steveyegge/beads) for issue tracking. Track work in beads, not markdown TODOs or TodoWrite.

### First Session
Run `bd onboard` to learn the workflow. This only needs to happen once per project.

### Session Start
```bash
bd ready --json           # Find unblocked work
bd show <id> --json       # Review issue details
```

Pick an issue from `bd ready`, review it with `bd show`, then claim it.

### Claiming and Completing Work
```bash
# Claim work
bd update <id> --status=in_progress --json

# Complete work
bd close <id> --reason="Implemented and tested" --json
```

### Creating Issues
```bash
# Basic issue
bd create "Title" -t task -d "Why this matters and what to do" --json

# Bug with priority
bd create "Title" -t bug -p 1 -d "Description" --json

# Discovered during other work (ALWAYS link to parent)
bd create "Found during implementation" -t task --deps discovered-from:<parent-id> --json
```

**Always include descriptions.** Issues without context waste future time.

### Issue Types
| Type | Use Case |
|------|----------|
| `bug` | Defects requiring fix |
| `feature` | New functionality |
| `task` | General work (tests, docs, refactoring) |
| `epic` | Large features with subtasks |
| `chore` | Maintenance work |

### Priorities
| Priority | Meaning |
|----------|---------|
| `0` | Critical (security, data loss, build broken) |
| `1` | High (major features, blocking work) |
| `2` | Medium (default) |
| `3` | Low (polish, optimization) |
| `4` | Backlog (future ideas) |

### Dependencies

Dependencies express "needs" not "comes before".

**Cognitive trap:** Temporal language ("Phase 1 before Phase 2") inverts your thinking.

```bash
# WRONG (temporal): "Phase 1 comes before Phase 2"
bd dep add phase1 phase2

# CORRECT (requirement): "Phase 2 needs Phase 1"
bd dep add phase2 phase1
```

Verify with `bd blocked --json` - tasks should be blocked by their prerequisites.

### Session End Protocol

**CRITICAL: Work is NOT done until pushed.**

Before claiming "done", "complete", or ending the session:

```bash
git status              # Check what changed
git add <files>         # Stage code changes
bd sync                 # Commit beads changes
git commit -m "..."     # Commit code
git push                # Push to remote
```

**The plane is NOT landed until `git push` succeeds.**

### Common Mistakes

| Mistake | Fix |
|---------|-----|
| Saying "done" without sync/push | Run full session end protocol |
| `bd dep add A B` meaning "A before B" | Think "B needs A" instead |
| Using TodoWrite for tasks | Use `bd create` instead |
| Creating issues without descriptions | Always include `-d "..."` |
| Forgetting discovered work link | Use `--deps discovered-from:<id>` |
| Omitting `--json` flag | Always use `--json` for agent operations |

### Red Flags - STOP

If you catch yourself doing any of these, stop and correct:

- About to say "complete" without running session end protocol
- Using temporal language for dependencies ("first", "then", "before")
- Creating markdown TODOs or using TodoWrite
- Ending session without `bd sync && git push`

### Troubleshooting

```bash
bd doctor              # Check for issues
bd doctor --fix        # Auto-fix issues
bd info --json         # System info
```

### Git Worktrees

Daemon mode doesn't work with git worktrees. Use:

```bash
BEADS_NO_DAEMON=1 bd <command>
# Or
bd --no-daemon <command>
```
```

---

## Project-Specific Additions

Add these sections if your project has custom conventions:

### Custom Labels

```markdown
### Labels for This Project
- `frontend` - UI/UX work
- `backend` - API/server work
- `urgent` - Needs immediate attention
- `tech-debt` - Refactoring and cleanup
```

### Custom Workflows

```markdown
### PR Workflow
1. Create issue with `bd create`
2. Create branch from issue: `git checkout -b <issue-id>-description`
3. Work and commit
4. Close issue when PR merges: `bd close <id> --reason="Merged in PR #X"`
```

### Team Conventions

```markdown
### Team Conventions
- Assign yourself before starting: `bd update <id> --assignee=$(whoami) --json`
- Use priority 0 only for production incidents
- Epics should have 3-7 subtasks (split if larger)
```

---

## What NOT to Include

Don't add these to your AGENTS.md - they're handled by `bd prime`:

- ❌ Full command reference (injected by hooks)
- ❌ Installation instructions (one-time setup)
- ❌ Architecture explanation (not needed for usage)
- ❌ Daemon configuration (automatic)

The goal is minimal, actionable guidance that reinforces critical behaviors without duplicating what the hooks provide.
