---
name: adversarial-review
description: This skill should be used when the user asks to "give this an adversarial review", "rubber-duck this with teeth", "what could go wrong here", "find the regression", "argue against this plan", "second opinion on this diff", "stress-test this design", "is there a simpler approach I'm missing", or otherwise wants a hostile critique of a plan, diff, design, or decision before committing to it. Runs the rubber-duck agent on a different model lineage (GPT-5.5 high) so the critique is genuinely independent rather than another Claude rubber-stamp.
---

# Adversarial Review — find the regression before you ship it

The standard rubber-duck pass is too cooperative for cleanup work, refactors, and design pivots — the right answer there is usually "delete more, simplify more, think about what you're actually breaking," not "yes that looks fine." This skill runs a hostile second-opinion pass on **GPT-5.6 Sol high** (a different model lineage from Claude Opus, so the disagreement is genuine and not just another instance of the same model agreeing with itself).

Use it as a forcing function: assume your plan or your diff is wrong in at least one of the well-known ways, and let the adversarial agent find it before CCR or your reviewers do.

## When to Use

**Always use:**

- Before opening a PR for any non-trivial change (>2 files, schema touch, persisted-data touch, telemetry change, behavior change).
- After a design pivot where the implementation evolved away from the original plan — the PR body, the tests, and the diff often disagree.
- When CCR or human reviewers keep coming back with the same class of comment — that's a signal the underlying mental model is wrong, not that the comments need addressing one-by-one.
- Before declaring done on cleanup work, refactors, and dead-code removal — these are the failure modes most prone to "looked simple, broke a downstream consumer."
- When you're about to add defensive plumbing (`*bool`, `nil` checks, `.Maybe()` mocks, retry logic) — that almost always means root-causing the problem in production code is the better fix.

**Don't bother:**

- Trivial edits: typo fixes, single-line bugfixes, doc-only PRs you've vetted.
- Tasks you've executed cleanly 5+ times before with no surprises.
- Things where you already know exactly what's right (rare; default to using the skill if uncertain).

The adversarial pass costs ~60-90s of agent time. Worth it on anything you'd be embarrassed to ship a regression in. Not worth it on a comment fix.

## Process

### Step 1 — Snapshot the work

Before invoking the agent, gather what it needs to attack:

- **The plan** — what you're about to do, in your own words. Bullet points are fine. Don't sanitize; the agent should see your real reasoning, including hedges and "I think this works because…"
- **The surface area** — for code work, list the files touched and a one-line "what changes here" per file. For design work, list the systems involved.
- **The constraints you're keeping** — kill-switches preserved, dependent FFs untouched, JSON schema compatibility, etc. Make these explicit so the agent doesn't waste time arguing for changes you've already ruled out.
- **The diff (post-edit only)** — `git diff origin/main..HEAD --stat` and the actual diff. If it's huge, point at the non-obvious files; the agent will read them.

### Step 2 — Run the adversarial pass

Use the `task` tool with these arguments:

- `agent_type: "rubber-duck"`
- `name`: descriptive, e.g. `"adversarial-ff-removal"` or `"adversarial-pr-2095"`
- `mode: "sync"` (you want the critique before continuing)
- **`model: "gpt-5.5"`** — *required override*; the default rubber-duck model is another Claude, which defeats the purpose
- `prompt`: use the template in `references/prompts.md` — adapt the "patterns to attack" list to the work type

The prompt has three load-bearing pieces:

1. **Explicit license to disagree.** "Don't be polite. If the plan is fundamentally muddled, say so." Without this, GPT-5.5 will still hedge.
2. **An enumerated list of mistake classes** to score the plan against. Generic "review this" prompts get generic findings.
3. **A bias toward simpler / smaller / deletion.** Default to "remove this," not "preserve this." Default to "let the schema drop a field" over "hardcode it for compatibility." Cleanup work especially.

Run the pass **twice on most non-trivial work**:

