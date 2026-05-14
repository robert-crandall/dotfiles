---
name: cleanup-worktrees
description: This skill should be used when the user asks to "clean up worktrees", "remove merged worktrees", "prune worktrees", "delete worktrees whose PRs are merged", "tidy up after the fleet", or otherwise wants to safely garbage-collect git worktrees that have outlived their PR. Encodes the safety checks (PR merged, no uncommitted changes, no unpushed commits, not the primary checkout) that prevent accidental data loss.
---

# Cleanup Worktrees — safely remove worktrees whose PRs have merged

Use this skill when a worktree-heavy workflow leaves a yard full of stale `repo-feature-x/` directories after the PRs merged. The mechanics are simple — `git worktree remove` — but you need to know **which** ones are safe to remove before pulling the trigger.

## When to Use This Skill

- "Clean up the worktrees from yesterday's fleet."
- "Which worktrees can I delete?"
- "Prune any worktree whose PR has been merged."
- "Tidy up the `repo-name-rm-*` directories under `~/Repos`."

If the user wants to clean up **branches** (not worktrees), this is the wrong skill — `git branch -d` on each is fine.

## Safety Rules (do not bypass)

A worktree is safe to remove **only if all of these hold**:

1. It is **not the primary checkout** (i.e. not the one the bare repo / source repo lives in).
2. `git status --porcelain` is empty in the worktree (no modified, no staged, no untracked non-ignored files).
3. The worktree's branch has **no unpushed commits** — `git log <upstream>..<branch>` is empty.
4. The branch's PR is **merged** (state=MERGED, mergedAt is non-null). Closed-without-merge or still-open PRs do not qualify.
5. The worktree has **no stash entries** specific to it (`git stash list` shows nothing scoped to this worktree).
6. The worktree's HEAD is **on a real branch**, not detached.

If any rule fails, **skip that worktree and surface the reason**. Do not "ask the user once and then delete the rest." Ask per skipped worktree, or default-skip and report.

## Workflow

### 1. Inventory all worktrees

```bash
git worktree list --porcelain
```

Each entry has `worktree <path>`, `HEAD <sha>`, and either `branch refs/heads/<name>` or `detached`.

The first entry is usually the primary checkout — note its path and exclude it from candidate work.

### 2. For each candidate worktree, run the safety checks

```bash
cd "$WORKTREE_PATH"

# 2a. Clean working tree?
status="$(git status --porcelain)"
[ -z "$status" ] || skip "uncommitted changes"

# 2b. Unpushed commits?
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
[ -n "$upstream" ] || skip "no upstream tracking"
unpushed="$(git log "$upstream..HEAD" --oneline)"
[ -z "$unpushed" ] || skip "unpushed commits: $unpushed"

# 2c. Branch + PR merged?
branch="$(git symbolic-ref --short -q HEAD)"
[ -n "$branch" ] || skip "detached HEAD"

# Discover repo (owner/repo) — usually from origin URL
repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"

pr_state="$(gh pr list --repo "$repo" --head "$branch" --state all \
  --json number,state,mergedAt --jq '.[0]')"
case "$(echo "$pr_state" | jq -r '.state // "NONE"')" in
  MERGED) ;;             # safe
  OPEN)   skip "PR is still open" ;;
  CLOSED) skip "PR closed without merge" ;;
  NONE)   skip "no PR found for this branch" ;;
esac

# 2d. Stash entries?
stashes="$(git stash list)"
[ -z "$stashes" ] || skip "has stash entries"
```

### 3. Show the user the verdict

Always print a per-worktree summary before doing anything destructive:

```text
Found 7 candidate worktrees:

  REMOVE  repo-name-rm-grouping-detector  (PR #2088 MERGED, branch cleanly gone)
  REMOVE  repo-name-rm-plan-tool          (PR #2090 MERGED, no drift)
  SKIP    repo-name-feature-x             (PR open: #2099)
  SKIP    repo-name-experiment            (no upstream tracking, 3 unpushed commits)
  SKIP    repo-name-wip                   (uncommitted changes: M src/foo.go)
  SKIP    /Users/.../repo-name            (primary checkout — never auto-remove)
  SKIP    repo-name-detached-debug        (detached HEAD)

Safe to remove: 2.  Skipped: 4 (+ primary).
```

