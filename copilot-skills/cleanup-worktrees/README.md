# cleanup-worktrees

Skill for safely removing git worktrees whose PRs have merged.

The two failure modes this skill exists to prevent:

1. **Deleting work that hasn't been pushed yet** — a worktree may have local commits ahead of origin, uncommitted changes, or stash entries. The skill checks all three before removing.
2. **Deleting the primary checkout** — `git worktree list` includes the main repo. The skill always excludes it from candidate work.

The 6-rule safety check (worktree not primary, working tree clean, no unpushed commits, PR merged, no stashes, branch not detached) is in `SKILL.md`. Ready-to-paste bash is in `references/checks.md`.
## Installation

```bash
gh hubber-skills install cleanup-worktrees-skill
```
