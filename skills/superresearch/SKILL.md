---
name: superresearch
description: "For any high-stakes claim you believe is true, formalize it into a verifiable argument chain where the gaps show up as failures before the real world shows them to you as disasters. Derives a shell-command verification kernel (like OpenGauss uses Lean for math), validates it against three adversarial questions (invariance, sufficiency, strategyproofness), then runs an iterative loop with a baseline. Triggers on: 'build this', 'prove this', 'validate my metric', 'is this claim defensible', or any goal with a measurable outcome."
version: 0.3.0
---

# Superresearch — Formalize It Until the Gaps Are Visible

**For any high-stakes claim you believe is true, this plugin forces you to formalize it until the gaps show up as failures before you execute.**

OpenGauss turns informal mathematical reasoning into machine-verifiable Lean proofs — the verification kernel catches logical gaps before peer review does. Superresearch does the same thing for general goals: it turns an informal claim ("this system will work," "this argument will hold," "this prediction is defensible") into a shell-command verify function that catches the gaps before reality does.

The structure is the same whether you're building a legal argument chain, validating a clinical trial endpoint, or shipping software. You have a claim. You need a verification kernel that's invariant, sufficient, and strategyproof. Then you iterate against it.

## The Three Steps

### Step 1: Derive the Measure

Given an informal claim, construct a verify command — the verification kernel.

One question: **"What command, run before vs. after your change, would prove the underlying thing actually improved?"** If you can't answer that, you don't have a measure yet.

**How:**

1. Start with the user's goal. If vague, sharpen it until it's metric-ready:
   - Not "improve performance" → "API response time under 200ms at p95"
   - Not "better tests" → "mutation score ≥ 80% on src/"
   - Not "make it work" → "all integration tests pass against real database"

2. Check for existing objectives at `docs/superresearch/objectives.md`. If they exist, select the subset for this session. If not, brainstorm with the user (protocol: `references/brainstorming-protocol.md`, template: `references/objectives-template.md`).

3. For each objective, define a metric with a verify command. Every metric must be mechanical — run a command, get a number. Template: `references/metrics-template.md`.

4. Each metric must include a **Goodhart test** answer and an **invariance check** answer (see template).

**Output:** `docs/superresearch/sessions/{session}/metrics.md` with verify commands for every objective.

**Gate:** Every in-scope objective has at least one metric with a verify command. If not, stay in Step 1.

### Step 2: Validate the Measure

Run three adversarial questions on each verify command. This is FMECA applied to the metric itself (`references/fmeca-protocol.md`).

**Question 1 — Invariance:** Will this metric measure the same underlying dimension regardless of what the agent changes? If the agent can shift what the metric measures by changing vocabulary, naming, or surface structure — the metric is invalid.

**Question 2 — Sufficiency:** Does passing this metric guarantee the goal is satisfied? Can the real thing be broken while the metric reads "pass"? If yes — the metric is a proxy, not a measure.

**Question 3 — Strategyproofness:** Can an intelligent agent improve this metric without improving reality? This is the Goodhart test formalized. If a sufficiently clever agent can game the number — the metric is invalid.

| Property | Formal field | Semiconductor analogue |
|---|---|---|
| Invariance | Measurement theory | Gauge R&R — same result regardless of operator or machine |
| Sufficiency | Construct validity (psychometrics) | Functional test — chip either computes correctly or doesn't |
| Strategyproofness | Mechanism design (Hurwicz 2007) | Wafer yield — can't improve it without actually fixing the process |

**For each metric, record:**

| Metric | Invariant? | Sufficient? | Strategyproof? | Verdict |
|---|---|---|---|---|
| {name} | Yes/No — reason | Yes/No — reason | Yes/No — reason | VALID / REVISE |

Any "No" = REVISE. All three "Yes" = VALID. No exceptions.

**The caveats rule:** If your "Yes" requires conditions not enforced by the verify command itself, the answer is "No." Conditions in prose are not enforceable. Fix the command to encode the condition, then re-answer.

**Gate:** Every metric is VALID. If any metric fails any question, revise it and re-run Step 2. Do not proceed to Step 3 with an invalid metric.

### Step 3: Run Karpathy's Loop

With validated metrics, run the autonomous build loop (`references/autonomous-loop.md`).

