# Per-worktree safety checks (ready to paste)

The full sweep, written so you can paste it into a bash session and audit every worktree under a directory. Adjust the `BASE` glob and the `PRIMARY` exclusion for the repo at hand. **Defaults to dry-run** — set `APPLY=1` only when you (or the user) have explicitly opted in.

## End-to-end script

```bash
#!/usr/bin/env bash
set -uo pipefail

PRIMARY="/Users/USERNAME/repos/copilot-code-review-agent"   # never touch
BASE_GLOB="/Users/USERNAME/repos/copilot-code-review-agent-*"
APPLY="${APPLY:-0}"   # set APPLY=1 to actually remove

# Make sure git knows about every listed worktree (cleans up stale metadata)
git -C "$PRIMARY" worktree prune

# Iterate over candidate directories
for wt in $BASE_GLOB; do
  [ -d "$wt/.git" ] || [ -f "$wt/.git" ] || continue
  [ "$wt" = "$PRIMARY" ] && continue

  echo "──────────────────────────────────────────────"
  echo "Worktree: $wt"

  cd "$wt" || { echo "  SKIP  cannot cd"; continue; }

  # 1. Clean working tree?
  status="$(git status --porcelain)"
  if [ -n "$status" ]; then
    echo "  SKIP  uncommitted changes:"
    echo "$status" | sed 's/^/        /'
    continue
  fi

  # 2. On a branch?
  branch="$(git symbolic-ref --short -q HEAD || true)"
  if [ -z "$branch" ]; then
    echo "  SKIP  detached HEAD"
    continue
  fi

  # 3. Upstream + unpushed commits?
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
  if [ -z "$upstream" ]; then
    echo "  SKIP  no upstream tracking on $branch"
    continue
  fi
  unpushed="$(git log "$upstream..HEAD" --oneline)"
  if [ -n "$unpushed" ]; then
    echo "  SKIP  unpushed commits on $branch:"
    echo "$unpushed" | sed 's/^/        /'
    continue
  fi

  # 4. Stash entries?
  stashes="$(git stash list)"
  if [ -n "$stashes" ]; then
    echo "  SKIP  stash entries present:"
    echo "$stashes" | sed 's/^/        /'
    continue
  fi

  # 5. PR merged?
  repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)"
  if [ -z "$repo" ]; then
    echo "  SKIP  cannot resolve owner/repo (gh not authed for this remote?)"
    continue
  fi
  pr_json="$(gh pr list --repo "$repo" --head "$branch" --state all \
    --json number,state,mergedAt --jq '.[0]' 2>/dev/null)"
  state="$(echo "$pr_json" | jq -r '.state // "NONE"')"
  number="$(echo "$pr_json" | jq -r '.number // ""')"

  case "$state" in
    MERGED)
      echo "  REMOVE  PR #$number MERGED — branch $branch"
      if [ "$APPLY" = "1" ]; then
        cd "$PRIMARY"
        git worktree remove "$wt" && git branch -D "$branch" \
          && echo "          ✓ removed worktree + branch"
      else
        echo "          (dry run — set APPLY=1 to actually remove)"
      fi
      ;;
    OPEN)    echo "  SKIP  PR #$number is OPEN" ;;
    CLOSED)  echo "  SKIP  PR #$number CLOSED without merge" ;;
    NONE)    echo "  SKIP  no PR found for branch $branch" ;;
    *)       echo "  SKIP  unexpected PR state: $state" ;;
  esac
done

echo "──────────────────────────────────────────────"
echo "Done. APPLY was '$APPLY'."
```

## Notes

- `git worktree prune` at the top removes metadata for worktrees whose directories were already deleted out from under git (e.g. by `rm -rf`). Cheap and safe.
- The script does not parallelize — each worktree's `gh pr list` is fast enough and serializing avoids ratelimits and `git worktree` metadata races.
- `gh pr list --head <branch>` only finds PRs from the **same repo** as the current `gh repo view` resolves. If your worktree is from a fork that PR'd into upstream, you'll need `--head "<owner>:<branch>"` instead. Surface that case for the user; don't try to guess.
- After `git worktree remove`, the branch still exists locally. We `-D` (force) because squash-merged branches won't pass `-d`'s "merged into HEAD" check even though the work is in main.

## Quick spot-checks

If you only want to audit one worktree:

```bash
cd /path/to/worktree
git status --porcelain && echo "  clean" || echo "  dirty"
git rev-parse --abbrev-ref --symbolic-full-name @{u} || echo "  no upstream"
git log @{u}..HEAD --oneline || true
git stash list
gh pr list --repo "$(gh repo view --json nameWithOwner --jq .nameWithOwner)" \
  --head "$(git symbolic-ref --short HEAD)" --state all \
  --json number,state,mergedAt
```
