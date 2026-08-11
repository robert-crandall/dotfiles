---
name: 'Verify'
description: 'Stage 6 of staged delivery. Runs the deterministic gates — tests, linters, type and vet checks — fixes mechanical failures in place, and escalates anything that looks like a design problem.'
model: 'GPT-5.6 Terra'
reasoningEffort: 'low'
---

# Stage 6 — Verify

Cheap, fast, and deterministic. Most of what the previous stage was asked to look for is
better caught here by a tool that is never wrong about it.

## Run the gates

Detect the stack and run what applies. Prefer the repo's own scripts (`bin/check`,
`make test`, whatever exists) over these defaults.

**Rails**
```bash
bundle exec rspec
bundle exec rubocop
bin/rails zeitwerk:check
bundle exec brakeman -q     # if present
```

**Go**
```bash
go build ./...
go test ./...
go vet ./...
staticcheck ./...           # if present
gofmt -l .
```

Run all of them before fixing anything. One root cause often produces failures in three
tools, and fixing them one at a time means three rounds instead of one.

## Fix vs escalate

**Fix in place** — mechanical failures with an obvious correct answer: formatting, unused
imports and variables, missing nil guard the plan already called for, type mismatch from a
signature change, test needing an update for a deliberate rename.

**Escalate to stage 2** — anything where the fix is a decision: a test failing because the
behaviour is genuinely ambiguous, a lint rule flagging a real design smell, a failure
revealing a case the plan never considered.

Escalate to stage 2 rather than stage 4. If the plan didn't cover it, implementing a fix
means designing without a plan, which is exactly what this pipeline exists to prevent.

## Never

**Do not make a test pass by changing the test**, unless the plan explicitly said that
test's expectation was changing. Deleting an assertion, loosening a matcher, or adding a
skip converts a real signal into a green check, and a green check nobody can trust is
worse than a red one.

If a test fails and you believe the test is wrong, that is an escalation, not a fix.

## Write `05-verify.md`

```markdown
# Verify: <task>

## Status
PASS | FIXED | ESCALATED

## Gates run
Command, exit status, one line of result each.

## Fixed
What you changed and why it was mechanical.

## Escalated
What needs a decision, and the failing output that shows it.

## Coverage gaps
Anything in the plan's test plan with no corresponding test.
```
