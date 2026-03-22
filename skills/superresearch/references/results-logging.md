# Results Logging Protocol

Track every iteration in a structured log. Enables pattern recognition and prevents repeating failed experiments.

## Log Location

Create `results.tsv` in the session directory: `docs/superresearch/sessions/{session}/results.tsv`

## Log Format (TSV)

```tsv
iteration	commit	metric	delta	guard	status	description
```

### Columns

| Column | Type | Description |
|--------|------|-------------|
| iteration | int | Sequential counter starting at 0 (baseline) |
| commit | string | Short git hash (7 chars), "-" if reverted |
| metric | float | Measured value from verification |
| delta | float | Change from previous best (negative = improved for "lower is better") |
| guard | enum | `pass`, `fail`, or `-` (no guard configured) |
| status | enum | `baseline`, `keep`, `discard`, `crash` |
| description | string | One-sentence description of what was tried |

### Example

```tsv
iteration	commit	metric	delta	guard	status	description
0	a1b2c3d	85.2	0.0	pass	baseline	initial state — test coverage 85.2%
1	b2c3d4e	87.1	+1.9	pass	keep	add tests for auth middleware edge cases
2	-	86.5	-0.6	-	discard	refactor test helpers (broke 2 tests)
3	-	0.0	0.0	-	crash	add integration tests (DB connection failed)
4	-	88.9	+1.8	fail	discard	inline hot-path functions (guard: 3 tests broke)
5	c3d4e5f	88.3	+1.2	pass	keep	add tests for error handling in API routes
```

## Log Management

- Create at setup (iteration 0 = baseline)
- Append after EVERY iteration (including crashes)
- Read last 10-20 entries at start of each iteration for context
- Use to detect patterns: what kind of changes tend to succeed?

## Metric Direction

Clarify at setup whether lower or higher is better:
- **Lower is better:** response time (ms), bundle size (KB), error count
- **Higher is better:** test coverage (%), lighthouse score, verify score

Record direction in first line of results log as a comment:
```
# metric_direction: higher_is_better
```

## Summary Reporting

Every 10 iterations (or at loop completion), print:

```
=== Superresearch Progress (iteration 20) ===
Baseline: 85.2% → Current best: 92.1% (+6.9%)
Keeps: 8 | Discards: 10 | Crashes: 2
Last 5: keep, discard, discard, keep, keep
```

## Fix Loop Results (Step 2: Validate the Measure)

When using the fix loop for spec verification, use a slightly adapted format:

```tsv
iteration	category	target	delta	guard	status	description
0	-	-	-	pass	baseline	47/100 spec score, 12 gaps detected
1	gap	error-handling	-2	pass	fixed	add error handling strategy section
2	gap	test-strategy	-1	pass	fixed	add test strategy with coverage targets
3	structure	non-goals	0	-	discard	wrong section — non-goals were already present
```

The `category` and `target` columns replace `commit` and `metric` for fix loops, since the focus is on error categories and specific fix targets rather than metric optimization.
