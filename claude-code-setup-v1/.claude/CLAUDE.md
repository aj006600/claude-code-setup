<!-- TEMPLATE NOTICE
本檔案是 claude-code-setup-v1 template 的一部分。
採用到新專案時,請替換所有 `<Placeholder>` 佔位符與 `<!-- TEMPLATE: ... -->` 註解區塊。
完整使用說明見 template 根目錄的 `README.md`。
-->

# CLAUDE.md

## Project Overview (專案概述)
**核心原則**:CLAUDE CODE 需查看並遵循 `.claude/SPEC.md` 進行動態調整。

<!-- TEMPLATE: Replace with your project's one-liner description -->
`<Project Name>` — `<One-sentence description of what this project does>`

---

## Tech Stack (技術堆疊)

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

<!-- TEMPLATE: Replace the tree below with your actual project structure -->

```
<project-name>/
├── .claude/                  # Claude Code 配置
│   ├── CLAUDE.md             # 開發規範 (本文件)
│   ├── SPEC.md               # 專案規格(由 maintaining-spec-md skill 建立)
│   ├── CLAUDE-CHANGELOG.md   # 本專案 CLAUDE.md 變更歷史(Keep a Changelog)
│   ├── rules/                # 開發規範參考(見 Rules Index 章節)
│   ├── skills/               # 專案專屬 skills
│   ├── commands/             # Slash commands
│   ├── agents/               # Sub-agents
│   ├── hooks/                # PreToolUse hooks(見 Safety & Hooks 章節)
│   └── settings.json         # Claude Code 設定
├── src/                      # 主要程式碼
│   └── <your-modules>/       # 依專案需求組織
├── tests/                    # 測試檔案
│   ├── unit/                 # 單元測試
│   ├── integration/          # 整合測試
│   ├── e2e/                  # 端到端測試
│   └── conftest.py           # Pytest fixtures
├── docs/                     # 文檔
├── pyproject.toml            # Python 專案配置(uv、ruff、mypy、pytest)
├── .env                      # 環境變數(加入 .gitignore)
├── .gitignore
└── README.md                 # 專案說明
```

---

## Development Workflow (開發流程)

**核心原則:嚴格遵守 TDD**——所有實作路徑必須經過 `writing-plans → executing-plans` 的測試先行流程。

新功能 / bug 修復 / 重構 → 啟用 `tdd-feature-workflow` skill 編排 4 階段(需求 → 開發 → PR → Review & Merge)。完整流程、階段轉場 gate、委派對象見該 skill。

常用 commands:
- `/pre-dev-check` — 開發前環境檢查(git 狀態、origin/dev 同步)
- `/pre-pr-check` — PR 前 workflow-aware 檢查(測試+coverage、code-simplifier、external-ref body scan、SPEC / README hints);ruff / format / mypy 由 CI 權威執行不重複
- `/project-status` — 快速狀態快照

---

## Coding Conventions (編碼規範)

### Modular Design
- **Single Responsibility**: 每個檔案專注於一個功能
- **Loose Coupling**: 模組間通過清晰的介面通訊
- **High Cohesion**: 相關功能放在同一個模組
- **Testability**: 避免全域狀態,方便 mock

### SOLID
- **S - Single Responsibility**: 一個類別只負責一件事
- **O - Open/Closed**: 對擴展開放,對修改封閉
- **L - Liskov Substitution**: 子類別可替換父類別
- **I - Interface Segregation**: 多個專用介面優於通用介面
- **D - Dependency Inversion**: 依賴抽象而非具體實作

詳細命名、type hints、docstring、import 規範見 `.claude/rules/code-style.md`。

---

## Testing Protocols (測試規範)
**核心原則**:每次程式碼改動都必須遵循 TDD。

### TDD Flow
撰寫測試 → 執行測試(失敗)→ 實作功能 → 執行測試(通過)→ 重構(如需要)→ 執行所有測試(確保無 regression)

### Strategy
- **Unit Test**: 核心功能必須有單元測試
- **Integration Test**: 視需求添加
- **Coverage**: 目標 70%+(用 `/pre-pr-check` command 驗證)

寫測試的正式入口是 `tdd-feature-workflow` 階段 2 的 `superpowers:writing-plans → superpowers:executing-plans`(plan 每個 task 內建 `寫 failing test → watch it fail → 最小實作 → watch it pass → commit` TDD 循環);`superpowers:test-driven-development` skill 作為紅綠節奏疑義時的紀律參考,不獨立啟用為階段。詳細測試慣例、fixture、mocking、parametrize 範例見 `.claude/rules/testing-rules.md`。

---

## Rules Index (規範檔索引)

四個 rules 檔,各管一個領域。對應操作時 Claude 應查閱:

| Rule | 用途 |
|------|------|
| `.claude/rules/code-style.md` | Python 命名、docstring、type hints、import、quotes、行寬——**程式碼實作時** |
| `.claude/rules/testing-rules.md` | pytest 慣例、fixture、mocking、markers、coverage 配置——**寫測試時** |
| `.claude/rules/git-rules.md` | 分支策略、commit message 格式、cross-repo 引用安全——**commit / push / PR 時** |
| `.claude/rules/documentation-style.md` | Markdown 撰寫、章節命名、Footer、Mermaid 圖表——**寫 README / docs 時** |

---

## Safety & Hooks (安全防護)

兩個 PreToolUse hooks 在 `Bash` 工具調用前執行。Claude 做 git / gh 操作時應意識其存在:

| Hook | 作用 | 行為 |
|------|------|------|
| `secrets-scan-advisory.sh` | 掃 staged 檔名與 diff 中的 secret pattern(AWS key / GitHub PAT / 私鑰等) | Advisory(`exit 0`,警告不阻擋) |
| `external-ref-guard.sh` | `git commit` / `gh pr/issue create\|edit\|comment` 前掃 `owner/repo#N` 與 GitHub URL,偵測外部 repo 裸 reference | **Guard(`exit 1`,阻擋)**——防止 cross-repo backlink leak |

被 guard 擋下時:用反引號包 ref(例 `` `foo/bar#123` ``)或改寫後重試;詳見 `git-rules.md` 的「Cross-repo 引用安全格式」。

---

## Available Resources (常用資源)

完整動態清單執行 `/agent-cheatsheet` command。以下為最核心入口:

- **`tdd-feature-workflow` skill** — 開發編排器(任何 feature / bug / refactor 起點)
- **`maintaining-spec-md` / `maintaining-claude-md` / `maintaining-readme-md` skills** — 專案文檔維護,依情境自動觸發
- **`/pre-dev-check` / `/pre-pr-check` commands** — 開發前 / PR 前檢查
- **`context7` MCP** — 查最新 library 文檔

本地 agents(`agents/` 目錄共 3 個:`code-reviewer` / `documentation-engineer` / `test-automator`)由 skill 透過 Agent tool 委派,不需手動記憶;想看時執行 `/agent-cheatsheet`。

---

**Last Updated**: `<YYYY-MM-DD>`(由 maintaining-claude-md Workflow A 首次客製化時填入)
**Version**: `<vX.Y.Z>`(由 maintaining-claude-md Workflow A 首次客製化時填入;預設 v1.0.0)
