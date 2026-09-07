---
name: implement
description: 'Builds a non-trivial code change through a staged pipeline — scope, plan, plan review, implement, code review, verify, PR — each stage run as a separate sub-agent on a different model with a clean context, handing off through files. Use when the user asks to build a feature, do a refactor, fix a non-obvious bug, change a schema or interface, or says "implement this", "run the pipeline", or "plan this properly". Also use when a change touches more than two files or adds a migration. Do not use for typo fixes, one-line changes, or questions about existing code.'
---

# Staged Implementation

Seven stages. Each runs as a separate `task` sub-agent pinned to a different model,
reading files and writing a file. No stage inherits the previous stage's conversation.

The file handoff is the whole point. A reviewer that already saw the reasoning behind
the thing it is reviewing is a rubber stamp.

You are the orchestrator. You do not scope, plan, implement, review, verify, or open the
PR yourself — you size the work, run the stages, hold the gates, and settle unresolved
disagreements without stopping the pipeline.

**The run is fully autonomous.** From the moment you start until the final report, do not
ask the user anything and do not wait for confirmation at any gate. Every open question,
disagreement, and block is yours to decide. Record each call in the run artifacts and
report them all at the end. A pipeline that stops halfway to ask a question is worse than
one that makes a defensible call and says so.

## 1. Size the work first

State the tier and why, in one line, before doing anything else. Running seven stages on a
small change is worse than running none.

| Tier | Looks like | Run |
|---|---|---|
| 0 | One file, under ~30 lines, no interface change, the fix is obvious | Nothing. Just do it and say why you skipped the pipeline. |
| 1 | One subsystem, no schema or public interface change, plan fits in a paragraph | Stages 2, 4, 6 |
| 2 | Multi-file, new or changed interface/schema/migration, or you cannot state the plan in one paragraph | All seven |

If unsure between 1 and 2, pick 2.

Stage 7 is separate from the tier. Run it whenever the change lands through a pull
request, at any tier — including tier 1. Skip it when the user is working locally, on
`main`, or has said they'll open the PR themselves.

Do not pause for confirmation before stage 7. Once verification passes and stage 7
applies, open the PR immediately.

**Complete when:** the tier is stated. Do not wait for the user to agree with it.

## 2. Set up the run

Pick a short kebab-case `<slug>` for the task. All artifacts go to `.copilot/runs/<slug>/`.

```
.copilot/runs/<slug>/
├── 00-scope.md        stage 1
├── 01-plan.md         stage 2
├── 02-plan-review.md  stage 3
├── 03-impl-notes.md   stage 4
├── 04-code-review.md  stage 5
├── 05-verify.md       stage 6
└── 06-pr.md           stage 7
```

Create the directory and make sure `.copilot/runs/` is in `.gitignore`. These are working
artifacts, not documentation.

## 3. Run the stages

Every stage is one `task` call with `agent_type: "general-purpose"` and `mode: "sync"`.
Sub-agents are what give each stage a clean context window; they share the working tree,
which stages 4 through 6 need.

Run stages one at a time. Never launch two in parallel — each one's input is the previous
one's output.

| # | Stage file | `model` | `reasoning_effort` | Reads | Writes |
|---|---|---|---|---|---|
| 1 | `scope.agent.md` | `claude-sonnet-5` | `medium` | repo, task description | `00-scope.md` |
| 2 | `plan.agent.md` | `claude-opus-5` | `high` | `00-scope.md`, repo | `01-plan.md` |
| 3 | `plan-review.agent.md` | `gpt-5.6-sol` | `high` | `01-plan.md`, the code it touches | `02-plan-review.md` |
| 4 | `implement.agent.md` | `gpt-5.6-sol` | `medium` | `01-plan.md`, `02-plan-review.md` | code, `03-impl-notes.md` |
| 5 | `code-review.agent.md` | `gpt-5.6-sol` | `high` | diff, `01-plan.md`, `03-impl-notes.md` | `04-code-review.md` |
| 6 | `verify.agent.md` | `gpt-5.6-terra` | `low` | repo, `01-plan.md` | `05-verify.md` |
| 7 | `pr.agent.md` | `claude-sonnet-5` | `medium` | `01-plan.md`, `04-code-review.md`, `05-verify.md` | PR, `06-pr.md` |