**3a. Baseline (iteration 0):**
Run the verify command on the current state. Record as iteration 0. No baseline = no valid delta = no valid experiment.

**3b. Plan (optional but recommended for big projects):**
For multi-step work, write a plan where each task has a metric target (`references/planning-protocol.md`). For simple tasks, skip the plan and just loop.

If the project is large enough to warrant a spec, write one. The spec references objectives and metrics — it doesn't invent new verify commands. Use `references/brainstorming-protocol.md` for the spec conversation and `references/spec-verification.md` to check it.

**3c. Loop:**
One change → one measurement → keep or discard. Git as memory. results.tsv as the control chart.

- Modify: one atomic change, explainable in one sentence
- Commit: before verification (so rollback is clean)
- Verify: run the verify command, extract the metric
- Guard: run the guard command if defined (regression check)
- Decide: improved → keep. Same or worse → discard and revert.
- Crash recovery: if verify fails or crashes, apply `references/fix-loop.md` (max 3 attempts, then discard)
- Log: append to results.tsv (`references/results-logging.md`)

**3d. Post-loop validation:**
After the loop completes (target hit or iterations exhausted), check: did the metric track reality? Run FMECA again (`references/fmeca-protocol.md`) — compare metric deltas to actual observed behavior. If the metric went up but reality didn't improve, the metric failed strategyproofness in practice. Learn from it.

**Output:** `docs/superresearch/sessions/{session}/results.tsv`

## When to Use

- **"I have a claim I need to make defensible"** — legal argument, prediction, technical spec (all three steps)
- **"I need a metric for my loop"** — you have a goal and a loop runner, you need a valid verify command (Steps 1-2)
- **"My loop is producing garbage"** — your metric is probably gameable or insufficient (Step 2 diagnosis)
- **"Build this"** — significant multi-step build session (all three steps)
- **"Is this metric valid?"** — standalone validation of an existing metric (Step 2 only)

## Dependencies

This plugin is **SELF-CONTAINED**. All protocols are inlined in reference docs. No external skills are required.

## Artifacts

### Project-Level (persistent, version controlled)

```
docs/superresearch/
└── objectives.md     ← WHAT and WHY — outlives any single session
```

Objectives are **project-level** and persistent. They evolve over time. Use `git log docs/superresearch/objectives.md` to see that evolution. Every objective must be **metric-ready** — written so you can immediately derive a verify command. Use `/superresearch:objectives` to brainstorm and stress-test objectives.

### Session-Level (per build session)

```
docs/superresearch/sessions/YYYY-MM-DD-{slug}/
├── metrics.md        ← Verify commands, targets, validity answers (Step 1-2 output)
├── spec.md           ← Optional: what to build for large projects
├── plan.md           ← Optional: task sequence with metric targets
└── results.tsv       ← Iteration log (Step 3 output)
```

## Self-Improvement

This plugin improves itself using a 5-layer continuous improvement model (see `references/self-improvement-protocol.md`):

| Layer | Framework | What it catches |
|---|---|---|
| 1 | Kaizen | Structural: are the files in place? (`bash scripts/verify.sh`) |
| 2 | OODA | Drift: have components fallen out of sync? |
| 3 | Ashby's Law | Blind spots: FMECA on the plugin itself |
| 4 | Double-Loop | Meta: are we even checking the right things? |
| 5 | Antifragility | Patterns: what do real sessions teach us? |

- **Verify:** `bash scripts/verify.sh` — Layers 1+2 (structural + consistency)
- **Improve:** `/superresearch:improve` — all 5 layers, escalating depth
- **Session artifacts:** Live in `docs/superresearch/sessions/{slug}/` in the host project

## The Thesis

**Superresearch treats your metric the way semiconductor fabs treat their process-of-record — paranoid, validated, never trusted on paper alone.**

The moat is learning how to learn. Superresearch makes it systematic:
1. Derive the measure (what does "better" mean?)
2. Validate the measure (can it be gamed?)
3. Run the loop (baseline, modify, verify, keep or discard)

Every step exists because the previous step has blind spots:
- Objectives exist because "build this" is ambiguous
- Metrics exist because objectives are prose
- FMECA exists because metrics look valid on paper
- The baseline exists because you can't measure improvement without a before
- Post-loop validation exists because metrics can lie in practice

This isn't pessimism. It's engineering. You never trust a clean lot. You just haven't found the defect yet.
