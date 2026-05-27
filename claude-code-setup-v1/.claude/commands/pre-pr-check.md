---
description: PR 前 workflow-aware 檢查（測試+coverage、code-simplifier、external-ref body scan、跨文件一致性、SPEC / architecture / decisions / README hints）
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

### 2.3 Cross-artifact consistency（文件一致性掃描）

借 spec-kit `/analyze` 概念:以工具掃描取代手動 health check。對存在的文件(`.claude/SPEC.md`、`.claude/docs/architecture.md`、`.claude/docs/decisions/decisions.md`)逐項驗:

1. **`[NEEDS CLARIFICATION]` 殘留**——SPEC 內未解的釐清標記不該帶進 PR:
   ```bash
   grep -rn 'NEEDS CLARIFICATION' .claude/SPEC.md 2>/dev/null
   ```
   命中 → WARNING:需求未收斂,建議 PR 前用 `maintaining-spec-md` 解決。

2. **ADR Status 一致性**——`decisions.md` 的 Decision Index 表所列 Status,須與對應 ADR 本體的 Status 欄一致。逐條比對,不一致 → WARNING(列出 ADR 編號)。

3. **Cross-ref 連結可解析**——SPEC / architecture / decisions 之間的 markdown 連結(檔案路徑 + 同檔錨點)是否指向實際存在的目標。斷鏈 → WARNING(列出來源與目標)。

4. **Footer 一致**——SPEC.md / architecture.md 的 `Version` + `Last Updated` 是否存在且與其 Change Log 對得上;CLAUDE.md 只需 `Last Updated`(無 SemVer)。不一致 → WARNING。

皆通過 → 一行 pass。本層為 soft gate(warn but continue),提供文件健康度訊號,不阻擋 PR。

## Level 3: Hints (inform only, no gate)

### 3.1 SPEC.md 對應性
Read `.claude/SPEC.md`. 本次 branch 的變更是否已在 SPEC 中有對應的 Functional Requirement?
- 有對應且 Acceptance Criteria 準確 → 通過
- 有對應但實作中產生新 Acceptance / 細節變化未寫回 → hint: 啟用 `maintaining-spec-md` 回寫
- 無對應 Functional Requirement(新功能未寫入 SPEC) → hint: 啟用 `maintaining-spec-md` 補上

### 3.2 README / docs sync
Inspect changed files in this branch. 是否包含 user-facing 變更(新功能、API 變動、安裝步驟變動、新環境變數、新依賴)?
若是 → hint: 建議 PR 前啟用 `maintaining-readme-md` skill。

### 3.3 architecture.md sync
Read `.claude/docs/architecture.md`(若存在)。本次 branch 是否含**現行架構**變更?
- 新增 / 移除模組、服務、元件;目錄重組
- Tech Stack 變更(新依賴於 `pyproject.toml`、換框架、加 DB / queue / SDK)
- 核心資料流改變

任一命中 → hint: 啟用 `maintaining-architecture-md` 同步 architecture.md。

### 3.4 decisions / ADR sync
本次 branch 是否含**架構決策**(在 2+ 方案中選 1 且有 trade-off、引入新依賴 / 機制、推翻既有設計)?
- 是,且尚未有對應 ADR → hint: 啟用 `maintaining-decisions-md` 補 ADR(記錄 Why)
- 既有 ADR 因本次變更被取代 → hint: 更新該 ADR Status 為 Superseded + 開新 ADR

### 3.5 CLAUDE.md sync

對照 `maintaining-claude-md` 觸發情境逐項 check;任一命中 → hint:

- **開發規範**:新 coding convention、新流程要求、新測試策略(覆蓋率、測試類型)
- **工作流程**:Git workflow / CI / CD / 文檔更新流程變更
- **專案需求**:User 特殊習慣、效能 / 安全 / 合規限制
- **SPEC.md 連動**:Project Overview 變更帶來新開發原則(技術棧 / 架構變更走 L3.3,不在此)

任一命中 → hint: 啟用 `maintaining-claude-md` 同步 CLAUDE.md。

## Final report

**只列非 clean 的條目**;全部通過則一行 `All Level 1–3 checks passed`。

非全綠範例:
```
Pre-PR Check Results

[L1] FAILED — pytest exit non-zero (e.g., 2 tests failed / coverage 65% < 70%)
[L2.1] code-simplifier: <N> suggestions (see above)
[L2.2] external-ref scan: <N> cross-repo refs in pr-body.md
[L2.3] consistency: 1 NEEDS CLARIFICATION 殘留 in SPEC.md; ADR-0003 Status 與 Index 不一致
[L3.1] SPEC.md: branch changes not yet reflected
[L3.2] README: user-facing changes detected → consider maintaining-readme-md
[L3.3] architecture.md: new dependency in pyproject.toml → consider maintaining-architecture-md
[L3.4] decisions: architecture decision detected, no ADR yet → consider maintaining-decisions-md
[L3.5] CLAUDE.md: new workflow rule → consider maintaining-claude-md

Hard gate: FAILED → fix before PR
Soft warnings: <N>; Hints: <N>
```

L1 失敗時立即 STOP,不跑 L2 / L3。
