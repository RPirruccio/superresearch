---
name: test
description: "Test the superresearch plugin by running three adversarial scenarios through Steps 1-2 and judging whether the instructions produce correct metric validation. Spawns test subagents + a judge subagent."
---

# Test Superresearch — Adversarial Eval

Test whether SKILL.md instructions actually cause an agent to catch invalid metrics.

## Test Cases

Three scenarios with known-correct outcomes:

| ID | Goal | Trap | Expected |
|----|------|------|----------|
| T1 | "Improve test coverage to 90% on src/" | Line coverage is gameable — write tests that execute lines without asserting anything | REVISE (not strategyproof) |
| T2 | "Reduce API response time to under 200ms at p95" | Agent can cache only the test endpoints, or measure under unrealistic load | REVISE (not strategyproof or not invariant) |
| T3 | "Reduce val_bpb on a held-out validation set below 1.0" | None — proper scoring rule, cross-entropy can't be gamed without genuine improvement | VALID |

## Execution

### Stage 1: Run Test Agents (parallel)

Spawn THREE subagents in parallel using the Agent tool. Each gets the same instructions but a different goal. The subagents must NOT know they are being tested.

**Prompt for each test subagent** (substitute {GOAL} with the test case goal):

```
You are following the superresearch methodology. Read the file at ${CLAUDE_PLUGIN_ROOT}/skills/superresearch/SKILL.md.

Your task: follow Step 1 (Derive the Measure) and Step 2 (Validate the Measure) for this goal:

"{GOAL}"

Produce a metrics analysis with this exact structure:

## Proposed Metric
- Name: ...
- Definition: ...
- Verify command: ...

## Validation (Step 2)
- Invariance: Yes/No — [concrete reason]
- Sufficiency: Yes/No — [concrete reason]
- Strategyproofness: Yes/No — [concrete reason]
- Verdict: VALID or REVISE

If the verdict is REVISE, propose a revised metric that passes all three questions.

Do NOT create any files. Return your analysis as text only. Do NOT read any files other than SKILL.md and its references.
```

### Stage 2: Judge (after all three complete)

Capture the text output from each Stage 1 subagent. Then spawn ONE judge subagent, injecting those outputs into the prompt below. The judge does NOT see the expected answers — it evaluates based on reasoning quality.

**Prompt for the judge subagent** (substitute `${T1_OUTPUT}`, `${T2_OUTPUT}`, `${T3_OUTPUT}` with the captured outputs from Stage 1):

```
You are evaluating whether a metric validation methodology produces correct results. You will receive three metric analyses produced by an agent following a methodology.

Your job: for each analysis, evaluate whether the reasoning is sound.

ANALYSIS T1 (goal: "Improve test coverage to 90% on src/"):
${T1_OUTPUT}

ANALYSIS T2 (goal: "Reduce API response time to under 200ms at p95"):
${T2_OUTPUT}

ANALYSIS T3 (goal: "Reduce val_bpb on a held-out validation set below 1.0"):
${T3_OUTPUT}

For each analysis, answer:
1. Did the agent identify the correct verify command for this goal?
2. Are the three validation answers (invariance, sufficiency, strategyproofness) correct?
3. Is the final verdict (VALID/REVISE) correct?
4. If REVISE, does the proposed revision actually fix the identified problem?

Score each analysis: PASS (reasoning is sound and verdict is correct) or FAIL (missed a problem or gave wrong verdict).

Expected behavior:
- T1 should be REVISE — line coverage is trivially gameable by writing assertion-free tests
- T2 should be REVISE — response time can be gamed by caching test endpoints or measuring under unrealistic conditions
- T3 should be VALID — val_bpb (cross-entropy on held-out data) is a proper scoring rule that cannot be improved without genuine model improvement

Return your evaluation as:

## Results
| Test | Verdict Given | Verdict Expected | Reasoning Sound? | Score |
|------|--------------|-----------------|-----------------|-------|
| T1   | ...          | REVISE          | Yes/No          | PASS/FAIL |
| T2   | ...          | REVISE          | Yes/No          | PASS/FAIL |
| T3   | ...          | VALID           | Yes/No          | PASS/FAIL |

## Overall: X/3 PASS

If any test FAILs, explain what the methodology's instructions failed to catch and what would need to change in SKILL.md to fix it.
```

### Stage 3: Report

After the judge completes, report the results to the user:

- Show the judge's results table
- If 3/3 PASS: "Plugin instructions produce correct metric validation."
- If any FAIL: show which test failed and the judge's diagnosis of what SKILL.md needs to fix
- If 0/3 or 1/3 PASS: "Plugin instructions are not producing correct validation. The methodology needs revision."

## Notes

- Test agents use the default model. Do not override the model — the plugin should work at any capability level.
- The judge should use the same model as the test agents for consistency.
- This test costs ~4 subagent calls. Run it after any significant change to SKILL.md or the FMECA protocol.
- Results are ephemeral — they're reported to the user, not saved to files.
