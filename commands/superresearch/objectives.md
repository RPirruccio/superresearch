---
name: objectives
description: "Brainstorm, review, or evolve project objectives that are metric-ready for superresearch sessions"
---

# Objectives Workflow

Manage the project's persistent objectives at `docs/superresearch/objectives.md`.

## Steps

1. **Check for existing objectives:**
   - Look for `docs/superresearch/objectives.md` in the current project
   - If found: read them, show the user, and ask what they want to do (add, refine, deprecate, or just review)
   - If not found: start fresh — create the file and begin brainstorming
   - Also check for project-level objectives in any known knowledge base or docs folder

2. **Brainstorm objectives** (follow `references/brainstorming-protocol.md`):
   - One question at a time
   - Focus on WHAT and WHY, never HOW
   - For each proposed objective, immediately stress-test: "Can we measure this mechanically?"

3. **Metric-readiness gate** — for EACH objective:
   - Ask: "What command would produce a number that tells us this is done?"
   - If the user can't answer → the objective is too vague → refine it
   - If they can → record the measurement hint (units, direction, rough target)
   - Example: "API response time under 200ms at p95" → units: ms, direction: lower is better, target: ≤200, command hint: `curl -w '%{time_total}'`

4. **Write/update objectives.md:**
   - Use template from `references/objectives-template.md`
   - Each objective gets a measurement hints section
   - Include Non-Objectives to prevent scope creep
   - Commit to git so the evolution is tracked

5. **Show git history** (if objectives existed before):
   - `git log --oneline docs/superresearch/objectives.md`
   - Highlight what changed and why

## Objective Format

Each objective should look like:

```markdown
### Objective N: {Name}

{What and why — no implementation details}

**Done when:** {Testable completion criteria}
**Measurement hints:** {units} | {direction} | {rough target} | {command hint}
```

## Arguments

$ARGUMENTS — optional: "review" to just show current objectives without editing
