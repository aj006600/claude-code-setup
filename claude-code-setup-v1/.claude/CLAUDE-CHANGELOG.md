# Changelog

All notable changes to `.claude/CLAUDE.md` (專案開發規範) will be documented in this file.

The format is based on [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

變更分類說明：
- **Added**：新增章節或規範項目
- **Changed**：修改既有規範的內容或細節
- **Deprecated**：即將移除但暫時保留的規範
- **Removed**：移除的章節或規範
- **Fixed**：修正錯字、邏輯錯誤、矛盾描述
- **Security**：安全相關規範的變更

---

## [Unreleased]

<!-- 尚未發布的變更累積於此。發版時改為 `## [vX.Y.Z] - YYYY-MM-DD` 並新增一個新的 Unreleased 區塊。 -->

---

## [v1.0.2] - 2026-04-23

### Changed
- Development Workflow 核心原則明確寫入「嚴格遵守 TDD」：不採用 `/feature-dev` command 作為實作入口（因其未強制 TDD）。委派清單從錯誤的 `superpowers:feature-dev` 改為實際使用的 `brainstorming` / `writing-plans` / `executing-plans` / `test-driven-development` / `finishing-a-development-branch`
- Available Agents & Skills > 功能開發段新增 `brainstorming` / `writing-plans` / `verification-before-completion` 三項常用 skill

### Removed
- 移除 Development Workflow 清單中錯誤的 `superpowers:feature-dev` 引用（feature-dev 是獨立 plugin 而非 superpowers 子項目）

---

## [v1.0.1] - 2026-04-23

### Changed
- Development Checklist 的測試指令改為 tech-agnostic（加「依 Tech Stack 調整」並保留 Python 範例），讓 template 採用者改用其他語言時不被鎖死在 uv/pytest

---

## [v1.0.0] - 2026-04-23

### Added
- Initial template setup — 採用自 claude-code-setup-v1 template
