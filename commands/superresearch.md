---
name: superresearch
description: "For any high-stakes claim, formalize it into a verifiable argument chain. Derives a verification kernel, validates it (invariance, sufficiency, strategyproofness), then runs the loop with a baseline."
---

Load and follow the superresearch methodology:

1. Read the skill file at the superresearch plugin's `skills/superresearch/SKILL.md`
2. Follow the three-step flow: Derive the Measure → Validate the Measure → Run Karpathy's Loop
3. Parse any inline arguments the user provided: $ARGUMENTS
4. **Check for existing session artifacts** before starting — resume if possible:
   - Look for `docs/superresearch/sessions/` — are there existing sessions?
   - Look for `docs/superresearch/objectives.md` — do project objectives exist?
   - If a recent session has `metrics.md` but no validation table (VALID/REVISE verdicts) → resume at Step 2
   - If a recent session has validated metrics but no `results.tsv` → resume at Step 3
   - If a recent session has `results.tsv` → check if target was hit; if not, resume Step 3; if yes, run post-loop validation
   - If no session artifacts exist, start fresh at Step 1
5. If arguments describe what to build, check if objectives already exist before starting fresh
6. **Session naming:** `YYYY-MM-DD-{slug}` where slug is a kebab-case summary of the primary objective (e.g., `2026-03-21-api-latency`)
7. Session artifacts go in `docs/superresearch/sessions/{session-name}/` — objectives stay at `docs/superresearch/objectives.md`