### 4. Confirm before removing

Default to **asking the user** before any destructive action, even when everything looks safe:

```
Proceed with removing the 2 safe worktrees? [y/N]
```

Only auto-remove without asking when the user has explicitly said something like "just clean them up" or "go ahead and delete the merged ones — don't ask me."

### 5. Remove

```bash
git worktree remove "$WORKTREE_PATH"
```

If `git worktree remove` complains about the worktree being "dirty" (e.g. ignored files like `node_modules/`), this is a sign the safety checks may have missed something. **Do not pass `--force` automatically.** Surface the message and let the user decide.

### 6. Optional: delete the local branch

After a successful worktree removal, the branch still exists locally. Squash-merged branches won't pass `git branch -d <name>` (the commit isn't in main's history), but you already know the PR was merged from step 2c, so you can safely `git branch -D <name>`.

Default: **also delete the branch** unless the user said "keep the branches around."

```bash
cd "$PRIMARY_CHECKOUT"
git branch -D "$BRANCH_NAME"
```

### 7. Final summary

Report what was removed and what was skipped, with reasons:

```text
Removed:
  ✓ repo-name-rm-grouping-detector  (branch obvioussean/remove-grouping-detector-ff also deleted)
  ✓ repo-name-rm-plan-tool          (branch obvioussean/remove-enable-plan-tool-ff also deleted)

Skipped (action required from you):
  • repo-name-feature-x             — PR #2099 is still open
  • repo-name-experiment            — 3 unpushed commits on branch sean/experiment-2
  • repo-name-wip                   — uncommitted changes:  M src/foo.go
  • repo-name-detached-debug        — detached HEAD; check it out to a branch first
```

## Common Pitfalls

- **`git worktree remove --force` to "make it work."** Force is for orphaned/broken worktrees. If the safety checks passed and remove still complains, the worktree has files that aren't gitignored that you didn't notice — investigate before forcing.
- **Deleting the primary checkout.** Always exclude the first entry in `git worktree list --porcelain` (or whichever entry's path is the canonical one).
- **Deleting an unmerged branch with `-D` based on PR state alone.** Always confirm `gh pr view` shows `MERGED` (not just `CLOSED`) before force-deleting the branch. A closed-without-merge PR's branch may still hold work the user wants.
- **Running across multiple repos at once.** Each worktree's `gh pr list --repo` lookup needs the right owner/repo. Run `cd $WORKTREE_PATH && gh repo view --json nameWithOwner` per worktree, don't assume.
- **Trusting `git status` on a worktree with `node_modules/` or build artifacts.** Those should be in `.gitignore`. If they show up in `git status --porcelain`, that's a real signal — the repo's `.gitignore` is incomplete. Don't suppress.
- **Ignoring stashes.** Worktrees can carry their own stash entries. A non-empty `git stash list` means uncommitted work the user might want.

## Boundaries

**Will:**
- Inventory every worktree under a given path or for a given repo.
- Run all 6 safety checks per worktree.
- Show a per-worktree verdict before doing anything destructive.
- Ask for confirmation before removing (unless the user explicitly opted out).
- Remove the worktree and optionally the local branch when safe.
- Report what was removed and what was skipped, with reasons.

**Will Not:**
- Use `--force` to remove a "dirty" worktree without asking.
- Delete a branch whose PR is closed-without-merge unless the user explicitly says to.
- Touch the primary checkout.
- Touch worktrees on detached HEAD without surfacing them.
- Run across worktrees in parallel — sequential is fast enough and avoids race conditions on `git worktree` metadata.

## References

- [`references/checks.md`](references/checks.md) — ready-to-paste bash for the per-worktree safety checks.

## Related Skills

- `create-pr` — the upstream of all those worktrees in the first place.
- `manage-pr` — drives the PR through review/CI; this skill picks up after the PR is merged.
- `remove-feature-flag` — the canonical "fleet of worktrees" producer.
