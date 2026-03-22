# Superresearch — Claude Code Context

## What This Plugin Actually Is

Superresearch solves one specific problem: **before you run any autonomous loop, you need a valid measure of "better."** Without that, you're just vibe-coding in a loop.

Every autonomous agent pattern — Karpathy's autoresearch, SEO bots, overnight experiment runners — reduces to four questions:

1. What does one cycle look like? (the directive)
2. What carries between cycles? (the state contract)
3. What does "better" mean? (the measure)
4. When do you keep, discard, or stop? (the decision rule)

Question 3 is the hard one. It's hard because most metrics are gameable — an agent can improve the number without improving the underlying thing (Goodhart's Law). Superresearch is the pre-flight checklist that forces you to answer question 3 honestly before the loop starts.

## The Goodhart Test (the core contribution)

A metric is only valid if it passes this test: **can this number improve without the underlying thing actually improving?**

- val_bpb (Karpathy): HARD to fake. The model has to actually compress text better.
- yield (semiconductor fab): HARD to fake. The chip either works or it doesn't.
- "tests passing": EASY to fake. Delete the tests.
- "FMECA checklist score": EASY to fake. Check boxes without reading them.

Superresearch's job is to construct a verify command that passes the Goodhart test before any build loop starts.

## Six Universal Components of Any Autonomous Loop

(From studying Karpathy, Matthew Berman's seo-kit, Anton Plex's overnight spawner, pi-autoresearch):

1. **Directive** — what to do each cycle (program.md, SOUL.md)
2. **State** — what carries between cycles (results.tsv)
3. **Trigger** — when to fire (cron, tmux, while-true)
4. **Capabilities** — what the agent can call
5. **Measure** — how to know if it worked (val_bpb, ranking delta)
6. **Decision** — keep or discard

Superresearch focuses on components 5 and 6 — deriving valid measures and decision rules — because those are what nobody else helps with. The runtime (Claude Code, cron) is commodity. The measure is not.

## The Core Insight

Karpathy didn't just have a loop — he had a measure (val_bpb) that was:
- Invariant under experimental manipulation (vocabulary-independent)
- Sufficient (captures everything that matters about language understanding)
- Strategyproof (you can't improve it without the model actually getting better)

These three properties — invariance, sufficiency, strategyproofness — are what makes a metric valid for an autonomous loop. Superresearch forces the agent to verify all three before proceeding.

## Current State (v0.3.0)

Three-step structure, formalized terminology:

**Step 1: Derive the Measure** — given a fuzzy goal, construct a verify command. "What command, run before vs. after your change, would prove the underlying thing actually improved?"

**Step 2: Validate the Measure** — three adversarial questions (FMECA on the metric itself):
- **Invariance** (measurement theory) — same dimension regardless of what the agent changes?
- **Sufficiency** (statistics) — does passing guarantee the goal is satisfied?
- **Strategyproofness** (mechanism design, Hurwicz 2007) — can an intelligent agent improve it without improving reality? This is the Goodhart test formalized.

**Step 3: Run Karpathy's Loop** — baseline measurement first (iteration 0). One change, one measurement, keep or discard. Git as memory. results.tsv as the control chart.

## Application Domains

The framework applies to any domain with a measurable claim: legal arguments, clinical trials, software systems, manufacturing quality. The README has generic examples.

## Files

- `skills/superresearch/SKILL.md` — main agent instructions
- `skills/superresearch/references/` — protocol documents
- `scripts/verify.sh` — structural self-check
- `commands/superresearch.md` — slash command entry point
- `commands/superresearch/improve.md` — 5-layer self-improvement
- `commands/superresearch/objectives.md` — objectives workflow
