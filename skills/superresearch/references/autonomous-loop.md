# Autonomous Loop Protocol

The core build loop for Step 3. Plan-driven iteration: execute tasks from plan.md sequentially, verify after each, keep or discard. When all plan tasks are done (or the plan proves insufficient), switch to exploratory mode.

## Relationship to the Plan

In superresearch, Step 3 optionally includes `plan.md` — a sequence of tasks, each with a metric target. The autonomous loop **executes that plan**:

1. **Plan-driven mode (default):** Work through plan.md tasks in order. Each task = one iteration. The plan tells you WHAT to change; the loop tells you HOW to verify it.
2. **Exploratory mode (when plan is exhausted):** If all plan tasks are done but the metric target isn't hit, switch to freeform exploration — the priority order below applies.

Read `plan.md` at the start of the loop. Track which task you're on. If a task's change gets discarded, try an alternative approach for that same task before moving to the next one.

## Step 0: Baseline (Before Iteration 1)

Before making any changes, run the verify command on the current state and record the result as iteration 0 in results.tsv. This is the baseline. No baseline = no valid delta = no valid experiment.

```bash
# Run verify command on current state
BASELINE=$(bash scripts/verify.sh | tail -1 | grep -oE '[0-9]+')

# Record as iteration 0
echo "0	baseline	$BASELINE	0	-	baseline	initial state before any changes" >> results.tsv
```

**Rules:**
- The baseline MUST be recorded before any modifications
- If the verify command fails on the current state, fix the verify command — not the code
- The baseline is the denominator for all future deltas. Every "improvement" is measured against this number.
- If you skip the baseline, every delta you report is meaningless

## Loop Modes

- **Bounded (default in superresearch):** Loop for N iterations where N = number of tasks in the plan. If target is hit early, stop. If plan is exhausted and target not hit, switch to exploratory for remaining iterations.
- **Unbounded:** Loop until manually interrupted (`Ctrl+C`). Use for open-ended optimization after the plan is complete.

When bounded, track `current_iteration` against `max_iterations`. After the final iteration, print summary and stop.

## Step 1: Review (30 seconds)

Before each iteration, build situational awareness:

```
1. Read plan.md — which task are we on? What's the metric target for this task?
2. Read current state of in-scope files (full context)
3. Read last 10-20 entries from results.tsv
4. Read git log --oneline -20 to see recent changes
5. Identify: what worked, what failed, what's untried
6. If bounded: check current_iteration vs max_iterations
```

**Why read every time?** After rollbacks, state may differ from what you expect. Never assume — always verify.

## Step 2: Ideate (Strategic)

### Plan-Driven Mode (default)

Pick the NEXT task from plan.md. The plan already specifies what to build and what metric target to hit. Your job is to implement it and verify.

If the previous task's change was discarded, try an alternative implementation of the SAME task before moving on.

### Exploratory Mode (plan exhausted, target not hit)

When all plan tasks are complete but the overall metric target hasn't been reached, switch to freeform exploration. Priority order:

1. **Fix crashes/failures** from previous iteration first
2. **Exploit successes** — if last change improved metric, try variants in same direction
3. **Explore new approaches** — try something the results log shows hasn't been attempted
4. **Combine near-misses** — two changes that individually didn't help might work together
5. **Simplify** — remove code while maintaining metric. Simpler = better
6. **Radical experiments** — when incremental changes stall, try something dramatically different

**Anti-patterns:**
- Don't repeat exact same change that was already discarded
- Don't make multiple unrelated changes at once (can't attribute improvement)
- Don't chase marginal gains with ugly complexity

**Bounded mode:** If remaining iterations are limited (<3 left), prioritize exploiting successes over exploration.

## Step 3: Modify (One Atomic Change)

- Make ONE focused change to in-scope files
- The change should be explainable in one sentence
- Write the description BEFORE making the change (forces clarity)

## Step 4: Commit (Before Verification)

```bash
git add <changed-files>
git commit -m "experiment: <one-sentence description>"
```

Commit BEFORE running verification so rollback is clean: `git reset --hard HEAD~1`

## Step 5: Verify (Mechanical Only)

Run the agreed-upon verification command. Capture output.

**Timeout rule:** If verification exceeds 2x normal time, kill and treat as crash.

**Extract metric:** Parse the verification output for the specific metric number.

## Step 6: Guard (Regression Check)

If a guard command was defined, run it after verification.

