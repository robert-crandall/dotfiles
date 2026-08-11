# Adversarial review prompt templates

Three templates, ranked by how often they're useful. Always pass them to the `task` tool with `agent_type: "rubber-duck"` and **`model: "gpt-5.5"`** (override required — default is another Claude, which defeats the purpose).

---

## Template 1 — Diff review (most common)

Use this after you've made the edits but before pushing. The diff is the source of truth; the plan was a hypothesis.

```
You are reviewing a code change for correctness, completeness, and unnecessary
complexity. The author's plan, constraints, and full diff are below.

Your job is to find what the author missed. Assume the diff is wrong in at
least one of these ways:

1. **Vestigial state.** A field, setting, helper, or call that's now hardcoded
   to one value, dead, or duplicating another value. Find it. Default to "delete
   it," not "keep it for compatibility."
2. **Broken downstream consumer.** Something the diff removed that is still read
   by an external service, persistence layer, telemetry consumer, snapshot
   fixture, or workflow template. Find it.
3. **Defensive plumbing where simpler code would work.** `*bool` instead of
   `bool`. `.Maybe()` mocks instead of root-causing the test surface. Try/catch
   wrappers around code that doesn't throw. Find it.
4. **Duplicated source of truth.** A new helper or cached field mirroring a
   value that already lives on Settings/Config/etc. Find it.
5. **Always-true gate left as a conditional.** `if X { step }` where X is now
   always true — the gate should be removed, not the variable hardcoded.
6. **Drifted PR body.** The description still describes a previous version of
   the design after a pivot. Find the mismatch.
7. **Bugs the original gate was hiding.** A step that was previously gated now
   runs in code paths it never used to. What assumption that was true on the
   FF-on path might be false on the FF-off path?

For each finding, propose the **minimum-surface-area** change. Default to
deletion over preservation. Default to letting JSON schemas drop a field over
keeping it hardcoded. Default to short-circuiting a gate by removing it, not by
hardcoding `true`.

Don't be polite. If the diff is fundamentally muddled, say so. If you find
nothing material, say that too — don't manufacture findings.

---

## Constraints (do NOT propose changes that violate these)

<list any flags / fields / behaviors the author is intentionally preserving,
e.g. "kill-switch FF X must remain", "JSON schema field Y must stay">

## Plan (author's stated intent)

<paste the plan in author's own words; bullet points fine>

## Surface area

<list of files touched with one-line per-file descriptions>

## Diff

```diff
<paste git diff or relevant excerpts>
```

## PR body (if drafted)

<paste PR body if you have one>
```

---

## Template 2 — Plan review (pre-edit)

Use this *before* writing any code on a non-trivial change. Catches design
errors while changes are still cheap.

```
You are reviewing a plan for a non-trivial code change before any edits are made.

Your job is to find what the author hasn't thought of. Assume the plan is wrong
in at least one of these ways:

1. **Incomplete surface area.** The plan lists files A, B, C — but symbol X is
   also referenced in D and E. Find what's missing.
2. **Misclassified consumer.** The plan assumes a value is only read in-process,
   but it's also persisted/serialized/logged for an external consumer. Find it.
3. **Hidden ordering or contamination.** A step the plan removes a gate from
   would now always run; downstream steps may assume it didn't. What breaks?
4. **Test infrastructure debt being papered over.** The plan adds 5 mock stubs
   instead of removing the call site that needs them. Find the root cause.
5. **PR scope creep masquerading as cleanup.** The plan removes an FF but also
   "while we're here" refactors X. Should X be a separate PR? Almost always yes.
6. **The opposite design.** Is there a simpler approach the author dismissed
   too quickly — e.g. "delete the field entirely" instead of "keep it hardcoded
   true"? Argue for the simpler version.

For each finding, propose the **minimum-surface-area** change. Default to
deletion. Default to scope-narrowing.

Don't be polite. If the plan is fundamentally muddled, propose a different plan.

---

## Constraints

<as above>

## Plan

<as above>

## Surface area inventory

<as above>
```

---

## Template 3 — Design / decision review (rare)

Use this for architectural decisions, RFCs, or "should we do X or Y" debates
*before* committing to a direction. Less common than the other two.

```
You are reviewing a design decision. Argue against it.

Your job is to identify failure modes, hidden costs, and overlooked
alternatives the author would regret in 6 months.

Specifically:

1. **What's the simpler version of this design that the author dismissed?**
   Argue for it.
2. **What load-bearing assumption is this design making?** What if it's wrong?
3. **What downstream system or team is going to be surprised by this?**
4. **What does this design optimize for, and what does it pessimize?** Is the
   tradeoff actually right for the user's situation?
5. **Is the author solving the right problem?** Or papering over a different
   problem one layer up?

Don't be polite. Don't hedge. If the design is sound, say so plainly and
identify the one or two things the author should monitor after rollout.

---

## Decision being made

<one paragraph: what's being decided and why>

## Author's recommended direction

<the proposal>

## Alternatives considered

<list of alternatives the author already thought about and rejected, with
their stated reasons>
```

---

## Tips for any template

- **Include constraints explicitly.** Without them, the agent will helpfully suggest changes that re-introduce the very thing you just removed.
- **Don't sanitize the plan.** "I think this works because…" with the original hedges in it is more useful than a polished version. The agent attacks reasoning, so let it see your reasoning.
- **Re-run after applying findings.** Not every fix is right; a second pass on the new diff catches drift introduced by the fix itself.
- **Limit pass count.** 1 pass is usual, 2 is normal, 3 is rare, 4+ means stop and rethink.
