---
description: PR 前 workflow-aware 檢查（測試+coverage、code-simplifier、external-ref body scan、SPEC / README hints）
---

Run pre-PR checks that complement CI. `.github/workflows/ci.yml` is the authoritative pre-merge gate for ruff / format / mypy / tests / coverage; this command does **not** repeat those tools. It runs:

- a single combined test+coverage local fast-fail (highest signal for CI failure)
- workflow-aware items CI cannot do (interactive code-simplifier dispatch, PR body file scan, SPEC / README sync hints)

## Level 1: Hard gate

### 1.1 Tests + coverage
```bash
uv run pytest --cov=src --cov-report=term-missing --cov-fail-under=70
```
測試失敗或 coverage 低於 70% → **STOP**。User 修復後重跑;不進 Level 2 / 3。

`--cov-fail-under=70` 與 CI L42 (`.github/workflows/ci.yml`) 及 `pyproject-tooling.example.toml` (`[tool.coverage.report] fail_under = 70`) 對齊;此值為單一 source of truth。

## Level 2: Soft gates (warn but continue)

### 2.1 Code quality via `code-simplifier:code-simplifier` agent

Dispatch the agent and surface findings:
```
Agent({
  subagent_type: "code-simplifier:code-simplifier",
  description: "Pre-PR code quality review",
  prompt: "Review files changed in this branch compared to the dev base branch. Focus on: duplication, overly complex code, missing abstractions, unclear naming. Report findings WITHOUT modifying any files."
})
```

Findings 的處理流程(詳細呈現 → CLAUDE 標 [強烈建議] / [可選] / [不同意] → User 決定 → 採納回階段 2 走 TDD → 不採納記錄到 PR description)由 `tdd-feature-workflow/SKILL.md` 階段 3.3 統一管理,不在此 command 內重述,避免雙寫漂移。

### 2.2 External-repo reference scan (PR body file)

`external-ref-guard.sh` PreToolUse hook 已擋 `git commit` / `gh pr|issue create|edit|comment` 命令文本含外部 repo ref(`owner/repo#N` 或 `https://github.com/owner/repo/(issues|pull)/N`)。但 hook 看不到 `--body-file <path>` 的檔案內容;此處補位:

掃 branch 內可能作為 PR body 的檔案——**預設掃**:
- `pr-body.md`(專案根 / `.github/`)
- `.github/PULL_REQUEST_TEMPLATE.md`
- 對話中 user 明示作為 `--body-file` 的任何路徑

掃描內容偵測指向**其他 repo**(非 `git remote get-url origin`)的 refs。Backticks 內的 ref 視為安全(GitHub code span 不做 reference parsing,跳過)。

若有外部 ref → WARNING,列出 finding 與所在檔;建議用 backticks 包或改寫(見 `git-rules.md` Cross-repo 引用安全格式)。不 block——hook 會在實際 `gh pr create --body-file` 時以命令文本層級擋下(若 body-file 路徑出現在 command,hook 至少能看到引用本身;但內容仍須此處掃描)。

## Level 3: Hints (inform only, no gate)

### 3.1 SPEC.md 對應性
Read `.claude/SPEC.md`. 本次 branch 的變更是否已在 SPEC 中有對應的 Functional Requirement?
- 有對應且 Acceptance Criteria 準確 → 通過
- 有對應但實作中產生新 Acceptance / 細節變化未寫回 → hint: 啟用 `maintaining-spec-md` 回寫
- 無對應 Functional Requirement(新功能未寫入 SPEC) → hint: 啟用 `maintaining-spec-md` 補上

### 3.2 README / docs sync
Inspect changed files in this branch. 是否包含 user-facing 變更(新功能、API 變動、安裝步驟變動、新環境變數、新依賴)?
若是 → hint: 建議 PR 前啟用 `maintaining-readme-md` skill。

### 3.3 CLAUDE.md / CLAUDE-CHANGELOG.md sync

對照 `maintaining-claude-md` 5 類觸發情境逐項 check;任一命中 → hint:

- **開發規範**:新 coding convention、新流程要求、新測試策略(覆蓋率、測試類型)
- **專案結構**:新增 / 移除目錄、模組重組、新技術堆疊
- **工作流程**:Git workflow / CI / CD / 文檔更新流程變更
- **專案需求**:User 特殊習慣、效能 / 安全 / 合規限制
- **SPEC.md 連動**:Project Overview / FR 變更帶來新依賴或架構需求(若 L3.1 已 hint SPEC 更新且涉此類則連動)

任一命中 → hint: 啟用 `maintaining-claude-md` 同步 CLAUDE.md + CLAUDE-CHANGELOG.md。

## Final report

**只列非 clean 的條目**;全部通過則一行 `All Level 1–3 checks passed`。

非全綠範例:
```
Pre-PR Check Results

[L1] FAILED — pytest exit non-zero (e.g., 2 tests failed / coverage 65% < 70%)
[L2.1] code-simplifier: <N> suggestions (see above)
[L2.2] external-ref scan: <N> cross-repo refs in pr-body.md
[L3.1] SPEC.md: branch changes not yet reflected
[L3.2] README: user-facing changes detected → consider maintaining-readme-md
[L3.3] CLAUDE.md: tech stack changed in pyproject.toml → consider maintaining-claude-md

Hard gate: FAILED → fix before PR
Soft warnings: <N>; Hints: <N>
```

L1 失敗時立即 STOP,不跑 L2 / L3。
