# Planning Protocol

Writes comprehensive implementation plans assuming the implementer has zero context. Every task has a metric target. The plan IS the autoresearch iteration sequence.

## Plan Document Location

Save plans to: `docs/superresearch/sessions/{session}/plan.md`

## Scope Check

If the spec covers multiple independent subsystems, break into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified:

- Design units with clear boundaries and well-defined interfaces
- Prefer smaller, focused files over large ones
- Files that change together should live together
- In existing codebases, follow established patterns

## Plan Header

Every plan MUST start with:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]
**Architecture:** [2-3 sentences about approach]
**Tech Stack:** [Key technologies/libraries]
**Verify:** [The verify command from metrics.md]
**Guard:** [The guard command from metrics.md]

---
```

## Bite-Sized Task Granularity

Each step is one action (2-5 minutes):
- "Write the failing test" — step
- "Run it to make sure it fails" — step
- "Implement the minimal code to make the test pass" — step
- "Run the tests and make sure they pass" — step
- "Commit" — step

## Task Structure

````markdown
### Task N: [Component Name] — metric target: X/Y → Z/Y

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## Superresearch-Specific Rules

1. **Every task has a metric target** — not just "Create CLI entry point" but "Create CLI entry point — verify score goes from 0 to 1/10"
2. **The plan IS the autoresearch iteration sequence** — each task becomes one iteration in the build loop
3. **Verify and guard commands come from metrics.md** — never invent them in the plan
4. **Tasks are ordered by metric contribution** — highest-impact tasks first

## Remember

- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits
