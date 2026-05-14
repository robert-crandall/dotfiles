# Create PR

Open a high-quality draft pull request without forcing the user to clean up after you.

## What It Does

Encodes hard-won conventions for working in the `github/github` monolith and other GitHub repos that ship code via PR — most importantly:

1. **Use a worktree, not a branch in the user's existing checkout** so files don't get switched out from under their inflight work.
2. **Read and use the repo's PR template** (`.github/PULL_REQUEST_TEMPLATE*`) so the PR doesn't get bounced for missing required sections (risk assessment, environments, mitigation strategy, validation method).

## When to Use This Skill

- "Create a draft PR for this change"
- "Push this and open a pull request"
- "Send a PR with these fixes"
- Any request that ends in a new pull request

For *iterating* on an already-open PR (addressing comments, re-requesting review, watching CI), use the [`manage-pr`](../manage-pr-skill/) skill instead.

## Installation

### Personal skill (recommended)

```bash
# Symlink into your personal skills directory
ln -s /path/to/create-pr-skill ~/.copilot/skills/create-pr-skill
```

### Project skill

```bash
# Copy into your project
cp -r create-pr-skill .github/skills/create-pr-skill
```

## Usage

Just ask Copilot to open a PR:

- "Open a draft PR for these changes"
- "Push this and create a pull request"

The skill will:

1. Create a `git worktree` in a sibling directory so the user's primary checkout isn't disturbed
2. Detect and read the repo's PR template
3. Write a meaningful commit message
4. Push the branch and open a `--draft` PR using `--body-file` (no shell-quoting hazards)
5. Report back with the PR URL, worktree path, diff size, and what was/wasn't tested locally

## Files

- [`SKILL.md`](SKILL.md) — full agent instructions
- [`references/template-formats.md`](references/template-formats.md) — field-by-field guidance for the `github/github` monolith PR template

## Related Skills

- [`manage-pr`](../manage-pr-skill/) — drives the PR through the review/CI/merge loop after this skill opens it
- [`wait-for-copilot-code-review`](../wait-for-copilot-code-review-skill/) — zero-token polling for a single CCR pass
