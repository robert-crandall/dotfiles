# PR Template Formats

Always check `.github/PULL_REQUEST_TEMPLATE*` (singular) and `.github/PULL_REQUEST_TEMPLATE/` (directory of named templates). If neither exists, write a focused body with at minimum: motivation, what changed, validation, and risk/rollback notes.

## Tooling tips

- Use `gh pr create --body-file <path>` for non-trivial bodies. Inline `--body "..."` with multi-line content is brittle.
- For repeat use in the same session, write the body to `/tmp/pr-body-<branch>.md`, create the PR, then `rm` the file.
- After creation, `gh pr edit <num> --body-file <path>` lets you iterate without recreating the PR.
- `gh pr view <num> --json body --jq .body` to inspect the rendered body.
