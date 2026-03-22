---
name: improve
description: "5-layer continuous improvement on the superresearch plugin itself — structural checks, condition detection, FMECA, meta-improvement, and session feedback"
---

# Self-Improvement — 5 Layer Protocol

Read `${CLAUDE_PLUGIN_ROOT}/skills/superresearch/references/self-improvement-protocol.md` for the full mental model.

Run all 5 layers in order. Each layer catches what the layers below miss.

## Layer 1: Kaizen (Structural)

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/verify.sh
```

If score < 100: apply the fix loop (`references/fix-loop.md`) to close structural gaps first. Do not proceed to Layer 2 until Layer 1 is 100/100.

If score = 100: report it, then **proceed to Layer 2** — 100% structural is necessary but never sufficient.

## Layer 2: OODA (Condition Detection)

Check for drift between components:

1. **Read SKILL.md** — extract every concept, phase, and term it introduces
2. **Cross-reference each reference doc** — does it reflect the current SKILL.md? Look for:
   - Concepts SKILL.md mentions that reference docs don't cover
   - Reference docs that describe outdated flows
   - Templates that don't include fields SKILL.md now requires (e.g., measurement hints in objectives)
3. **Check step handoffs** — for each Step N → Step N+1:
   - Does Step N's "Output" match Step N+1's "Input"?
   - Are the file paths consistent?
4. **Check session history** — if `docs/superresearch/sessions/` exists, note how many sessions have run and what their results look like

Report findings. Fix what's clear-cut (path inconsistencies, missing template fields). Flag ambiguous findings for Layer 3.

## Layer 3: Ashby's Law (FMECA on Self)

Dispatch a subagent to perform FMECA on the plugin itself. The subagent should:

1. Read ALL files in the plugin cold (as if seeing them for the first time)
2. For each step: "Can someone follow this without external context? What's ambiguous?"
3. For each reference doc: "Is this complete enough to replace the source skill?"
4. For each handoff: "Is the transition clear or would the user be stranded?"
5. For each 'Proceed when' gate: "Is this enforceable or just prose?"
6. Check for contradictions between reference docs
7. Output: prioritized finding table (P0 = methodology broken, P1 = significant gap, P2 = could be better)

Review findings with the user. Fix P0/P1. Track P2 for future.

## Layer 4: Double-Loop (Question the Questions)

Present these meta-questions to the user:

1. Are the current verify.sh checks still the right checks? Should new categories be added?
2. Is there a category of quality we're completely blind to? (Clarity? Learnability? Real-world usability?)
3. Has the methodology evolved past what the templates teach?
4. Should any verify.sh checks be deprecated or replaced?
5. Based on Layers 2-3 findings, what new checks should verify.sh grow?

Implement approved changes. Update verify.sh with new checks. The bar rises.

## Layer 5: Antifragility (Session Feedback)

Only run if sessions exist at `docs/superresearch/sessions/`.

Analyze completed sessions:
1. Read `results.tsv` from each session — what's the keep/discard ratio?
2. Were there recurring FMECA findings across sessions?
3. Which step consistently bottlenecked?
4. Were there metric false positives (verify passed but result was wrong)?
5. Feed patterns back into reference docs and templates

## After All Layers

Report summary:
- Layer 1: score (should be 100/100)
- Layer 2: N findings (M fixed, K flagged)
- Layer 3: N findings by severity
- Layer 4: N meta-improvements proposed/approved
- Layer 5: N session patterns identified

The bar should be higher after every run. If it's not, Layer 4 failed.

## Arguments

$ARGUMENTS — optional:
- "verify-only" or "layer-1" — just run structural checks
- "layers 1-2" — run structural + condition detection
- "full" or no args — run all 5 layers
