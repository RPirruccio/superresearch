#!/bin/bash
# verify.sh — Self-verification for the superresearch plugin
# Layer 1 (Kaizen): structural checks — are the pieces in place?
# Layer 2 (OODA): consistency checks — have components drifted apart?
# Usage: bash scripts/verify.sh

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL="$PLUGIN_DIR/skills/superresearch/SKILL.md"
REFS_DIR="$PLUGIN_DIR/skills/superresearch/references"

SCORE=0
MAX=0
GAPS=""

check() {
    local points=$1
    local label=$2
    local pattern=$3
    local file="${4:-$SKILL}"
    MAX=$((MAX + points))
    if grep -qi "$pattern" "$file" 2>/dev/null; then
        SCORE=$((SCORE + points))
        echo "  [+$points] $label"
    else
        GAPS="$GAPS\n  [-$points] MISSING: $label"
    fi
}

check_file() {
    local points=$1
    local label=$2
    local path=$3
    MAX=$((MAX + points))
    if [ -f "$path" ]; then
        SCORE=$((SCORE + points))
        echo "  [+$points] $label"
    else
        GAPS="$GAPS\n  [-$points] MISSING: $label (file not found: $path)"
    fi
}

check_no_match() {
    local points=$1
    local label=$2
    local pattern=$3
    local file="${4:-$SKILL}"
    MAX=$((MAX + points))
    if ! grep -qi "$pattern" "$file" 2>/dev/null; then
        SCORE=$((SCORE + points))
        echo "  [+$points] $label"
    else
        GAPS="$GAPS\n  [-$points] FAIL: $label (found external dependency)"
    fi
}

# Cross-reference: check that SKILL.md concept appears in a reference doc
check_propagation() {
    local points=$1
    local label=$2
    local concept=$3
    local ref_file=$4
    MAX=$((MAX + points))
    if grep -qi "$concept" "$ref_file" 2>/dev/null; then
        SCORE=$((SCORE + points))
        echo "  [+$points] $label"
    else
        GAPS="$GAPS\n  [-$points] DRIFT: $label (concept in SKILL.md not propagated to $(basename "$ref_file"))"
    fi
}

# Check that every ref doc mentioned in SKILL.md actually exists
check_dangling_refs() {
    local points=$1
    MAX=$((MAX + points))
    local dangling=""
    # Extract all references/*.md mentions from SKILL.md
    for ref in $(grep -oE 'references/[a-z-]+\.md' "$SKILL" | sort -u); do
        if [ ! -f "$PLUGIN_DIR/skills/superresearch/$ref" ]; then
            dangling="$dangling $ref"
        fi
    done
    if [ -z "$dangling" ]; then
        SCORE=$((SCORE + points))
        echo "  [+$points] No dangling references in SKILL.md"
    else
        GAPS="$GAPS\n  [-$points] DANGLING: SKILL.md references non-existent files:$dangling"
    fi
}

