# Fix Loop Protocol

Autonomous fix loop for Step 2 / spec verification and any repair work. Detect → Prioritize → Fix ONE thing → Verify → Keep/Revert → Repeat until zero errors.

## When to Use

- **Step 2:** Fix the spec until verify-spec.sh returns 100/100
- **Step 3 build loop:** When the build loop hits errors that need systematic repair
- **Post-loop validation:** When validation reveals gaps between objectives and what was built

## Architecture

```
Fix Loop:
  ├── Step 1: Detect (what's broken?)
  ├── Step 2: Prioritize (fix order)
  ├── Step 3: Fix ONE thing (atomic change)
  ├── Step 4: Commit (before verification)
  ├── Step 5: Verify (did error count decrease?)
  ├── Step 6: Guard (did anything else break?)
  ├── Step 7: Decide (keep / revert / rework)
  └── Step 8: Log & Repeat
```

## Step 1: Detect

Run the verification command and capture all failures. For spec verification, this is `bash scripts/verify-spec.sh`. For build verification, this is the verify command from metrics.md.

## Step 2: Prioritize

### Code Mode (Step 3 build loop, post-loop validation)

Fix in this order (blockers first, polish last):

| Priority | Category | Why First |
|----------|----------|-----------|
| 1 | Build failures | Nothing works if it doesn't compile |
| 2 | Critical bugs | Data loss, security |
| 3 | Type errors | Type safety prevents cascading bugs |
| 4 | Test failures | Tests verify correctness |
| 5 | Lint errors | Code quality |
| 6 | Warnings | Polish |

### Spec Mode (Step 2 / spec verification)

When fixing a SPEC (not code), use this priority order:

| Priority | Category | Why First |
|----------|----------|-----------|
| 1 | Missing sections | Structural gaps — entire concerns not addressed |
| 2 | FMECA P0 findings | Objectives silently ignored, architecture contradictions |
| 3 | Completeness gaps | Error handling, test strategy, rollback plan missing |
| 4 | FMECA P1 findings | Metric false positives, significant gaps |
| 5 | Structural quality | Missing non-goals, unclear success criteria |
| 6 | FMECA P2 findings | Minor improvements |

**Key difference:** In code mode, you fix the implementation (not tests). In spec mode, you fix the spec content — add sections, flesh out detail, resolve contradictions. The "one fix per iteration" rule still applies: add ONE missing section, address ONE FMECA finding.

Within a category: cascading impact first, then simplicity, then file locality.

## Step 3: Fix ONE Thing

Pick the highest-priority unfixed item and make ONE focused change.

**Rules:**
- ONE fix per iteration. Not two. Not "while I'm here."
- Fix the IMPLEMENTATION, not the test (unless the test is genuinely wrong)
- Never suppress errors — no `@ts-ignore`, `eslint-disable`, `# type: ignore`
- Prefer minimal changes — smallest diff that fixes the issue

## Step 4: Commit Before Verification

```bash
git add <changed-files>
git commit -m "fix: [what was fixed] — [file:line]"
```

Commit BEFORE running verification. Enables clean rollback.

## Step 5: Verify

Re-run detection and compare:

```
previous_errors = error_count_before
current_errors = error_count_after
delta = previous_errors - current_errors
```

Expected: `delta > 0` (fewer errors than before)

## Step 6: Guard

If a guard command is specified, run it. Guard prevents regressions — fixing one thing shouldn't break another.

## Step 7: Decide

| Condition | Action |
|-----------|--------|
| `delta > 0` AND guard passes | **KEEP** |
| `delta > 0` AND guard fails | **REWORK** (max 2 attempts) |
| `delta == 0` | **DISCARD** — revert |
| `delta < 0` (more errors!) | **DISCARD** — revert immediately |
| Crash | **RECOVER** — revert, try simpler approach (max 3 attempts) |

## Step 8: Log & Repeat

Append to results log. Every 5 iterations, print progress:

```
=== Fix Progress (iteration 15) ===
Baseline: 62 errors → Current: 23 errors (-39, -63%)
Keeps: 11 | Discards: 3 | Reworks: 1
```

**Completion detection:**
```
IF current_errors == 0:
  PRINT "=== All Clear — Zero Errors ==="
  STOP (even in unbounded mode)
```

## Escalation Path

When 3 attempts at the same error fail:

1. **DOCUMENT:** What was tried, why each failed
2. **ISOLATE:** Create minimal reproduction
3. **SKIP:** Move to "blocked" list, continue with others
4. **FLAG:** Note in summary — "Error X requires investigation"

**Never loop on the same failing approach.** Each attempt must use a materially different strategy.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Do This Instead |
|--------------|----------------|-----------------|
| Suppress errors | Hides the problem | Fix the root cause |
| Delete failing tests | Removes safety net | Fix the implementation |
| Hardcode values to pass | Feature broken for real data | Fix the logic |
| Empty catch blocks | Bugs become invisible | Handle or re-throw |
| Comment out broken code | Never gets fixed | Fix it or delete it |