- **Pre-edit pass** — input is the plan + surface area. Catches design errors while changes are cheap.
- **Post-edit pass** — input is the diff. Catches "what you actually shipped diverges from what you said you'd do" — the highest-leverage moment because the failure mode of the pre-edit pass is "the plan was fine but the implementation slipped."

### Step 3 — Triage findings

The agent will return a list of findings, usually with severity. Sort them yourself, don't just adopt all of them:

| Adopt | Why |
| --- | --- |
| Anything that prevents a regression (downstream consumer broken, behavior changed silently, kill-switch bypassed). | Non-negotiable. |
| Anything that simplifies the diff without changing behavior (delete the field, drop the helper, remove the defensive `*bool`). | Cleanup work earns its name only if it's actually clean. |
| Findings that catch a mismatch between PR body / commit message and the actual diff. | These will block CCR rounds otherwise. |

| Set aside | Why |
| --- | --- |
| Findings that ask for scope creep ("while you're here, also refactor X"). | Out of scope. Note them; open a follow-up if worthwhile. |
| Findings based on the agent misreading the constraints you stated. | Re-prompt with sharper constraint wording, don't argue. |
| Stylistic preferences (naming, formatting) when the project has its own conventions. | Project conventions win. |

When in doubt, run a second pass with the disagreement included as a counter-argument — *"the agent says X, my reasoning is Y; who's right?"* GPT-5.5 will defend or recant.

### Step 4 — Apply the catches and re-run if needed

If the post-edit pass found something material, fix it, then run the post-edit pass *again* on the new diff. Two iterations is normal; three is rare; four+ means the underlying plan is wrong and you should go back to step 1.

### Step 5 — Report

When summarizing for the user (whether you ran this on your own initiative or because they asked), surface:

- What classes of mistake you tested for
- The findings adopted (and the resulting changes)
- Findings deliberately set aside, with the reason
- Any disagreements with the agent that you defended

This makes the adversarial pass auditable — the user can second-guess your triage if they want, instead of trusting that "I checked, it's fine."

## Output Format

When invoking the skill on the user's behalf, your response after the pass should look like:

```text
Adversarial review (GPT-5.5 high) — <plan name or PR ref>

Findings adopted:
  • <one-liner finding> → <fix applied>
  • …

Findings set aside:
  • <one-liner finding> — out of scope (will follow up in <issue/PR>)
  • <one-liner finding> — agent misread the constraint that <X>

Disagreements I defended:
  • <one-liner> — agent recommended X; my reasoning is Y; …

Net diff impact: +N/-M lines, <files> files
```

If the pass returned no material findings, that's fine and worth reporting — it's evidence that the work is cleaner than the cost of the pass. Don't manufacture findings to justify having run it.

## Boundaries

**Will:**
- Frame plans, diffs, and designs adversarially using GPT-5.5 high.
- Surface findings sorted by what to adopt, set aside, or push back on.
- Loop the pass when a fix surfaces a new question.
- Cross-link from cleanup-heavy skills (e.g. `remove-feature-flag`) so they don't each duplicate the prompt.

**Will Not:**
- Auto-trigger on every interaction. Adversarial passes are slow and noisy on trivial work.
- Replace human review or CCR — it's a *pre-flight* check, not a substitute for someone signing off.
- Adopt every finding blindly. Triage is the user's (or your) job.
- Use the same model lineage as the host agent — defeats the purpose.

## References

- [`references/prompts.md`](references/prompts.md) — ready-to-paste prompt templates for plan review, diff review, and design review.
- [`references/catches.md`](references/catches.md) — known high-value catches by work type (FF cleanup, refactor, schema change, performance, dependency bump). Seeded from real production misses.

## Related Skills

- `remove-feature-flag` — calls this skill at step 4 (pre-edit) and step 6 (post-edit).
- `manage-pr` — when CCR rounds keep oscillating on the same theme, that's a signal to invoke this skill before the next push.
- `create-pr` — invoke before opening a PR with a non-trivial body, to catch pivot-mismatched descriptions.