**Never name an input file that does not exist.** At tier 1, stages 1 and 3 never run, so
`00-scope.md` and `02-plan-review.md` are not there. Drop them from stage 2's and stage 4's
input lists and say in the prompt that the run is tier 1, rather than pointing a stage at a
missing file and letting it decide what that means. Same rule for any rerun: list only what
has actually been written.

Stage 1 is deliberately not the strongest model — that work is retrieval, not reasoning.
Stage 4 is deliberately medium effort; high effort there makes the model relitigate
decisions stages 2 and 3 already settled. Stage 7 is a different vendor from stage 4 on
purpose: if the model that wrote the code also judged whether review comments on it were
valid, `false-positive` becomes the easy way out.

Stage 7 is the only stage whose output other people see. It opens a real PR and posts real
comments, so a bad call there costs someone else's attention.

### Stage prompt template

```
You are stage <n> of a staged delivery pipeline.

Read the stage file at <absolute path to ~/.copilot/skills/implement/agents/<stage>.agent.md>
and follow it exactly — it is your full instruction set, including the output format
and the things you must not do. Ignore its YAML frontmatter; your model and effort
are already set.

Task: <one-line task description>
Run directory: <abs path>/.copilot/runs/<slug>/

Read exactly these inputs and nothing else from the run directory:
<explicit list from the table above>

Write your output to <abs path>/.copilot/runs/<slug>/<output file>.
Report back only your verdict/status line and a two-sentence summary.
```

**Paths must be absolute.** Sub-agents cannot expand `~`. Substitute the real home
directory in both the stage-file path and the run directory before sending the prompt.

**Sub-agents have no channel to the user.** They cannot ask questions and cannot invoke
skills. Anything that needs a human decision comes back to you.

**Pass only the inputs the table names.** Do not helpfully forward extra context — handing
stage 3 the reasoning behind the plan is exactly what defeats stage 3. Do not paste a
previous stage's summary into the next stage's prompt; the file is the handoff.

## 4. Gates

Hold these yourself between stages. A gate the orchestrator waves through is not a gate.

- **After stage 1** — do not stop. Answer the questions in `00-scope.md` yourself, highest
  ranked first, using the repo, the task description, and stage 1's own `## Assumptions`
  section. Write them into `00-scope.md` under an `## Answers` heading, each one marked
  `[decided by orchestrator]` with a one-line reason, before starting stage 2. Where the
  facts genuinely don't settle it, pick the option that keeps the change smallest and most
  reversible, and prefer matching what the codebase already does over introducing a new
  pattern. Every question gets an answer — leaving one open makes stage 2 guess silently,
  which is the thing stage 1 exists to prevent. If stage 1 wrote "None", continue.
  Surface the decisions in the final report, not before.
- **After stage 3** — read the verdict.
  - `APPROVE` → stage 4.
  - `APPROVE_WITH_CHANGES` → stage 4, and the binding changes are binding.
  - `REJECT` → back to stage 2, with `02-plan-review.md` added to its inputs. Let the
    planner and reviewer attempt at most two consecutive disagreement rounds before
    applying the disagreement budget below.
- **During stage 4** — if it returns `BLOCKED`, do not fix it yourself and do not rerun it
  with encouragement. Read `03-impl-notes.md`, decide the open question yourself, and go
  back to stage 2 with your decision. Do not stop to ask the user. Pick the option that
  keeps the change smallest and most reversible; when the scope answers or `01-plan.md`
  already imply a direction, follow it. Record the call in `00-scope.md` under an
  `## Orchestrator decisions` heading — creating that file if tier 1 means it doesn't
  exist yet — mark it binding, and add it to stage 2's inputs. Tell the user what you
  decided in the final report, not before.
- **After stage 5** — `BLOCK` sends the blocking findings back to stage 4 (inputs:
  `01-plan.md`, `02-plan-review.md` if it exists, `04-code-review.md`). Non-blocking
  findings get recorded and left alone.
