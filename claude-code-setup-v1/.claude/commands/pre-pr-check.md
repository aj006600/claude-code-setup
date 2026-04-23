---
description: PR 前的完整檢查（Level 1 hard gates / Level 2 soft warnings / Level 3 hints）
---

Execute all pre-PR checks in order. Apply different pass/fail behavior per level.

## Level 1: Hard gates (stop on first failure)

### 1.1 All tests pass
```bash
uv run pytest tests/ -v
```
If any test fails → **STOP**. Do not run Level 2 or 3. Report failures; User must fix before PR.

## Level 2: Soft gates (warn but continue)

### 2.1 Coverage ≥ 70%
```bash
uv run pytest tests/ --cov=src --cov-report=term-missing
```
If below 70% → WARNING. List modules below target.

### 2.2 Code quality via `code-simplifier:code-simplifier` agent
Use Agent tool:
```
Agent({
  subagent_type: "code-simplifier:code-simplifier",
  description: "Pre-PR code quality review",
  prompt: "Review files changed in this branch compared to the dev base branch. Focus on: duplication, overly complex code, missing abstractions, unclear naming. Report findings WITHOUT modifying any files."
})
```
If suggestions returned → WARNING. Summarize findings.

### 2.3 Lint via `ruff check` (if available)
```bash
if command -v ruff >/dev/null 2>&1; then
  uv run ruff check . || echo "[pre-pr-check] ruff check found issues"
else
  echo "[pre-pr-check] ruff not installed — skipping lint"
fi
```
If issues found → WARNING. Surface specific rule violations; do not block.

### 2.4 Format check via `ruff format --check` (if available)
```bash
if command -v ruff >/dev/null 2>&1; then
  uv run ruff format . --check || echo "[pre-pr-check] files need formatting"
else
  echo "[pre-pr-check] ruff not installed — skipping format check"
fi
```
If drift detected → WARNING. Suggest running `uv run ruff format .`; do not block.

### 2.5 Type check via `mypy` (if available)
```bash
if command -v mypy >/dev/null 2>&1; then
  uv run mypy src/ || echo "[pre-pr-check] mypy found type errors"
else
  echo "[pre-pr-check] mypy not installed — skipping type check"
fi
```
If type errors found → WARNING. Summarize top issues; do not block.

**Note**: Level 2.3-2.5 are tool-conditional — unavailable tools silently skip. Level 1 (tests) remains the only hard gate. This matches `code-style.md`'s "Recommended Tools" positioning.

## Level 3: Hints (inform only, no gate)

### 3.1 SPEC.md Status
Read `.claude/SPEC.md`. For the feature being worked on, is Status `In Progress` or `Completed`?
If outdated → hint: suggest activating `maintaining-spec-md` skill.

### 3.2 README / docs sync
Inspect changed files in this branch. Do they include user-facing changes (new features, API changes, install step changes, new env vars, new dependencies)?
If yes → hint: suggest activating `maintaining-readme-md` skill before PR.

## Final report

```
🔍 Pre-PR Check Results

[Level 1] Tests: ✅ <X> passed / FAILED
[Level 2] Coverage: ✅ <X>% | ⚠️ <X>% (target 70%) - below: <modules>
[Level 2] code-simplifier: ✅ clean | ⚠️ <N> suggestions (see above)
[Level 2] ruff check: ✅ clean | ⚠️ <N> issues | ⏭ skipped (not installed)
[Level 2] ruff format: ✅ clean | ⚠️ drift detected | ⏭ skipped (not installed)
[Level 2] mypy: ✅ clean | ⚠️ <N> type errors | ⏭ skipped (not installed)
[Level 3] SPEC.md: ✅ up to date | 💡 Status needs update for feature <Y>
[Level 3] README: ✅ no user-facing change | 💡 user-facing changes detected

Summary:
- Hard gates: PASSED / FAILED
- Soft warnings: <N>
- Hints: <N>

Decision: User should review warnings before creating PR.
```

If Level 1 fails, stop immediately; do not run Level 2 or 3.
