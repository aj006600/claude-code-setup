# claude-code-setup-v0

Claude Code 專案配置模板 — 第零版:**rule-driven 設計**,透過 CLAUDE.md + rules 被動讀取規範,不含 skill / command / hook / CI 自動化層。

> V1 採用 skill-driven 設計,提供更完整的自動觸發與 workflow 編排。兩者使用相同的外部工具,核心差異在於規範傳遞機制(被動讀取 vs 主動觸發)。詳見 [V0 vs V1 對照](#v0-vs-v1-對照)。

---

## Overview

V0 採 **rule-driven 模式**——Claude Code 透過 `.claude/CLAUDE.md` 引用 `.claude/rules/*.md` 被動讀取規範。使用與 V1 相同的外部工具(superpowers / code-simplifier plugins、context7 / github MCPs),但不含 skill / command / hook / CI 自動化層。

設計訴求:

- **Rule-driven**:所有規範以 markdown 表達,Claude 被動讀取而非由 skill description 主動觸發
- **無自動化層**:無 slash command、無 PreToolUse hook、無 CI workflow
- **Prose 流程描述**:TDD 4 階段、文檔維護流程皆以 prose 敘述,無結構化 workflow 分支判斷

---

## What's Included

### 1 主規範 + 1 專案規格 template
- `.claude/CLAUDE.md` — 主規範入口(Project Overview / Tech Stack / Architecture / Workflow / Conventions / Testing / Development Checklist),動態引用各 rule
- `.claude/SPEC.md` — 專案規格空白模板(Functional Requirements / Acceptance Criteria / Change Log)

### 8 Reference Rules
| Rule | 用途 |
|------|------|
| `spec-update-rules.md` | SPEC.md 撰寫與動態更新指引(5 類觸發點 + 5 步驟流程) |
| `claude-update-rules.md` | CLAUDE.md 何時與如何更新 |
| `readme-update-rules.md` | README / docs 更新流程(PR Review 後 merge 前觸發) |
| `development-workflow-details.md` | TDD 4 階段詳細流程(需求 → 開發 → PR → Review) |
| `git-rules.md` | Branch Strategy + Commit Convention |
| `code-style.md` | Docstring(Google Style + 繁中) |
| `testing-rules.md` | pytest 慣例與範例 |
| `documentation-style.md` | 文檔撰寫規範 + 三類 doc 模板(Service / Reference / Guide) |

---

## Prerequisites

| 工具 | 用途 |
|------|------|
| Python 3.11+ | 開發語言 |
| `uv` | Python 套件管理 |
| `git` | 版本控制 |
| `gh` | GitHub CLI(PR 建立) |
| `superpowers` plugin | TDD plan 執行(`executing-plans`)+ code review(`code-reviewer`) |
| `code-simplifier` plugin | 代碼審查與優化 |
| `context7` MCP | 查詢最新 library 文檔 |
| `github` MCP | GitHub 資源查詢 |

---

## Quick Start

### Step 1:初始化 Python 專案

```bash
mkdir my-project && cd my-project
uv init
```

### Step 2:複製 template setup

```bash
cp -r path/to/claude-code-setup-v0/.claude .
```

### Step 3:啟動 Claude Code 並提出第一個需求

直接說明專案目標,Claude Code 會依 CLAUDE.md 引用的 rules 進行 TDD 開發。建議流程:

1. 請 Claude 依 `.claude/rules/spec-update-rules.md` 草擬 `.claude/SPEC.md` 初版,確認後 commit
2. 提出第一個功能需求 → Claude 依 `.claude/rules/development-workflow-details.md` 執行 4 階段 TDD
3. PR Review 通過後依 `.claude/rules/readme-update-rules.md` 補文檔

---

## Template 結構

```
claude-code-setup-v0/
├── README.md                  # 本檔
├── CHANGELOG.md               # V0 自身演進史
├── ROADMAP.md                 # V0 → V1 設計演進對照
└── .claude/
    ├── CLAUDE.md              # 主規範入口
    ├── SPEC.md                # 專案規格空白模板
    └── rules/
        ├── claude-update-rules.md
        ├── code-style.md
        ├── development-workflow-details.md
        ├── documentation-style.md
        ├── git-rules.md
        ├── readme-update-rules.md
        ├── spec-update-rules.md
        └── testing-rules.md
```

---

## V0 vs V1 對照

| 面向 | V0(本版) | V1 |
|------|------------------|--------------|
| 設計典範 | Rule-driven(Claude 被動讀規範) | Skill-driven(規範由 skill description 主動觸發載入) |
| 文檔維護 | `claude-update-rules.md` / `spec-update-rules.md` / `readme-update-rules.md` 三 rule,Claude 自行判斷 | `maintaining-claude-md` / `maintaining-spec-md` / `maintaining-readme-md` 三 skill 自動觸發 |
| TDD 編排 | `development-workflow-details.md` prose 描述 4 階段 | `tdd-feature-workflow` skill 編排 + 委派 superpowers skills |
| Slash commands | 無 | `/project-status` / `/pre-dev-check` / `/pre-pr-check` / `/agent-cheatsheet` |
| Hooks | 無 | `secrets-scan-advisory.sh`(advisory)+ `external-ref-guard.sh`(guard) |
| CI | 無 | `.github/workflows/ci.yml`(ruff / mypy / pytest / coverage) |
| 工具配置 | 無 | `pyproject-tooling.example.toml`(ruff / mypy / pytest / coverage `[tool.*]`) |
| 外部依賴 | `superpowers` / `code-simplifier` plugins + `context7` / `github` MCPs + `gh` CLI + Python 3.11+ / `uv` / `git` | 同 V0 基礎,另加 `code-review` plugin |

完整 V0 → V1 設計演進原因見 [`claude-code-setup-v1/README.md`](../claude-code-setup-v1/README.md) 的 `## Design Rationale` 章節。

---

## 何時用 V0

- 偏好 rule-driven 的被動讀取模式,不需要 skill 主動觸發
- 想以 V0 為起點客製自己的 rule-driven 設計
- 不需要 slash command / hook / CI 自動化層

V1 提供更完整的 skill-driven 自動觸發、workflow 編排、安全防護(hooks)與 CI——如需這些能力,建議直接採用 V1。

---

## 遷移到 V1

V0 與 V1 共享相同外部工具,核心差異在自動化層(skills / commands / hooks / CI)。既有 V0 專案若要遷移,參考 V1 README 的 Quick Start,並依本檔的 V0 vs V1 對照表逐項引入。

---

**Template Version**: v0.2.0
**Last Updated**: 2026-05-05
