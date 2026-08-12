# Known high-value catches by work type

Seeded from real production misses. Worth more than the generic checklist, because each one
shipped past a human reviewer at least once.

Find the work type that matches the diff. Read that section. Skip the rest.

---

## Feature-flag cleanup

The single most under-reviewed work type. It reads as deletion, so reviewers skim it.

- **The flag is still checked somewhere the diff didn't touch.** Grep the flag name across
  the whole repo, not just the changed files. Background jobs, serializers, admin tooling,
  and templates are the usual survivors.
- **The wrong branch was kept.** The retained code is the `false` path, not the `true` path.
  Read the original conditional before the diff removed it.
- **The flag was checked with a default.** `flag_enabled?(x) || legacy_behaviour` collapses
  differently than the author expected once the check is gone.
- **Config, seeds, and test fixtures still set the flag.** Now a no-op that silently lies to
  the next reader.
- **Cleanup left the plumbing.** A method whose only job was reading the flag now takes an
  argument nobody varies. The right answer is delete more, not preserve the signature.
- **Kill-switch removed while the incident it guarded is still possible.** Ask what the flag
  was protecting against, not just whether it's rolled out.

## Refactor / "no behaviour change"

The claim is the thing to attack. Refactors that claim no behaviour change usually have one.

- **Extraction changed evaluation order.** Code moved above or below a side effect, an early
  return, or a transaction boundary.
- **Extraction changed laziness.** An enumerable became an array, or a query became eager or
  N+1. Check every `.map` / `.each` / `.select` that moved across a method boundary.
- **Nil and empty handling shifted.** The old inline code returned `nil`; the new helper
  returns `[]`, `0`, or raises. Callers care.
- **Exception surface changed.** The extracted method raises where the inline version
  rescued, or the rescue now wraps more than it used to.
- **Memoization moved.** `@x ||=` inside a method that's now called on a fresh instance per
  request is no longer memoized, or is now memoized across requests when it shouldn't be.
- **Tests were rewritten in the same commit.** If the tests changed to match the new code,
  they can no longer prove the behaviour didn't change. That's a finding.
- **Public method deleted or renamed** with callers outside the repo (API, gem, generated
  client, other service). Search beyond the module.

## Schema / migration change

- **Destructive before additive.** Dropping or renaming a column in the same deploy as the
  code that stops using it. Old pods will still reference it during rollout.
- **Not backwards-compatible during deploy.** For a window, old code and new schema coexist.
  Walk that window explicitly.
- **`NOT NULL` added without a backfill**, or with a backfill that isn't chunked and will
  lock the table.
- **Index added without `CONCURRENTLY`** (Postgres) on a table large enough to matter.
- **Down migration doesn't work after the up ran against real data.** Dropping a column is
  reversible in schema and irreversible in data. Say so.
- **The model, serializer, factory, fixture, or GraphQL type wasn't updated** alongside the
  column.
- **Default added to an existing column** — check whether it applies to existing rows on
  this database version, and whether the app now writes two different defaults.
- **Uniqueness enforced in the app but not the database**, or vice versa.

## Performance work

- **Measured the wrong thing.** The PR claims a speedup; the benchmark covers a path that
  isn't hot, or measures a warm cache.
- **Caching added without an invalidation path.** Ask what writes the underlying data and
  whether it busts the key.
- **Cache key omits a variable the value depends on** — tenant, locale, user, feature flag,
  permission scope. This is the classic cross-tenant data leak.
- **N+1 "fixed" with an eager load that pulls far more rows** than the N+1 did.
- **Batching added without an upper bound**, or with a bound that isn't enforced on the
  input.
- **Concurrency added** — threads, goroutines, async jobs — over code that was safe only
  because it was serial. Look for shared mutable state and non-atomic read-modify-write.
- **Timeouts removed or raised** to make something "work". That's usually the symptom, not
  the fix.

## Dependency bump

- **The changelog wasn't read.** Look for behaviour changes between the pinned versions, not
  just the CVE it claims to fix.
- **Major version bump described as a patch bump.** Check the actual semver delta.
- **Lockfile changed without the manifest**, or vice versa. Transitive upgrades hidden in a
  lockfile-only diff are worth a look.
- **A pin was loosened** (`~>` to `>=`, exact to caret) as a side effect.
- **Vendored or generated code wasn't regenerated** to match.
- **The bump silently changed a default** — TLS version, timeout, retry policy, JSON
  encoding, timezone handling.

## Bugfix

- **Fixes the symptom at the call site** when the defect is in the shared code. New nil
  guard, new `?.`, new rescue — ask why the value is nil, and whether every other caller has
  the same hole.
- **No regression test**, or a test that would pass against the unfixed code. Re-read the
  test against the pre-fix implementation and ask honestly whether it fails.
- **The root cause is stated in the PR body but not addressed** by the diff.
- **The same bug exists in a sibling code path** the diff didn't touch.

## New endpoint / public surface

- **Authorization checked at the controller but not the object.** Or checked for read and
  not for write.
- **No pagination, no limit,** on something that returns a collection.
- **Params not constrained** — mass assignment, unbounded array, unvalidated enum.
- **Rate limiting and abuse considerations absent** on an unauthenticated route.
- **The response shape leaks a field** that wasn't in the serializer before.
- **Errors return 200,** or return a stack trace, or leak internal IDs.

## Async jobs / background work

- **Not idempotent.** Retries are guaranteed, not hypothetical. Walk a double-execution.
- **Enqueued inside a transaction** that may roll back after the job already picked it up.
- **Arguments are objects, not IDs** — the job will deserialize stale or missing records.
- **No dead-letter or failure path**, or failures are swallowed and counted as success.
- **Schedule change** (cron, interval) without checking overlap with the previous run's
  runtime.
