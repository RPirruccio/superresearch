# Spec Verification Protocol

How to build and run verify-spec.sh scripts that mechanically validate specs before any code is written.

## Purpose

verify-spec.sh is **Layer 1 for specs** — structural completeness checking. It turns "is the spec good enough?" into "does the spec at least mention all the things it should?"

### Known Limitation: Grep-Based Theater

This script checks for keyword PRESENCE, not quality. A spec with `## Error Handling: TODO` will pass the error handling check. A section that mentions "performance" in passing scores the same as a detailed performance analysis.

**This is by design.** verify-spec.sh catches what CAN be caught mechanically — missing sections, forgotten concerns, structural gaps. It cannot assess depth, coherence, or correctness. That's what FMECA (Step 2: Validate the Measure) is for.

Think of it as incoming inspection vs. functional testing:
- **verify-spec.sh** = "all the components are in the box" (necessary)
- **FMECA** = "the components actually work together" (sufficient)

The script should hit 100/100 BEFORE FMECA runs, not instead of it.

## Script Location

Create at: `scripts/verify-spec.sh` in the project root (or session directory)

## Script Template

```bash
#!/bin/bash
# verify-spec.sh — Mechanical spec verification
# Usage: bash scripts/verify-spec.sh <path-to-spec.md>

set -euo pipefail

SPEC="${1:?Usage: verify-spec.sh <spec-file>}"
SCORE=0
MAX=0
GAPS=""

check() {
    local points=$1
    local label=$2
    local pattern=$3
    MAX=$((MAX + points))
    if grep -qi "$pattern" "$SPEC"; then
        SCORE=$((SCORE + points))
        echo "  [+$points] $label"
    else
        GAPS="$GAPS\n  [-$points] MISSING: $label"
    fi
}

echo "=== Spec Verification ==="
echo "File: $SPEC"
echo ""

# A. COMPLETENESS — does spec cover all MVP concerns?
echo "--- Completeness ---"
# Add checks for each major component from objectives.md
# Example:
# check 5 "Authentication" "auth"
# check 5 "Database schema" "schema\|database\|model"
# check 5 "API endpoints" "endpoint\|route\|api"

# B. GAP DETECTION — what's missing?
echo "--- Gap Detection ---"
check 5 "Error handling strategy" "error.handling\|error.strategy\|error.propagat"
check 5 "Test strategy" "test.strategy\|test.plan\|coverage"
check 5 "Environment configuration" "environment\|env.var\|config"
check 5 "Data flow documentation" "data.flow\|data.model\|data.pipeline"
check 3 "Rollback/recovery plan" "rollback\|recovery\|revert"
check 3 "Security considerations" "security\|auth\|permission\|secret"
check 3 "Performance targets" "performance\|latency\|throughput"

# C. STRUCTURAL QUALITY — does it follow spec best practices?
echo "--- Structural Quality ---"
check 5 "Problem statement" "problem\|challenge\|issue"
check 5 "Clear goal" "goal\|objective\|purpose"
check 5 "Success criteria" "success.criter\|done.when\|acceptance"
check 5 "Non-goals" "non.goal\|out.of.scope\|not.included"
check 5 "Iteration plan with metrics" "iteration\|phase\|step.*metric"

# D. FMECA ALIGNMENT — does spec match objectives?
echo "--- FMECA Alignment ---"
check 5 "References objectives" "objective\|obj.*[0-9]"
check 5 "References metrics" "metric\|verify.*command\|guard.*command"
check 5 "Verify commands defined" "verify\|bash.*script\|check.*command"
check 3 "Guard commands defined" "guard\|regression\|safety"

# Summary
echo ""
echo "--- Gaps Found ---"
if [ -n "$GAPS" ]; then
    echo -e "$GAPS"
else
    echo "  None!"
fi

echo ""
PERCENT=$((SCORE * 100 / MAX))
echo "=== Score: $SCORE/$MAX ($PERCENT/100) ==="
```

## How to Customize

The template above is a starting point. For each superresearch session:

1. **Read objectives.md** — add a `check` line for each objective's key component
2. **Read metrics.md** — add a `check` line for each metric's verify/guard command presence
3. **Add domain-specific checks** — if building a CLI, check for "argument parsing"; if building an API, check for "endpoint documentation"

## Scoring

- Each `check` is worth a specified number of points
- Total possible = sum of all check points
- **Target: 100/100 (percentage)** — spec is not done until it hits this

## Integration with Fix Loop

The fix loop uses verify-spec.sh as its verification command:

```
Target: bash scripts/verify-spec.sh docs/superresearch/sessions/{session}/spec.md
Scope: docs/superresearch/sessions/{session}/spec.md
Guard: echo "pass"  (spec changes can't break anything)
```

Each fix loop iteration:
1. Read verify-spec.sh output to find the highest-priority gap
2. Edit spec.md to address that gap
3. Re-run verify-spec.sh
4. If score improved → keep; if not → discard and try different approach

## Evolving the Script

After FMECA (Step 2: Validate the Measure), update verify-spec.sh to also catch FMECA findings:

```bash
# Added after FMECA — F1: Obj 3 was silently ignored
check 10 "Objective 3: User notifications" "notification\|alert\|notify"

# Added after FMECA — F2: No cache warmup in perf test
check 5 "Performance test warmup" "warmup\|warm.up\|cache.prime"
```

Then run the fix loop again until the updated script returns 100/100.
