<!-- TEMPLATE NOTICE
本檔案是 claude-code-setup-v1 template 的一部分。
採用到新專案時，請替換所有 `<Placeholder>` 佔位符與 `<!-- TEMPLATE: ... -->` 註解區塊。
完整使用說明見 template 根目錄的 `README.md`。
-->

# CLAUDE.md

## Project Overview (專案概述)
**核心原則**：CLAUDE CODE 需查看並遵循 `.claude/SPEC.md` 進行動態調整。

<!-- TEMPLATE: Replace with your project's one-liner description -->
`<Project Name>` — `<One-sentence description of what this project does>`

---

## Tech Stack (技術堆疊)
**核心原則**：CLAUDE CODE 需根據專案需求自行動態擴充或調整。

<!-- TEMPLATE: Below is a Python-focused baseline. Replace items marked with `<...>` to fit your project. -->

- **Language**: Python 3.11+
- **Package Manager**: uv
- **Web Framework**: `<your framework, e.g., FastAPI / Starlette / Django>`
- **Testing**: pytest, pytest-asyncio
- **Linter / Formatter**: ruff
- **Type Checker**: mypy
- **Version Control**: Git
- **其他依賴**: `<list project-specific dependencies here, e.g., database clients, SDK integrations>`

---

## Architecture (專案架構)
**核心原則**：功能模組化、漸進式建立、靈活調整。CLAUDE CODE 需依專案更動自行修改、擴展。

<!-- TEMPLATE: Replace the tree below with your actual project structure -->

```
<project-name>/
├── .claude/                  # Claude Code 配置
│   ├── CLAUDE.md             # 開發規範 (本文件)
│   ├── SPEC.md               # 專案規格（由 maintaining-spec-md skill 建立）
│   ├── CLAUDE-CHANGELOG.md   # CLAUDE.md 變更歷史
│   ├── rules/                # 開發規範參考
│   ├── skills/               # 專案專屬 skills
│   ├── commands/             # Slash commands
│   ├── agents/               # Sub-agents
│   ├── hooks/                # Advisory hooks
│   └── settings.json         # Claude Code 設定
├── src/                      # 主要程式碼
│   └── <your-modules>/       # 依專案需求組織
├── tests/                    # 測試檔案
│   ├── unit/                 # 單元測試
│   ├── integration/          # 整合測試
│   ├── e2e/                  # 端到端測試
│   └── conftest.py           # Pytest fixtures
├── docs/                     # 文檔
├── pyproject.toml            # Python 專案配置（uv、ruff、mypy、pytest）
├── .env                      # 環境變數（加入 .gitignore）
├── .gitignore
└── README.md                 # 專案說明
```

---

## Development Workflow (開發流程)
**核心原則**：開發新功能 / bug 修復 / 重構時，啟用 `tdd-feature-workflow` skill。該 skill 會編排完整 4 階段 TDD 流程並委派給 superpowers skills（`brainstorming`、`writing-plans`、`executing-plans`、`test-driven-development`、`finishing-a-development-branch`）與 local agents（`test-automator`、`code-reviewer`）。**嚴格遵守 TDD**：所有實作路徑必須經過 `writing-plans → executing-plans` 的測試先行流程。

四階段速覽：

### 1. 需求確認
User 提需求 → 啟用 `maintaining-spec-md` skill → User 確認 SPEC.md 後開始

### 2. 開發（TDD）
建立功能分支 → 撰寫測試（`test-automator` agent 或 `superpowers:test-driven-development` skill）→ 實作功能（`superpowers:executing-plans` skill）→ 測試通過 → 更新 SPEC.md Status

### 3. 提交與 PR
執行 `/pre-pr-check` command（含 `code-simplifier:code-simplifier` 審查）→ 提交變更 → 推送分支 → 在 GitHub 建立 PR

### 4. Review 與 Merge
`code-reviewer` agent → 更新 README（`maintaining-readme-md` skill）→ 合併並清理分支（`superpowers:finishing-a-development-branch` skill）

詳細流程請啟用 `tdd-feature-workflow` skill；查看當前狀態可用 `/project-status` command。

---

## Coding Conventions (編碼規範)
**核心原則**：遵循命名規範、模組化設計、SOLID 原則。

### Naming
- **Classes**: `PascalCase`
- **Functions/Methods**: `snake_case`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private**: 前綴 `_`

### Modular Design
- **Single Responsibility**: 每個檔案專注於一個功能
- **Loose Coupling**: 模組間通過清晰的介面通訊
- **High Cohesion**: 相關功能放在同一個模組
- **Testability**: 避免全域狀態，方便 mock