- **After stage 6** — `FIXED` is fine. `ESCALATED` goes back to stage 2, not stage 4:
  if the plan didn't cover it, implementing a fix means designing without a plan.
  Only `PASS` or `FIXED` may enter stage 7. Enter it immediately without asking the user
  to confirm opening the PR.
- **After stage 7** — read `06-pr.md`. Anything it escalated goes back to stage 2. If it
  stopped short of auto-merge — unresolved human comment, `changes-requested`, conflicts,
  a `must-fix` it replied to but didn't fix, scope creep, or its own three-round budget —
  hand that to the user instead of rerunning it.

**Disagreement budget:** allow two consecutive stage 2/stage 3 disagreement rounds. If
the models still disagree and a third round would begin, do not stop the run and do not
ask the user. Arbitrate yourself: read `01-plan.md` and `02-plan-review.md`, and pick the
approach with the better correctness argument. When correctness is a wash, pick the
smaller, more reversible one. A reviewer objection that names a specific file, line, or
caller beats a planner objection that argues from the plan's own account of the code.

Record the selected approach in `02-plan-review.md` under an `## Orchestrator arbitration`
heading, with the reason, mark it as binding, and continue with stage 2. The selected
approach settles that disagreement unless later stages uncover new correctness evidence.
A disagreement, an exhausted disagreement budget, or a model repeating a settled objection
is never a reason to end the pipeline.

**Loop budgets.** Nothing pauses for a human any more, so every loop needs its own
terminator. Count rounds yourself and enforce these:

| Loop | Budget | When it runs out |
|---|---|---|
| stage 2 ↔ stage 3 | 2 rounds | Arbitrate, as above, and continue |
| stage 5 → stage 4 | 2 rounds | Record the remaining findings as non-blocking, note them in the report, and continue to stage 6 |
| stage 6 → stage 2 | 2 rounds | Stop the run. Report the escalation and leave the branch unmerged |
| whole pipeline | 20 stage calls | Stop the run and report where the calls went |

Two of those exits stop the pipeline, which the rest of this document tells you not to do.
The difference is that these are terminal and reported, not a mid-run question. A loop with
no exit is not autonomy; it is a run that never ends and nobody is watching.

A stage 6 escalation that survives two replans is a design problem the pipeline cannot
solve by trying harder. Say what keeps failing and hand it over.

## 5. Report

When the run finishes, give the user:

- The tier, and which stages ran.
- Stage 3 verdict, stage 5 verdict, stage 6 status.
- The PR URL and whether auto-merge is enabled, if stage 7 ran.
- Anything escalated or left uncovered.
- Every decision you made on the user's behalf — scope answers, stage 2/3 arbitration,
  stage 4 `BLOCKED` calls — each with its reason, in one line apiece. This is the part
  the user most needs to check, so do not bury it.
- The path to the run directory.

Then append one line to `.copilot/runs/log.md`:

```
<date> | <slug> | tier <n> | stages rerun: <list> | caught at 3: <n> | caught at 5: <n> | caught at 7: <n>
```

That log is the only way to find out whether the pipeline earns its latency. If stages 3
and 5 stop catching things, drop them. If defects keep landing after merge, the plan
format is the problem, not the models. If stage 7 keeps catching `must-fix` comments,
stage 5 is being too easy.

**Complete when:** the report is delivered and the log line is appended.

## What each stage must not do

The stage files enforce this, but as the orchestrator you should notice when one drifts.
Every stage's failure mode is doing the next stage's job.

| Stage | Must not |
|---|---|
| scope | Propose a solution, write code, or ask questions whose answers wouldn't change the design |
| plan | Write implementation code, or leave the rollback story unstated |
| plan-review | Manufacture objections to look useful, or approve without naming what it checked |
| implement | Deviate from the plan without stopping, or refactor adjacent code |
| code-review | Comment on formatting or style — the linter owns that |
| verify | Fix a failing test by changing the test |
| pr | Make a check pass by weakening the check, resolve a human's thread, or design a fix the plan never covered |