# Check that every ref doc in the directory is actually referenced by SKILL.md
check_orphan_refs() {
    local points=$1
    MAX=$((MAX + points))
    local orphans=""
    for ref_file in "$REFS_DIR"/*.md; do
        local basename
        basename=$(basename "$ref_file")
        if ! grep -q "$basename" "$SKILL" 2>/dev/null; then
            orphans="$orphans $basename"
        fi
    done
    if [ -z "$orphans" ]; then
        SCORE=$((SCORE + points))
        echo "  [+$points] No orphan reference docs"
    else
        GAPS="$GAPS\n  [-$points] ORPHAN: Reference docs not linked from SKILL.md:$orphans"
    fi
}

echo "========================================"
echo "  LAYER 1: KAIZEN (Structural Checks)"
echo "========================================"
echo ""

# --- Self-Contained ---
echo "--- Self-Contained ---"
check_no_match 5 "No superpowers:brainstorming dependency" "use.*superpowers:brainstorming"
check_no_match 5 "No superpowers:writing-plans dependency" "use.*superpowers:writing-plans"
check_no_match 5 "No autoresearch:autoresearch dependency" "use.*autoresearch:autoresearch\b"
check_no_match 5 "No autoresearch:fix dependency" "use.*autoresearch.*fix"
check 3 "Self-contained declaration" "self.contained"

# --- Protocol Coverage ---
echo "--- Protocol Coverage ---"
check_file 3 "brainstorming-protocol.md exists" "$REFS_DIR/brainstorming-protocol.md"
check_file 3 "planning-protocol.md exists" "$REFS_DIR/planning-protocol.md"
check_file 3 "autonomous-loop.md exists" "$REFS_DIR/autonomous-loop.md"
check_file 3 "fix-loop.md exists" "$REFS_DIR/fix-loop.md"
check_file 3 "results-logging.md exists" "$REFS_DIR/results-logging.md"
check_file 3 "fmeca-protocol.md exists" "$REFS_DIR/fmeca-protocol.md"
check_file 3 "spec-verification.md exists" "$REFS_DIR/spec-verification.md"
check_file 3 "self-improvement-protocol.md exists" "$REFS_DIR/self-improvement-protocol.md"
check 2 "References brainstorming protocol" "brainstorming-protocol"
check 2 "References planning protocol" "planning-protocol"
check 2 "References autonomous loop" "autonomous-loop"
check 2 "References fix loop" "fix-loop"
check 2 "References results logging" "results-logging"
check 2 "References FMECA protocol" "fmeca-protocol"
check 2 "References spec verification" "spec-verification"

# --- Self-Verification ---
echo "--- Self-Verification ---"
check_file 3 "verify.sh exists" "$PLUGIN_DIR/scripts/verify.sh"

# --- Self-Improvement ---
echo "--- Self-Improvement ---"
check_file 3 "improve command exists" "$PLUGIN_DIR/commands/superresearch/improve.md"
check 2 "5-layer improvement model" "layer.*kaizen\|layer.*ooda\|5.layer\|five.layer"
check 2 "Self-improvement references protocol" "self-improvement-protocol"

# --- Three-Step Structure ---
echo "--- Three-Step Structure ---"
check 3 "Step 1: Derive the Measure" "step.1.*derive\|derive.the.measure"
check 3 "Step 2: Validate the Measure" "step.2.*validate\|validate.the.measure"
check 3 "Step 3: Run Karpathy" "step.3.*karpathy\|run.karpathy\|karpathy.*loop"
check 2 "Three adversarial questions" "three.adversarial\|three.*question"
check 2 "Invariance concept" "invariance"
check 2 "Sufficiency concept" "sufficiency"
check 2 "Strategyproofness concept" "strategyproof"
check 2 "Goodhart test" "goodhart"
check 2 "Baseline before iteration" "baseline.*iteration\|iteration.0\|iteration 0"
check 2 "Metric-ready objectives concept" "metric.ready"
check 2 "Persistent objectives concept" "persistent\|project.level"
check 2 "Sessions subdirectory pattern" "sessions/"

# --- Thesis ---
echo "--- Thesis ---"
check 3 "Thesis section exists" "the.thesis"
check 3 "Learning how to learn" "learning.how.to.learn"
check 2 "Kaizen reference" "kaizen"
check 2 "OODA reference" "ooda"

# --- Templates ---
echo "--- Templates ---"
check_file 2 "objectives-template.md exists" "$REFS_DIR/objectives-template.md"
check_file 2 "metrics-template.md exists" "$REFS_DIR/metrics-template.md"

# --- Commands ---
echo "--- Commands ---"
check_file 2 "objectives command exists" "$PLUGIN_DIR/commands/superresearch/objectives.md"
check_file 2 "test command exists" "$PLUGIN_DIR/commands/superresearch/test.md"

echo ""
echo "========================================"
echo "  LAYER 2: OODA (Consistency Checks)"
echo "========================================"
echo ""

# --- Reference Integrity ---
echo "--- Reference Integrity ---"
check_dangling_refs 3
check_orphan_refs 3

# --- Concept Propagation ---
echo "--- Concept Propagation ---"
check_propagation 2 "Objectives template has measurement hints" "measurement.hint\|units.*direction.*target" "$REFS_DIR/objectives-template.md"
check_propagation 2 "Objectives template has metric-readiness" "metric.ready\|metric.readiness" "$REFS_DIR/objectives-template.md"
check_propagation 2 "Brainstorming protocol knows about metric-readiness" "metric.ready\|measur" "$REFS_DIR/brainstorming-protocol.md"
check_propagation 2 "Planning protocol references metrics.md" "metrics.md\|verify.*command.*from.*metric" "$REFS_DIR/planning-protocol.md"
check_propagation 2 "Fix loop knows about spec verification" "verify.spec\|spec.*verif" "$REFS_DIR/fix-loop.md"
check_propagation 2 "Results logging matches session path" "session" "$REFS_DIR/results-logging.md"
check_propagation 2 "Metrics template has Goodhart test field" "goodhart.test" "$REFS_DIR/metrics-template.md"
check_propagation 2 "Metrics template has invariance check field" "invariance.check" "$REFS_DIR/metrics-template.md"
check_propagation 2 "FMECA has three adversarial questions" "invariance\|sufficiency\|strategyproof" "$REFS_DIR/fmeca-protocol.md"
check_propagation 2 "Autonomous loop has baseline step" "baseline\|iteration.0\|step.0" "$REFS_DIR/autonomous-loop.md"

# --- Step Handoff Consistency ---
echo "--- Step Handoffs ---"
# Step 1 output (metrics.md) feeds Step 2 (validation)
check 2 "Step 1→2 handoff: metrics to validation" "verify.command\|validate.*metric\|each.metric"
# Step 2 output (validated metrics) feeds Step 3 (loop)
check 2 "Step 2→3 handoff: validated metrics to loop" "validated.metric\|valid.*proceed\|do.not.proceed"
# Step 3 references baseline
check 2 "Step 3 baseline requirement" "no.baseline.*no.valid\|baseline.*iteration"

# Layer 2 summary
echo ""
echo "--- Layer 1+2 Gaps ---"
if [ -n "$GAPS" ]; then
    echo -e "$GAPS"
else
    echo "  None!"
fi

echo ""
PERCENT=$((SCORE * 100 / MAX))
echo "=== Score: $SCORE/$MAX ($PERCENT/100) ==="

if [ "$PERCENT" -eq 100 ]; then
    echo ""
    echo "Layer 1+2 clean. But this is NECESSARY, not SUFFICIENT."
    echo "Run /superresearch:improve for Layers 3-5 (FMECA, double-loop, antifragility)."
fi