### SOLID
- **S - Single Responsibility**: 一個類別只負責一件事
- **O - Open/Closed**: 對擴展開放，對修改封閉
- **L - Liskov Substitution**: 子類別可替換父類別
- **I - Interface Segregation**: 多個專用介面優於通用介面
- **D - Dependency Inversion**: 依賴抽象而非具體實作

詳細 coding style 規範見 `.claude/rules/code-style.md`。

---

## Testing Protocols (測試規範)
**核心原則**：**每次程式碼改動都必須遵循 TDD**。寫測試請啟用 `superpowers:test-driven-development` skill 或委派 `test-automator` agent；測試規範細節請見 `.claude/rules/testing-rules.md`。

### TDD Flow
撰寫測試 → 執行測試（失敗）→ 實作功能 → 執行測試（通過）→ 重構（如需要）→ 執行所有測試（確保無 regression）

### Strategy
- **Unit Test**: 核心功能必須有單元測試
- **Integration Test**: 視需求添加
- **Coverage**: 目標 70%+（用 `/pre-pr-check` command 驗證）

---

## Available Agents & Skills (可用資源速查)
**核心原則**：本專案常用 agents / skills / commands 的對照表。完整動態清單請執行 `/agent-cheatsheet` command。

### 常用 Agents（via Agent tool）
- `test-automator`（project-local）— 寫測試
- `code-reviewer`（project-local）— PR review
- `documentation-engineer`（project-local）— 寫 README / docs（由 `maintaining-readme-md` skill 委派）
- `code-simplifier:code-simplifier`（plugin）— 代碼簡化審查

### 常用 Skills（via Skill tool）
**專案維護**（依情境自動觸發）：
- `maintaining-spec-md` — SPEC.md 變更
- `maintaining-claude-md` — CLAUDE.md 變更
- `maintaining-readme-md` — README / docs 變更

**功能開發**：
- `tdd-feature-workflow` — 本專案 TDD 編排器（開始新功能時啟用）
- `superpowers:brainstorming` — 需求設計討論（需求模糊時）
- `superpowers:writing-plans` — 寫 bite-sized TDD plan
- `superpowers:executing-plans` — 批次執行 plan + checkpoint
- `superpowers:test-driven-development` — TDD 紀律
- `superpowers:verification-before-completion` — 完成前強制自檢
- `superpowers:finishing-a-development-branch` — branch 收尾

### 常用 Commands（slash）
- `/project-status` — 快速狀態快照
- `/pre-dev-check` — 開發前檢查
- `/pre-pr-check` — PR 前完整檢查
- `/agent-cheatsheet` — 動態完整清單

---

## Development Checklist (開發檢查項目)
**核心原則**：此清單為靜態 reference。CLAUDE CODE 每次開發時，依對應階段使用 TodoWrite tool 建立本次 session 的動態 todo list 追蹤執行狀態，**不修改本清單本身**。若實作中發現清單內容需優化，啟用 `maintaining-claude-md` skill 走正式更新流程。

完整流程請啟用 `tdd-feature-workflow` skill 自動編排。以下為人工參照用的 checklist：

### 開發前
- 確認 SPEC.md 是否需要更新（啟用 `maintaining-spec-md` skill）
- 執行 `/pre-dev-check` command（涵蓋 git 狀態、遠端同步、測試基線）
- 建立功能分支（遵循 `.claude/rules/git-rules.md` 分支命名規範）

### 開發中
- 先撰寫測試（TDD，委派 `test-automator` agent 或啟用 `superpowers:test-driven-development` skill）
- 實作功能（啟用 `superpowers:executing-plans` skill；技術疑問用 `context7` MCP 查文檔）
- 執行相關測試確認通過
- 執行所有測試確認無 regression（依 Tech Stack 調整；Python 範例：`uv run pytest tests/ -v`）
- 檢查測試覆蓋率（依 Tech Stack 調整；Python 範例：`uv run pytest tests/ --cov=src --cov-report=term-missing`）
- 更新 SPEC.md 功能狀態（啟用 `maintaining-spec-md` skill）

### 提交與 PR
- 執行 `/pre-pr-check` command（含 `code-simplifier:code-simplifier` agent 審查、coverage 驗證、SPEC / README hints）
- 若 `/pre-pr-check` 發現代碼需修改，遵循 TDD：更新測試 → 修改代碼 → 執行相關測試 → 執行所有測試
- 提交變更（遵循 `.claude/rules/git-rules.md` commit 規範）
- 推送分支並建立 PR 到 `dev`

### Review 與 Merge
- Code review（委派 `code-reviewer` agent）；若未通過，回到「開發中」階段依 TDD 流程修改
- Review 通過後更新文檔（啟用 `maintaining-readme-md` skill）
- 合併並清理分支（可啟用 `superpowers:finishing-a-development-branch` skill）

---

**Last Updated**: 2026-04-23
**Version**: v1.1.0