**Key distinction:**
- **Verify** answers: "Did the metric improve?" (the goal)
- **Guard** answers: "Did anything else break?" (the safety net)

**Guard rules:**
- Only run if a guard was defined (it's optional)
- Run AFTER verify — no point checking guard if the metric didn't improve
- Guard is pass/fail only (exit code 0 = pass)
- If guard fails, revert and rework (max 2 attempts)
- NEVER modify guard/test files — always adapt the implementation instead

**Guard failure recovery (max 2 rework attempts):**
1. Revert the change (`git reset --hard HEAD~1`)
2. Read guard output to understand WHAT broke
3. Rework the optimization to avoid the regression
4. Commit reworked version, re-run verify + guard
5. If both pass → keep. If guard fails again → one more attempt, then discard

## Step 7: Decide (No Ambiguity)

```
IF metric_improved AND (no guard OR guard_passed):
    IF metric_barely_improved (<0.1%) AND change_adds_complexity:
        STATUS = "discard"  # simplicity override — marginal gain not worth complexity
    ELSE:
        STATUS = "keep"
ELIF metric_improved AND guard_failed:
    REWORK (max 2 attempts, then discard)
ELIF metric_unchanged AND change_simplifies_code:
    STATUS = "keep"  # simplicity override — simpler is better at same metric
ELIF metric_same_or_worse:
    STATUS = "discard"
    git reset --hard HEAD~1
ELIF crashed:
    Attempt fix (max 3 tries), then discard
    git reset --hard HEAD~1
```

The simplicity overrides are integrated into the decision tree, not applied after it. This ensures they're evaluated before the generic discard branch.

## Step 8: Log Results

Append to results.tsv using the 7-column format from `results-logging.md`:

```tsv
iteration	commit	metric	delta	guard	status	description
42	a1b2c3d	0.9821	+0.02	pass	keep	increase attention heads from 8 to 12
43	-	0.9845	+0.0024	-	discard	switch optimizer to SGD
44	-	0.0000	0.0	-	crash	double batch size (OOM)
```

## Step 9: Repeat

### Plan-Driven Mode (default in superresearch)

```
IF metric_target_achieved:
    Print: "Target achieved at iteration {N}! Final metric: {value}"
    STOP — proceed to post-loop validation (Step 3d)
ELIF plan_tasks_remaining:
    Go to Step 1 (next task from plan)
ELIF current_iteration < max_iterations:
    Switch to exploratory mode, go to Step 1
ELSE:
    Print final summary
    STOP — proceed to post-loop validation (Step 3d)
```

The loop terminates when the metric target is hit OR iterations are exhausted. Either way, post-loop validation (Step 3d) runs next.

### Unbounded Exploratory Mode (post-plan, open-ended optimization)

Go to Step 1. Keep optimizing until interrupted (`Ctrl+C`). Only use this when the plan is complete and the user wants to push the metric further.

### Bounded Mode
```
IF current_iteration < max_iterations:
    Go to Step 1
ELIF goal_achieved:
    Print: "Goal achieved at iteration {N}! Final metric: {value}"
    STOP
ELSE:
    Print final summary
    STOP
```

**Final summary format:**
```
=== Superresearch Build Complete (N/N iterations) ===
Baseline (iteration 0): {baseline} → Final: {current} (delta: {delta})
Keeps: X | Discards: Y | Crashes: Z
Best iteration: #{n} — {description}
```

The baseline value comes from Step 0. If no baseline was recorded, the summary is invalid.

### When Stuck (>5 consecutive discards)

1. Re-read ALL in-scope files from scratch
2. Re-read the original goal/direction from objectives.md
3. Review entire results.tsv for patterns
4. Try combining 2-3 previously successful changes
5. Try the OPPOSITE of what hasn't been working
6. Try a radical architectural change

## Crash Recovery

- Syntax error → fix immediately, don't count as separate iteration
- Runtime error → attempt fix (max 3 tries), then move on
- Resource exhaustion (OOM) → revert, try smaller variant
- Infinite loop/hang → kill after timeout, revert, avoid that approach
- External dependency failure → skip, log, try different approach

## Communication

- **DO NOT** ask "should I keep going?" — the loop has clear termination conditions (target hit or iterations exhausted). Follow them.
- **DO NOT** summarize after each iteration — just log and continue
- **DO** print a brief one-line status every ~5 iterations
- **DO** alert if you discover something surprising or game-changing
- **DO** print a final summary when bounded loop completes
