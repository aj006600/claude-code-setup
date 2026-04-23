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
[Level 3] SPEC.md: ✅ up to date | 💡 Status needs update for feature <Y>
[Level 3] README: ✅ no user-facing change | 💡 user-facing changes detected

Summary:
- Hard gates: PASSED / FAILED
- Soft warnings: <N>
- Hints: <N>

Decision: User should review warnings before creating PR.
```

If Level 1 fails, stop immediately; do not run Level 2 or 3.
