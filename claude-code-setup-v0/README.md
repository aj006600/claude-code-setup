# claude-code-setup-v0

Claude Code 專案配置模板 — 第零版:**rule-driven 簡潔設計**、純文字規範驅動的早期 setup。

> **狀態**:V0 已凍結為歷史快照。Active development 在 [`claude-code-setup-v1/`](../claude-code-setup-v1/),新專案請直接採用 V1。本目錄保留供設計演進對照與極簡需求情境使用。

---

## Overview

V0 是 setup template 的最初設計,採 **rule-driven 模式**——Claude Code 透過 `.claude/CLAUDE.md` 引用 `.claude/rules/*.md` 被動讀取規範。整個 setup 由純 markdown 構成,沒有 skill / command / hook / CI 自動化層。

設計訴求:

- **極簡**:只有 markdown 規範檔,無腳本、無自動觸發
- **純文字規範**:開發流程、TDD 紀律、文檔規範皆以 prose 表達
- **低依賴**:無需 superpowers / code-simplifier plugin、無需 MCP server,只需基本 Python 環境

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

無其他外部依賴(skill / plugin / MCP / CI 皆無)。

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
├── CHANGELOG.md               # V0 自身演進史(凍結於 v0.1.0)
├── ROADMAP.md                 # V0 → V1 演進回顧
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

| 面向 | V0(本版,frozen) | V1(active) |
|------|------------------|--------------|
| 設計典範 | Rule-driven(Claude 被動讀規範) | Skill-driven(規範由 skill description 主動觸發載入) |
| 文檔維護 | `claude-update-rules.md` / `spec-update-rules.md` / `readme-update-rules.md` 三 rule,Claude 自行判斷 | `maintaining-claude-md` / `maintaining-spec-md` / `maintaining-readme-md` 三 skill 自動觸發 |
| TDD 編排 | `development-workflow-details.md` prose 描述 4 階段 | `tdd-feature-workflow` skill 編排 + 委派 superpowers skills |
| Slash commands | 無 | `/project-status` / `/pre-dev-check` / `/pre-pr-check` / `/agent-cheatsheet` |
| Hooks | 無 | `secrets-scan-advisory.sh`(advisory)+ `external-ref-guard.sh`(guard) |
| CI | 無 | `.github/workflows/ci.yml`(ruff / mypy / pytest / coverage) |
| 工具配置 | 無 | `pyproject-tooling.example.toml`(ruff / mypy / pytest / coverage `[tool.*]`) |
| Per-rule versioning | 每個 rule 獨立 footer 與版本號 | 取消;統一由 template CHANGELOG 追蹤 |
| 外部依賴 | `uv` + `git` + Python 3.11+ | 加上 `superpowers` / `code-simplifier` / `code-review` plugins、`context7` / `github` MCPs、`gh` CLI |

完整 V0 → V1 設計演進原因見 [`claude-code-setup-v1/README.md`](../claude-code-setup-v1/README.md) 的 `## Design Rationale` 章節。

---

## 何時用 V0

- 評估 setup template 的演進歷史,作為 V1 設計決策對照
- 想以 V0 為起點客製自己的 rule-driven 設計
- 極端輕量需求:不希望引入 skill / plugin / hook / CI 任何自動化層

對絕大多數實際專案而言,**直接用 V1**——自動觸發、workflow 編排、安全防護皆已內建,使用體驗顯著優於 V0。

---

## 升級到 V1

V0 → V1 為大幅重構,無向下兼容的 migration script。建議直接以 V1 作為新專案模板;既有 V0 專案若要升級,參考 V1 README 的 Quick Start,並用本檔的 V0 vs V1 對照表逐項引入 skills / commands / hooks。

---

**Template Version**: v0.1.0
**Last Updated**: 2026-05-04
