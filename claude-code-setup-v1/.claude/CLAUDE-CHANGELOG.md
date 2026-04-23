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

## [v1.1.0] - 2026-04-23

### Added
- `maintaining-claude-md` skill 新增 **Workflow A（初次客製化）**：偵測 `<Placeholder>` / `<!-- TEMPLATE NOTICE -->` / `<YourName>` / `your-email@example.com` 殘留，於對話揭示相應決策時主動引導填入 placeholder、移除 NOTICE 區塊、批次替換 `.claude/` 下的 Git 身份資訊
- `maintaining-claude-md` description 新增 placeholder 觸發條件
- 「觸發情境清單」新增第 6 項「Template 未客製化」
- `.claude/hooks/secrets-scan-advisory.sh`：PreToolUse hook，`git commit` / `git add` 前掃 staged 檔名（`.env`、`*.pem`、`*.key`、`credentials.json` 等）與 staged diff 中的已知 secret pattern（AWS key、GitHub PAT、OpenAI API key、Slack token、私鑰 header 等）。Advisory only，不阻擋
- `.github/workflows/ci.yml`：GitHub Actions，PR 與 push 到 `main` / `qas` / `dev` 時觸發 ruff check + ruff format --check + mypy + pytest + coverage，與 `/pre-pr-check` 檢查項一致

### Changed
- `maintaining-claude-md` SKILL.md 原 Workflow 更名為 **Workflow B（更新既有 CLAUDE.md）**，與新增的 Workflow A 形成對稱結構（對齊 `maintaining-spec-md` 的 A/B 分流哲學）
- README Quick Start 從 5 步驟精簡為 3 步驟：原 Step 2（手動替換 placeholder）、Step 3（提需求建 SPEC）、Step 5（手動 sed 替換 Git 身份）合併為新 Step 2「啟動 Claude Code 並提出第一個需求」，由 `maintaining-claude-md` Workflow A + `maintaining-spec-md` Workflow A 自動處理
- README「What's Included」：hook 清單從 1 個更新為 2 個；新增「1 CI Workflow」區塊
- README「Template 結構」樹狀圖更新反映新檔案
- `.claude/settings.json`：新增 `secrets-scan-advisory.sh` 到 PreToolUse hooks 陣列

---

## [v1.0.3] - 2026-04-23

### Changed
- CLAUDE.md Development Workflow 核心原則改為純正面描述（「嚴格遵守 TDD：所有實作路徑必須經過 `writing-plans → executing-plans` 的測試先行流程」），不再提及不採用的替代方案
- `tdd-feature-workflow` skill description 與 body 移除所有 `/feature-dev` command 負面引用（description 尾段、核心原則、「為何需要這層編排」段落、分工表後置提醒）
- 所有 skill / command / rule 檔案移除裝飾性 emoji（`✅ ❌ ⚠️ 🔍 📊 📝 🎯 🔧 📚 🔌 💡 📋 ⏭ ℹ️`），保留目錄樹字符、流程箭頭、Markdown checkbox、section divider 等功能性符號
- `agent-cheatsheet` 各 section banner 與 output template 改為純文字

### Removed
- `agent-cheatsheet` 中錯誤的 `superpowers:feature-dev` 條目（`feature-dev` 是獨立 plugin，非 superpowers 子 skill）
- README Prerequisites 中 superpowers plugin 用途描述裡的 `feature-dev` 引用（同上錯誤）

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
