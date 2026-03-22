# Brainstorming Protocol

Collaborative design process for Steps 1-3 (Objectives, Metrics, Spec). Turns ideas into fully formed designs through structured dialogue before any implementation begins.

## Hard Gate

Do NOT write any code, create any implementation files, or take any build action until:
1. Objectives are defined and approved (Step 1)
2. Metrics are defined and approved (Step 1)
3. Spec is written and FMECA'd (Step 2-3)

## The Process

### Understanding the Idea

- Check project state first (files, docs, recent commits, vault objectives)
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems, flag this immediately — decompose before refining
- If too large for a single session, help decompose into sub-projects. Each gets its own objectives → metrics → spec → build cycle
- Ask questions **one at a time** to refine the idea
- Prefer multiple choice when possible, open-ended when not
- Focus on: purpose, constraints, success criteria

### Exploring Approaches

- Propose 2-3 different approaches with trade-offs
- Lead with your recommended option and explain why
- Present options conversationally

### Presenting the Design

- Once you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if simple, detailed if nuanced
- Ask after each section whether it looks right
- Cover: architecture, components, data flow, error handling, testing
- Go back and clarify when something doesn't make sense

## Design Principles

- **One question at a time** — don't overwhelm
- **Multiple choice preferred** — easier than open-ended
- **YAGNI ruthlessly** — remove unnecessary features from all designs
- **Explore alternatives** — always propose 2-3 approaches before settling
- **Incremental validation** — present design, get approval before moving on
- **Design for isolation** — smaller units with clear boundaries and interfaces

## Working in Existing Codebases

- Explore current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work, include targeted improvements as part of the design
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

## Anti-Pattern: "This Is Too Simple"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short, but you MUST present it and get approval.

## Superresearch-Specific Adaptations

In superresearch, brainstorming serves three distinct steps:

1. **Step 1 (Objectives + Metrics):** Brainstorm WHAT, WHY, and HOW to measure it. Each objective must be testable; every metric must produce a number from a command.
2. **Step 2 (FMECA):** Validate the metrics — three adversarial questions per metric.
3. **Step 3 (Build):** Brainstorm the implementation plan. Optional plan and spec reference objectives by number and metrics by name.

The brainstorming output flows into structured artifacts — not just a design doc, but three separate documents with clear separation of concerns.
