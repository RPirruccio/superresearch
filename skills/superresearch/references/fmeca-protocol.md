# FMECA Protocol

Failure Mode, Effects, and Criticality Analysis — applied to the verify command itself. The point: catch invalid metrics before the build loop starts.

## When to Run FMECA

1. **Step 2 (Validate the Measure):** After metrics are defined, before any code
2. **Step 3d (Post-loop validation):** After the build, comparing metric deltas to observed behavior
3. **Any time the verify command changes:** Re-run on the delta

## The Three Questions

For each verify command in metrics.md, answer these three questions. A "yes" to any = P0 failure. Revise the metric before proceeding.

### Question 1: Invariance

**Is the metric invariant under experimental manipulation?**

Will this metric measure the same underlying dimension regardless of what the agent changes? If the agent can shift what the metric measures by changing vocabulary, naming conventions, or surface structure — the metric is vocabulary-dependent and invalid.

- val_bpb: INVARIANT — measures compression quality regardless of what tokens the model uses
- "grep -c TODO": NOT INVARIANT — agent can rename TODOs to FIXMEs and the count drops
- yield: INVARIANT — chip works or it doesn't, regardless of process tweaks

**Test:** Describe two changes that improve reality equally. Does the metric move the same amount for both? If not, it's measuring the change, not the outcome.

### Question 2: Sufficiency

**Does passing this metric guarantee the goal dimension is satisfied?**

Can the underlying thing the metric is supposed to measure be broken while the metric still reads "pass"? If yes, the metric is insufficient — it's measuring a proxy, not the thing.

- "tests pass": INSUFFICIENT — you can delete tests and they still "pass"
- val_bpb below threshold: SUFFICIENT — model must actually compress text well
- "build succeeds": INSUFFICIENT — broken code can compile fine

**Test:** Describe a way to make the metric pass while the actual goal is failed. If you can describe one, add a guard or replace the metric.

### Question 3: Strategyproofness

**Can an intelligent agent improve this metric without improving reality?**

This is the Goodhart test, formalized as strategyproofness (mechanism design, Hurwicz 2007). A metric is strategyproof when the optimal strategy for any agent is to actually improve the underlying reality — there is no shortcut, no gaming path.

- "FMECA checklist score": NOT STRATEGYPROOF — check boxes without reading them
- val_bpb on held-out set: STRATEGYPROOF — must actually model language better
- "line coverage %": NOT STRATEGYPROOF — write tests that execute lines without asserting anything

**Test:** If you gave this verify command to an adversarial agent whose only goal was to maximize the number, could it succeed without the real thing improving? If yes, the metric is not strategyproof.

**Critical rule:** If your "Yes" requires conditions, caveats, or assumptions not enforced by the verify command itself, the answer is "No." Conditions that exist only in prose but not in the command are not enforceable. Fix the command, then re-answer.

## Output Format

For each metric, record the three answers:

| Metric | Invariant? | Sufficient? | Strategyproof? | Verdict |
|--------|-----------|-------------|----------------|---------|
| {name} | Yes/No — {reason} | Yes/No — {reason} | Yes/No — {reason} | VALID / REVISE |

Any "No" = REVISE. All three "Yes" = VALID. No exceptions.

## Severity Definitions

| Level | Meaning | Action |
|-------|---------|--------|
| **P0** | Metric fails any of the three questions | MUST revise metric before build loop starts |
| **P1** | Metric is borderline — passes but with caveats | Add guards to close the gap |
| **P2** | Metric is valid but could be more precise | Acceptable, refine if time permits |

## FMECA -> Fix Loop Integration

After FMECA produces findings:

1. Revise metrics that fail any of the three questions
2. Update verify commands to match revised metrics
3. Re-run FMECA to confirm all three questions pass
4. Only proceed to the build loop when every metric is VALID

## Post-Loop FMECA (Step 3d)

After the build loop completes, run FMECA again but now check:
- Did the metric actually track reality? Compare metric deltas to observed behavior.
- Did the agent find ways to game the metric that weren't caught in Step 2?
- Any drift between what the metric measured and what actually improved?

If gaps are found, return to the build loop to close them.
