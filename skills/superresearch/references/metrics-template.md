# Metrics Template

Use this template for `docs/superresearch/sessions/{session}/metrics.md`.

---

```markdown
# Metrics — {Session Name}

**Date:** YYYY-MM-DD
**In-scope objectives:** Obj {1}, Obj {3}, Obj {5} — subset from docs/superresearch/objectives.md

## Metric: {Name}

- **Objective:** {Which objective(s) this measures — reference by number}
- **Definition:** What it measures
- **Units:** How it's quantified (integer count, percentage, score 0-100)
- **Direction:** Higher is better / Lower is better
- **Measurement:** The exact command that produces the number
- **Target:** What "done" looks like (≥6 files, 100/100, 0 errors)
- **Spec:** Institutional source if applicable (MIL-STD-1629A, Web Vitals, OWASP, etc.)
- **Verify command:** `bash scripts/verify.sh` — shell command for autoresearch verify step
- **Guard command:** `npm test` — shell command that must always pass (regression prevention)
- **Goodhart test (strategyproofness):** Can this metric improve without the underlying thing actually improving? If yes, the metric is not strategyproof — revise it. {Answer here — must be "No, because..." with a concrete reason. "Yes" = metric rejected.}
- **Invariance check:** Will this metric measure the same underlying dimension regardless of what the agent changes? If no, the metric is vocabulary-dependent — revise it. {Answer here — must be "Yes, because..." with a concrete reason. "No" = metric rejected.}

## Metric: {Name 2}

- **Objective:** Obj 2
- **Definition:** ...
- **Units:** ...
- **Direction:** ...
- **Measurement:** ...
- **Target:** ...
- **Spec:** ...
- **Verify command:** ...
- **Guard command:** ...
- **Goodhart test:** ...
- **Invariance check:** ...

## Composite Verify Command (required when multiple metrics exist)

The build loop needs ONE verify command that produces ONE number. When you have multiple metrics, create a composite script:

```bash
#!/bin/bash
# scripts/verify.sh — composite verify for this session
# Runs all metric commands and produces a single weighted score

set -euo pipefail

# Run each metric and capture the value
COVERAGE=$(pytest --cov=src --cov-report=term-only 2>/dev/null | grep TOTAL | awk '{print $4}' | tr -d '%')
PERF_SCORE=$(curl -s -w '%{time_total}' -o /dev/null http://localhost:8080/api/health | awk '{printf "%.0f", (1 - $1/0.2) * 100}')
QUALITY=$(bash scripts/lint-check.sh | tail -1 | grep -oE '[0-9]+')

# Weighted composite (weights must sum to 1.0)
SCORE=$(echo "$COVERAGE * 0.4 + $PERF_SCORE * 0.3 + $QUALITY * 0.3" | bc -l | awk '{printf "%.0f", $1}')

echo "Coverage: $COVERAGE% | Perf: $PERF_SCORE | Quality: $QUALITY"
echo "=== Composite Score: $SCORE/100 ==="
```

**Rules for composite metrics:**
- Normalize all metrics to 0-100 scale before combining
- Weights reflect relative importance — assign from objectives priority
- If metrics have different directions (higher vs lower), flip the lower-is-better ones: `normalized = (1 - value/ceiling) * 100`
- The composite script becomes the SINGLE verify command for the build loop
- Document the weights and normalization in metrics.md so they're auditable
```

---

## Rules

1. **Every metric must be MECHANICAL** — run a command, get a number. No subjective assessment.
2. **Every metric traces to an objective** — no orphan metrics
3. **Verify command = the autoresearch verify step** — this is what gets run every iteration
4. **Guard command = regression prevention** — this must always pass
5. **Metrics from institutional specs are more authoritative** than ad-hoc metrics
6. **At least one metric per objective** — if you can't measure it, the objective is too vague
7. **Target is not aspirational** — it's the minimum for "done". Set achievable targets.
8. **Every metric must pass the Goodhart test** — if the number can improve without reality improving, reject the metric and find a better one. No exceptions.
9. **Every metric must pass the invariance check** — if the metric measures a different thing depending on what the agent changes (e.g., vocabulary-dependent text scores), reject it and find one that's stable under manipulation.
