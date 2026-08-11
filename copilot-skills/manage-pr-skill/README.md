# Manage PR

Drive a pull request from "review feedback received" to "ready to merge" through the address → reply → resolve → request-review → watch-CI loop.

## What It Does

Encodes hard-won knowledge about GitHub's PR review APIs and the typical iteration loop, so you don't have to rediscover them:

- The right reviewer login to re-request Copilot Code Review (CCR) is `copilot-pull-request-reviewer[bot]`, **not** plain `Copilot`. The plain form silently no-ops on re-requests after the bot has already reviewed.
- A successful re-request POST returns 201 even when GitHub silently dedup's it; you must verify by re-reading the PR.
- CCR runs are tied to a specific commit SHA; you can't trigger a fresh review without either a new push or a successful re-request.
- The latest CCR review's `commit_id` must match the current `head.sha` before declaring victory — otherwise you're reading an approval verdict from an earlier SHA.

## When to Use This Skill

- "Address all the open review comments on PR #X"
- "Re-request Copilot review on this PR"
- "Wait for CI to finish and tell me what's failing"
- "Loop on this PR — fix the review feedback and the CI failures until it's all green"
- "What's the state of PR #X? What's left to address?"

For raw CI watching only, prefer [`watch-ci`](../watch-ci-skill/). For waiting on a single CCR pass, prefer [`wait-for-copilot-code-review`](../wait-for-copilot-code-review-skill/). Use this skill when you want full address-feedback + watch orchestration.

## Installation

### Personal skill (recommended)

```bash
# Symlink into your personal skills directory
ln -s /path/to/manage-pr-skill ~/.copilot/skills/manage-pr-skill
```

### Project skill

```bash
# Copy into your project
cp -r manage-pr-skill .github/skills/manage-pr-skill
```

## Usage

Just ask:

- "Address the PR feedback on owner/repo#289"
- "Re-request a Copilot review on this PR"
- "Wait for CI on PR #42 and tell me if anything fails"
- "Iterate on this PR until it's ready to merge"

The skill will:

1. Snapshot the PR (one GraphQL read: threads + CI + mergeability + CCR head-coverage)
2. Apply fixes for unresolved threads
3. Push, then reply on and resolve each addressed thread
4. Request (or re-request) Copilot review using the correct `[bot]`-suffixed login
5. Verify the re-request landed (the API silently drops some)
6. Watch CCR + CI to completion
7. Loop until clean

## Files

- [`SKILL.md`](SKILL.md) — full agent instructions
- [`references/copilot-code-review.md`](references/copilot-code-review.md) — the CCR re-request gotcha, workflow timing, and how to debug "review never fires"
- [`references/bulk-resolve.md`](references/bulk-resolve.md) — bash template for replying to + resolving N threads in one pass
- [`references/gh-pr-snippets.md`](references/gh-pr-snippets.md) — copy-pasteable `gh api` commands for common PR queries

## Related Skills

- [`create-pr`](../create-pr-skill/) — opens the PR that this skill drives through review
- [`watch-ci`](../watch-ci-skill/) — focused CI-only monitoring with notifications on completion
- [`wait-for-copilot-code-review`](../wait-for-copilot-code-review-skill/) — zero-token polling for a single CCR pass
- [`slack-search`](../slack-search-skill/) — pull related Slack discussion when a review comment references chat context
