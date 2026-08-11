# Known high-value catches by work type

Seeded from real production misses. Use as a checklist when scoring adversarial findings — if the agent didn't catch one of these but it applies to your diff, prompt it again with the specific question.

## Feature flag removal

| Pattern | Symptom | Fix |
| --- | --- | --- |
| Field deleted, but downstream reader (workflow monitor, datastore consumer, telemetry pipeline) still reads its JSON tag. | Persisted reviews lose the key, downstream branches dispatch wrong / classify as "unknown". | Restore the field; populate from the now-unconditional resolver. The base FF can still be deleted. |
| Field kept hardcoded-true with vestigial ExP read (`_ = assignment.GetBool(...)`) and an override in `generateFromDatabase`. | Dead code; misleading test surface; reviewer comments will all push to *restore* the field. | Delete the field. If a downstream binary needs the key in its flag map, hardcode the literal in the *one* place that emits it (e.g. `agent.go`). |
| Defensive `*bool` introduced in observability-only consumer to distinguish "field absent" from "field false". | Adds nil-check noise; legacy persisted rows now classify as "unknown" instead of their real value. | Keep `bool`. Observability tags can be slightly stale on historical rows. |
| Shortcut helper duplicates `Settings.X` (or similar); both are populated from the same source. | Two sources of truth. Future drift inevitable. | Delete the helper; read `Settings.X` directly. |
| Sub-agent adds 5+ `.Maybe()` mocks across test files instead of asking why the test surface area suddenly grew. | Production gate stopped short-circuiting → tests now hit a code path they never did. | Either restore the short-circuit (extract resolution into a helper that's testable in isolation), OR refactor the test helper to bypass `NewExecution`/`ResolveSettings` entirely. |
| `if FF { step }` becomes `if true { step }` after the FF read is removed. | Dead conditional left in the code; reviewers will ask why. | Remove the gate; if the step now runs in code paths it never used to, recheck "bugs the gate was hiding." |
| PR description still describes the previous design after a pivot. | CCR comments will all push you to undo the pivot. | Update the PR body *first*, then resolve threads pointing at the body. |

## Refactor / dead code removal

| Pattern | Symptom | Fix |
| --- | --- | --- |
| Removed code that looked dead but was actually load-bearing for a build tag, a test file, or a code-generation tool. | CI fails on a build target you didn't run locally; or a generator stops emitting something. | Run the broader build matrix; inspect generators referenced in `go:generate`/equivalent. |
| Renamed a public symbol that an external consumer (other repo, vendored package) imports. | Compile breaks downstream after merge. | Search across owning org; either keep an alias, or coordinate the rename. |
| Inlined a helper at call sites and now each call site has the same 5-line block. | Unintended duplication; later changes have to be made N times. | Keep the helper, even if you removed its abstraction. |
| Replaced an interface with a concrete type "since there's only one impl." | Mocking infra in tests breaks; future second impl now requires a refactor. | Keep the interface unless you're confident the mock layer doesn't need it. |

## Schema / persistence changes

| Pattern | Symptom | Fix |
| --- | --- | --- |
| Field removed from a struct with a JSON tag; struct is persisted (CosmosDB, blob store, Kafka payload). | Older serialized rows can still be unmarshaled (good); but downstream consumers querying the JSON key now see nothing. | Audit consumers in *all* repos that read the persistence layer, not just the one you're editing. |
| Required field changed to optional. | Old code paths producing the field still work; new code paths may emit nil and consumers crash. | Sweep every producer; consider a migration window with both forms supported. |
| Enum value renamed; old serialized values still in the data store. | Reads of historical rows fail to deserialize. | Keep the old name as an alias; add a migration. |
| Telemetry field removed. | Splunk / Kusto / Datadog dashboards quietly start showing zero/null on that field. | Search org-wide for the field name in queries; coordinate the dashboard update. |

## Performance changes

| Pattern | Symptom | Fix |
| --- | --- | --- |
| Cache added in front of a function with side effects. | Stale data; second-call behavior diverges from first-call. | Caches go in front of pure reads only. If the function has side effects, cache the result *and* the side-effect fingerprint, or don't cache. |
| Parallelism added without a backpressure mechanism. | Resource exhaustion under load (DB connections, memory, file handles). | Add a `MaxParallelism` knob; default conservative. |
| Loop replaced with goroutines but the closure captures a loop variable. | Classic Go bug; all goroutines see the last value. | Capture by parameter, not by closure. (Pre-Go-1.22.) |
| Eager fetch turned into a lazy fetch. | First request after a cold start is now slow; latency dashboards spike. | Add a warmup or accept the trade-off explicitly. |

## Dependency / version bumps

| Pattern | Symptom | Fix |
| --- | --- | --- |
| Major version bump that the changelog says is API-compatible. | Subtle behavior changes (default value flipped, error type renamed) that don't show in `go vet`. | Read the changelog *and* the diff between the tagged versions for files you actually use. |
| Indirect dependency upgraded transitively. | Behavior change you didn't intend. | `go mod why <package>` to confirm intended; pin if necessary. |
| Fork removed in favor of upstream. | Patches that lived in the fork are now silently absent. | Diff the fork against upstream before removing; cherry-pick or upstream the patches first. |

## How to use this list with the adversarial agent

After the agent returns its findings, scan this table for the work type at hand. If a high-value catch isn't represented in the agent's findings *and it applies to your diff*, send a follow-up prompt naming the specific pattern:

```
You missed this pattern: <paste row from the table>.
Does it apply to my diff? If yes, what's the fix?
```

Faster than re-running the full pass and usually surfaces the catch.
