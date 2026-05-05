# Changelog

All notable changes to the **claude-code-setup-v0 template itself** will be documented in this file.

V0 是 setup 的 **rule-driven** 設計版本,不含 skill / command / hook / CI 自動化層。

The format is based on [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

變更分類說明:
- **Added**:新增功能(rule、章節等)
- **Changed**:修改既有功能的內容或細節
- **Removed**:移除的功能
- **Fixed**:修正錯字、邏輯錯誤、矛盾描述

---

## [Unreleased]

---

## [v0.2.0] - 2026-05-05

修正 V0 內部邏輯衝突,使所有 rule 之間一致且可用。

### Changed
- `.claude/CLAUDE.md` — Development Checklist 分支建立步驟加上 `git checkout dev && git pull origin dev`,對齊 `development-workflow-details.md`
- `.claude/CLAUDE.md` — `code-reviewer agent` 改為 `superpowers:code-reviewer`
- `.claude/rules/development-workflow-details.md` — `code-reviewer agent` 改為 `superpowers:code-reviewer`;移除 `documentation-engineer agent` 引用
- `.claude/rules/claude-update-rules.md` — 分支 workflow 加上 base branch(`dev`)與 PR target;移除引用不存在的 `CLAUDE-CHANGELOG.md` 的 TODO 註解
- `.claude/rules/readme-update-rules.md` — 移除 `documentation-engineer agent` 引用
- `.claude/rules/documentation-style.md` — 移除專案特定硬編碼「SMT AI Agent」,改為通用描述
- `.claude/rules/spec-update-rules.md` — emoji 改為純文字粗體;移除負面描述「不好的做法」區塊

### Fixed
- `.claude/rules/development-workflow-details.md` — 檔名引用 `spec-rules.md` 修正為 `spec-update-rules.md`
- `.claude/rules/spec-update-rules.md` — 自身檔名引用 `spec-rules.md` 修正為 `spec-update-rules.md`

### Removed
- 所有 rule 檔案與 CLAUDE.md 的 `**Version**` footer(per-rule versioning 為反模式,統一由本 CHANGELOG 追蹤)

---

## [v0.1.0] - 2026-05-04

Rule-driven design baseline。Claude Code 透過 `.claude/CLAUDE.md` 引用 `.claude/rules/*.md` 被動讀取規範,所有開發流程以 prose 表達,無 skill / command / hook 自動化機制。改進方向見 `ROADMAP.md`。

### Added
- `.claude/CLAUDE.md` — 主規範入口,涵蓋 Project Overview、Tech Stack(Python 3.11+ / uv)、Architecture、Development Workflow(4 階段 TDD)、Coding Conventions(命名 / Modular / SOLID)、Testing Protocols、Development Checklist;以動態引用 `.claude/rules/*.md` 各篇規範作為單一規範入口
- `.claude/SPEC.md` — 專案規格 template,含 Project Overview / Out of Scope / Functional Requirements(Priority / Status / Description / User Needs / Acceptance Criteria)/ Change Log;附 footer(Last Updated / Version)
- `.claude/rules/spec-update-rules.md` — SPEC.md 撰寫與動態更新指引;5 類觸發點(新需求 / 技術限制 / API 變更 / 狀態更新 / Bug 揭示需求錯誤)+ Step 1~5 完整更新流程模板 + 範例 + 自我檢查清單
- `.claude/rules/claude-update-rules.md` — CLAUDE.md 何時與如何更新;3 類觸發場景(新規範 / 結構變更 / 工作流程調整 / 專案需求)+ 4 步驟更新流程
- `.claude/rules/readme-update-rules.md` — README / docs 何時與如何更新;PR Review 通過後 merge 前觸發
- `.claude/rules/development-workflow-details.md` — TDD 4 階段詳細流程(需求確認 → 開發 → 提交與 PR → Review 與 Merge),逐步操作指令
- `.claude/rules/git-rules.md` — Branch Strategy(`main` / `qas` / `dev` + `feat` / `fix` / `hotfix` / `docs` / `refactor`)、分支命名規範、Conventional Commits 風格 commit type 表、最佳實踐
- `.claude/rules/code-style.md` — Docstring 規範(Google Style + 繁體中文內容 + 英文技術術語);包含 Args / Returns / Raises / Example
- `.claude/rules/testing-rules.md` — pytest 測試慣例;測試命名 + 單元測試 + 整合測試 + fixture 範例
- `.claude/rules/documentation-style.md` — 文檔撰寫規範(章節分隔符、Footer 格式、標題層級、程式碼區塊語言標記、Mermaid 圖表)+ 三類文檔模板(Service / Reference / Guide)+ 章節命名標準

### Design Notes
- **Per-rule versioning**:每個 rule 檔案各自附 `**Last Updated**` + `**Version**` footer;後續評估認定為反模式(各 rule 版本互不相干、user 不會每次編輯都同步),改為由 template `CHANGELOG.md` 統一追蹤
- **被動讀取模式**:Claude Code 仰賴 CLAUDE.md 的「需查看並遵循 `xxx-rules.md`」提示去 Read 規範,觸發精度受限於 CLAUDE.md context 與當下對話語意;改進方向見 `ROADMAP.md`
- **無自動化層**:不含 slash command / hook / CI workflow;規範執行完全靠 Claude 自律;改進方向見 `ROADMAP.md`
