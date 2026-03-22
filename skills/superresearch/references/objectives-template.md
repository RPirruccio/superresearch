# Objectives Template

Use this template for `docs/superresearch/objectives.md` (project-level, persistent).

---

```markdown
# Objectives — {Project Name}

**Created:** YYYY-MM-DD
**Last updated:** YYYY-MM-DD
**Project:** {project name}

## Context

{What this project is and what it's trying to achieve at a high level.}

## Objectives

### Objective 1: {Name}

{What this objective achieves and why it matters. No implementation details — no file paths, no technology choices, no architecture decisions.}

**Done when:** {How would you know this objective is met? Must be testable.}
**Measurement hints:** {units} | {direction: higher/lower is better} | {rough target} | {command hint}

### Objective 2: {Name}

{Description}

**Done when:** {Testable completion criteria}
**Measurement hints:** {units} | {direction} | {rough target} | {command hint}

### Objective 3: {Name}

{Description}

**Done when:** {Testable completion criteria}
**Measurement hints:** {units} | {direction} | {rough target} | {command hint}

## Non-Objectives

- {Things explicitly NOT in scope for this project}
- {Things that might seem related but aren't goals}

## Deprecated Objectives

- {Objectives that were once active but have been retired, with date and reason}

## Source

- {Link to project knowledge if it exists}
- {Link to any triggering context: issue, conversation, vault note}
```

---

## Rules

1. **Abstract only** — no file paths, no technology choices, no architecture
2. **Each objective must be metric-ready** — you must be able to derive a verify command from it
3. **Measurement hints are mandatory** — units, direction, rough target, command hint
4. **Separate from architecture** — objectives are WHAT and WHY, never HOW
5. **Non-objectives are mandatory** — explicitly state what's NOT in scope
6. **Deprecated section** — don't delete old objectives, mark them deprecated with date and reason so the evolution is visible
7. **Version controlled** — commit every change so `git log` tells the story

## Conflict Resolution

When a new request contradicts an existing objective:

| Situation | Action |
|---|---|
| New request directly contradicts existing objective (e.g., "fast" vs "feature-complete over fast") | Surface the conflict to the user. Present both objectives. Ask which takes priority. The losing objective gets deprecated with reason, or revised to coexist. |
| New request adds scope that stretches an existing objective beyond its original intent | Split into two objectives — the original (unchanged) and a new one for the expanded scope. |
| Existing objective is outdated but nobody noticed | Mark deprecated with date and reason. Add replacement if needed. This is healthy evolution — document it. |
| Two existing objectives conflict with each other (discovered during session) | This is a FMECA finding on the objectives themselves. Surface to user, resolve before proceeding to Step 1. |

**Never silently override an objective.** If priorities change, the change must be explicit, documented, and committed. That's how `git log objectives.md` tells the real story.

## Metric-Readiness Test

For each objective, ask: "What shell command would produce a number that tells us this is done?"

| Result | Action |
|---|---|
| You can write the command immediately | Objective is metric-ready |
| You can describe what to measure but not the command | Needs refinement — specify the measurement more precisely |
| You can't describe what to measure | Objective is too vague — decompose or reframe |
