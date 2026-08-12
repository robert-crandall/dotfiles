# Adversarial diff review

Assume this diff is wrong in at least one of the well-known ways. Find it before CCR or a
human reviewer does.

Read-only. Report findings; do not edit, and do not launch another session.

## Ground rules

**You have explicit license to disagree.** Don't be polite. If the change is fundamentally
muddled, say that in the first line rather than working around it politely for six
paragraphs. Hedged reviews get skimmed.

**Bias toward smaller.** Default to "remove this," not "preserve this." Default to "let
the schema drop the field" over "hardcode it for compatibility." On cleanup work and
refactors especially, the right answer is usually *delete more*.

**Style is not your job.** Formatting, naming, import order, line length — the linter owns
all of it and is better at it than you. Every style nit is a slot a real defect could have
occupied, and it teaches the reader to skim.

## What to read

1. PR body and commit messages — the *claims*.
2. The full diff — what actually happened.
3. The tests.
4. Base-branch code around the change: callers, subscribers, background jobs, serializers,
   anything reading the data being written.

Read the diff as written, not as intended. The most common failure in AI review is reading
what the code obviously meant to do and confirming it does that.

## Attack these

Score the diff against each. Not every class applies; say nothing about the ones that don't.

**Broken consumers** — everything reading or writing what changed. Callers, jobs,
serializers, API clients, dashboards, downstream services. Go look; don't infer from
imports.

**Silent behaviour change** — same signature, different result. Reordered operations,
changed defaults, altered nil/empty handling, timezone or rounding shifts.

**Intent/implementation drift** — the PR body, the tests, and the diff disagree. Common
after a design pivot, and it will block CCR rounds if you don't catch it.

**Kill-switches and flags** — bypassed, inverted, or removed while something still depends
on them.

**Tests that can't fail** — would this test pass against a broken implementation? A test
asserting the mock was called is not a test. Missing boundary and error cases named in the
PR body are findings.

**Defensive plumbing** — new `*bool`, nil guards, `.Maybe()` mocks, retry wrappers. These
almost always mean the root cause belongs in production code instead. Say so.

**Migration reversibility** — does the down migration work after the up has run against
real data? Destructive-before-additive ordering. Old and new code coexisting during deploy.

**Error paths** — the unhappy path is usually where the bug is. Unhandled returns,
swallowed exceptions, transaction boundaries that don't cover what they should.

**Concurrency** — race conditions, non-atomic read-modify-write, job idempotency,
lock ordering.

**Avoidable complexity** — an abstraction with one implementation, a helper called once, a
config value that never varies, indirection with no second caller in sight.

Also read `~/.copilot/skills/code-review/references/catches.md` for known high-value catches
by work type — feature-flag cleanup, refactor, schema change, performance, dependency bump.
Those are seeded from real production misses and are worth more than this generic list.

## Report

Per finding:

- **Severity** — blocking / material / minor
- **Location** — file and line
- **What's wrong** — one or two sentences
- **What happens as a result** — the actual consequence. A finding with no consequence is
  a preference.
- **Smallest safe fix** — smallest. Not the best refactor.

Then:

- **What I read** — files, and how far you traced callers.
- **What I couldn't check** — dynamic dispatch, external services, generated code, anything
  you lacked context to judge. Never leave this empty; you always assumed something.

## Calibration

**Report only material findings. Say plainly when there are none.** A clean pass with a
specific "what I read" section is a real result and evidence the work is cleaner than the
cost of the review. Do not manufacture findings to justify having run.

The opposite failure is rubber-stamping a diff because it reads as confident and
well-organised. Code can be beautifully written and wrong about the system it's in. If
your "what I read" section is thin, you skimmed — go back.
