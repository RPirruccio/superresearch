# Self-Improvement Protocol

Five-layer continuous improvement system for the superresearch methodology itself. Each layer catches what the layers below miss.

## The Five Layers

```
Layer 5: ANTIFRAGILITY — get stronger from stress
  │  Integrate learnings from sessions that used the methodology
  │  What worked? What failed? What patterns recur?
  │  Feed findings back into the methodology
  │
Layer 4: DOUBLE-LOOP — question the questions
  │  Are we checking the right things?
  │  Should the objectives themselves change?
  │  Are there entire categories of failure we're blind to?
  │
Layer 3: ASHBY'S LAW — match variety to reality
  │  FMECA on ourselves — dispatch agent to read docs cold
  │  Find failure modes the structural checks can't see
  │  Contradictions, lost concepts, unclear handoffs, false confidence
  │
Layer 2: OODA — detect changed conditions
  │  Has the environment shifted since last improvement?
  │  New capabilities, new patterns, new failure modes from recent work
  │  Did SKILL.md evolve but reference docs didn't catch up?
  │
Layer 1: KAIZEN — structural checks
  │  Are the files in place? Do keywords match?
  │  verify.sh — mechanical, fast, baseline hygiene
  │  This is necessary but NEVER sufficient
```

## Layer 1: Kaizen (Structural)

**Tool:** `bash scripts/verify.sh`
**What it catches:** Missing files, missing keywords, broken references
**What it misses:** Everything about quality, consistency, and completeness

This is the thermostat. It keeps the house at 70F. It cannot tell you if the house is on fire.

Run first. If this fails, fix structural issues before going deeper.

## Layer 2: OODA (Condition Detection)

**Tool:** Scripted checks in verify.sh (enhanced section)
**What it catches:** Drift between components, stale reference docs, new concepts not propagated

Checks:
- **Internal consistency:** Does Phase N's stated output match Phase N+1's stated input?
- **Reference freshness:** Do reference docs mention all concepts that SKILL.md introduces?
- **Concept propagation:** If SKILL.md says "metric-ready objectives," does the objectives-template mention measurement hints?
- **Session history:** Are there completed sessions in `docs/superresearch/sessions/`? What do their results tell us?
- **Orphan detection:** Are there reference docs that SKILL.md doesn't link to, or vice versa?

This layer detects that the game has changed but your playbook hasn't caught up.

## Layer 3: Ashby's Law (Variety Matching — FMECA on Self)

**Tool:** Dispatch a subagent to perform FMECA on the plugin itself
**What it catches:** Failure modes that no grep pattern can find

The subagent reads:
1. ALL reference docs cold (as if seeing them for the first time)
2. SKILL.md in full
3. The objectives template and metrics template
4. The commands

Then performs FMECA:
- **For each phase:** Can someone follow this without external context? What's ambiguous?
- **For each reference doc:** Is it complete enough to replace the source skill it was adapted from? What critical concepts were lost?
- **For each handoff (Phase N → Phase N+1):** Is the transition clear? Are there gaps where the user would be stranded?
- **For each "Proceed when" gate:** Is this mechanically enforceable or just prose?
- **Cross-reference:** Do reference docs contradict each other? Does brainstorming-protocol.md align with the metric-readiness concept in SKILL.md?

Output: Prioritized finding table (P0/P1/P2) — same format as fmeca-protocol.md describes.

## Layer 4: Double-Loop (Meta-Improvement)

**Tool:** Agent analysis + human review
**What it catches:** Wrong assumptions baked into the verification system itself

Questions to ask:
- Are the 6 objectives in verify.sh still the right objectives? Should new ones be added?
- Is "100/100 structural" creating false confidence? (Yes — that's why this protocol exists)
- Are there entire categories of quality we're not measuring? (Clarity? Actionability? Learnability?)
- Has the methodology evolved past what the templates teach? (e.g., metric-ready objectives weren't in the original template)
- Should verify.sh grow new check categories? Should old ones be deprecated?

**Output:** Proposed additions/changes to verify.sh and objectives. These go to the user for approval before implementation — double-loop changes the goals, so a human must approve.

## Layer 5: Antifragility (Session Feedback)

**Tool:** Analysis of `docs/superresearch/sessions/*/results.tsv` + session artifacts
**What it catches:** Patterns across sessions that reveal methodology weaknesses

Look for:
- **Keep/discard ratio across sessions:** If most iterations are discards, the planning phase isn't producing good iteration sequences
- **Recurring FMECA findings:** If the same P1 appears across sessions, the spec template needs to address it by default
- **Phase bottlenecks:** Which phase consistently takes the longest? That's where the reference doc needs more guidance
- **Crash patterns:** What kinds of crashes recur? Add prevention to the relevant protocol
- **Metric false positives:** Were there sessions where verify passed but the result was wrong? The metric methodology needs improvement

**Output:** Concrete improvements to reference docs, templates, and the methodology itself — informed by real usage, not theory.

## Running the Full Stack

The `/superresearch:improve` command runs all 5 layers in order:

```
1. Layer 1 (Kaizen)      — bash scripts/verify.sh
   If < 100 → fix structural issues first, don't proceed

2. Layer 2 (OODA)        — enhanced consistency checks
   Log findings, fix what's automatable

3. Layer 3 (Ashby)       — dispatch FMECA subagent
   Review findings with user, fix P0/P1

4. Layer 4 (Double-Loop) — propose meta-improvements
   Present to user for approval, implement approved changes

5. Layer 5 (Antifragility) — analyze session history
   Only if sessions exist. Feed patterns back into methodology.
```

Each layer's findings can trigger updates to lower layers:
- Layer 3 finding → new check in verify.sh (Layer 1)
- Layer 4 finding → new check category added to verify.sh
- Layer 5 finding → new section in a reference doc

**The bar always rises.** A system that reaches 100% and stops is broken. Each improvement cycle should make the next cycle's checks harder.
