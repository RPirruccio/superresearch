# Superresearch

**For any high-stakes claim you believe is true, formalize it until the gaps show up as failures before the real world shows them to you as disasters.**

OpenGauss uses Lean as its verification kernel for mathematics. Superresearch uses a shell-command verify function as the verification kernel for everything else. The domain is whatever you're working on — the formalization is always code, because code is how you express deterministic functions. Same structure: informal claim → formal verification → iterate until the gaps close.

## Install

```bash
claude plugin add RPirruccio/superresearch
```

## Three Steps

### Step 1: Derive the Measure

Given an informal claim, construct a verify command — the verification kernel. One question: "What command, run before vs. after your change, would prove the underlying thing actually improved?"

### Step 2: Validate the Measure

Three adversarial questions on the verify command itself:

| Question | Formal field | What it catches |
|---|---|---|
| **Invariance** — same dimension regardless of what the agent changes? | Measurement theory | Agent shifts what the metric measures (e.g., renames TODOs to FIXMEs) |
| **Sufficiency** — does passing guarantee the goal is satisfied? | Construct validity | Metric is a proxy, not the thing (e.g., "build succeeds" but code is broken) |
| **Strategyproofness** — can an intelligent agent improve it without improving reality? | Mechanism design | Metric is gameable (e.g., line coverage via tests that assert nothing) |

Any "No" = revise the metric. All three "Yes" = valid. **The caveats rule:** if your "Yes" requires conditions not enforced by the verify command itself, the answer is "No." Encode the condition in the command, then re-answer.

### Step 3: Run Karpathy's Loop

Baseline measurement first (iteration 0). Then: one change, one measurement, keep or discard. Git as memory. `results.tsv` as the control chart.

## Examples

**Legal argument chain.** A whistleblower alleges regulatory violations at a pharmaceutical company. The informal claim is "pattern of retaliation after protected disclosure." Step 1: derive the verify command — a Python script that queries CourtListener, EDGAR, and a local document store, returning the count of sources that independently corroborate the fact pattern. Step 2: validate — Invariant (same result regardless of which evidence you emphasize)? Sufficient (does corroboration across three sources guarantee the pattern is real)? Strategyproof (can you pass without the retaliation existing)? Apply the caveats rule: the script counts three sources, but if two derive from the same original, the count inflates without evidence improving. "Independent" must be enforced by the command — e.g., checking that no two sources share a common origin — or the metric is invalid.

**Clinical trial endpoint.** You claim a new drug reduces hospital readmission rates by 15% vs. placebo. Step 1: derive the verify command — a Python script that pulls readmission data from the trial database, runs a two-sample proportional z-test, and returns the effect size with confidence interval. Step 2: validate — Invariant (same measurement regardless of which sites or demographics)? Sufficient (does a 15% reduction in readmissions guarantee clinical significance)? Strategyproof (can the trial improve the number by cherry-picking sites with low baseline readmission)? Apply the caveats rule: "pre-registered cohort" is a precondition for strategyproofness, but if the command doesn't verify the cohort hash against the registration record, it's a condition in prose, not in code. Encode it or the metric is invalid.

**Software system.** You want API response time under 200ms at p95. Step 1: derive the verify command — `k6 run load-test.js | jq '.metrics.http_req_duration.p95'` against a production-mirrored load profile. Step 2: validate — Invariant (same measurement regardless of what the agent optimizes)? Sufficient (does sub-200ms p95 guarantee acceptable UX)? Strategyproof (can the agent cache only the test endpoints)? Apply the caveats rule: if the load profile isn't production-mirrored and baked into the script, "realistic load" is a prose condition. The command must enforce its own preconditions.

## Commands

| Command | Purpose |
|---|---|
| `/superresearch` | Start a formalization session |
| `/superresearch:objectives` | Brainstorm and stress-test project objectives |
| `/superresearch:improve` | 5-layer self-improvement on the plugin itself |

## Artifacts

```
docs/superresearch/
├── objectives.md                          # Persistent, version controlled
└── sessions/
    └── 2026-03-21-my-feature/             # Per-session
        ├── metrics.md                     # Step 1-2 output: verified metrics
        ├── spec.md                        # Optional: what to build (large projects)
        ├── plan.md                        # Optional: task sequence with metric targets
        └── results.tsv                    # Step 3 output: iteration log
```

## Inspired By

- [OpenGauss](https://github.com/math-inc/OpenGauss) — autoformalization of informal math into machine-verifiable Lean proofs (DARPA expMath). Same pattern: informal claim → formal verification kernel → iterate.
- [superpowers](https://github.com/obra/superpowers) by Jesse Vincent — structured brainstorming, spec writing, and plan execution workflows
- [autoresearch](https://github.com/uditgoenka/autoresearch) by Udit Goenka — autonomous metric-driven iteration loops (modify, verify, keep/discard, repeat)
- Goodhart's Law (1975) — the problem. Mechanism design (Hurwicz/Myerson/Maskin 2007) — the solution.

## License

MIT
