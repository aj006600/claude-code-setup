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
If suggestions returned → 不只 summarize,執行三步:

1. **詳細呈現**每條建議:具體位置、修改前後對比、agent 的理由
2. **CLAUDE 附上自己的判斷**:每條標 `[強烈建議]` / `[可選]` / `[不同意](理由)`
3. **等待 User 決定**:明確提問「要採納哪些?」

**重要**:User 決定採納任何條目後,不在此 command 內直接改——交棒給 `tdd-feature-workflow` 階段 3.3 走 TDD 流程(更新測試 → 修改代碼 → 重跑全測試)。

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

### 2.6 External-repo reference scan

Scan for `owner/repo#N` shortcuts and `https://github.com/owner/repo/(issues|pull)/N` URLs that point to OTHER repos than this one's origin. These would create GitHub "mentioned in ..." backlinks and leak PR content to unrelated projects' issues.

Scope to scan:
- The PR body draft you are about to pass to `gh pr create` (including `--body-file` contents, which the `external-ref-guard.sh` hook cannot see)
- Commit messages on this branch since it diverged from the base branch: `git log <base>..HEAD --format=%B`

Derive current repo from `git remote get-url origin`. Skip refs already wrapped in backticks (GitHub suppresses cross-refs inside inline code spans).

If any external refs found → WARNING. Show each finding with its source (PR body / which commit). Suggest wrapping in backticks or rephrasing per `.claude/rules/git-rules.md` Cross-repo 引用安全格式. Do not block at this level — the hook will block at the actual `git commit` / `gh pr create` invocation.

**Note**: Level 2.3-2.5 are tool-conditional — unavailable tools silently skip. Level 1 (tests) remains the only hard gate. This matches `code-style.md`'s "Recommended Tools" positioning.

## Level 3: Hints (inform only, no gate)

### 3.1 SPEC.md 對應性
Read `.claude/SPEC.md`. 本次 branch 的變更是否已在 SPEC 中有對應的 Functional Requirement?
- 有對應且 Acceptance Criteria 準確 → 通過
- 有對應但實作中產生新 Acceptance / 細節變化未寫回 → hint: 啟用 `maintaining-spec-md` 回寫
- 無對應 Functional Requirement(新功能未寫入 SPEC) → hint: 啟用 `maintaining-spec-md` 補上

### 3.2 README / docs sync
Inspect changed files in this branch. Do they include user-facing changes (new features, API changes, install step changes, new env vars, new dependencies)?
If yes → hint: suggest activating `maintaining-readme-md` skill before PR.

## Final report

```
Pre-PR Check Results

[Level 1] Tests: <X> passed / FAILED
[Level 2] Coverage: <X>% | below target 70%: <modules>
[Level 2] code-simplifier: clean | <N> suggestions (see above)
[Level 2] ruff check: clean | <N> issues | skipped (not installed)
[Level 2] ruff format: clean | drift detected | skipped (not installed)
[Level 2] mypy: clean | <N> type errors | skipped (not installed)
[Level 2] external-ref scan: clean | <N> cross-repo refs found (see above)
[Level 3] SPEC.md: up to date | branch changes not yet reflected in SPEC
[Level 3] README: no user-facing change | user-facing changes detected

Summary:
- Hard gates: PASSED / FAILED
- Soft warnings: <N>
- Hints: <N>

Decision: User should review warnings before creating PR.
```

If Level 1 fails, stop immediately; do not run Level 2 or 3.
