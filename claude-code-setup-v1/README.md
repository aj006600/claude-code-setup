# claude-code-setup-v1

Claude Code 專案配置模板 — 第一版：**通用 Python 專案**、編碼業界最佳實踐的 lean setup。

---

## Overview

這是給 Claude Code 使用的專案 setup template。它提供一組經過設計的 skills、commands、rules、agents 與 hooks，讓 Claude Code 在開發 Python 專案時：

- **自動維護規範一致性**：SPEC.md、CLAUDE.md、README / docs 透過 skill 自動同步
- **強制 TDD 紀律**：4 階段 workflow 編排，委派 superpowers skills
- **提供最佳實踐預設**：code style、testing、git、documentation 規範內建
- **降低認知負擔**：commands 減少重複操作，advisory hook 提供安全網

## Design Philosophy

- **Procedural → Skill**：有步驟的流程（如更新 CLAUDE.md）做成 skill，由 description 觸發
- **Reference → Rule**：查閱類規範（如 coding style）留在 rule 檔案
- **Single source of truth**：規範不重複；skill / rule / agent 各司其職
- **Progressive disclosure**：Skill bundled references 只在需要時載入
- **Template-friendly**：CLAUDE.md 有明確 `<Placeholder>` 標記，Architecture 可客製

---

## What's Included

### 4 Maintenance Skills
- `maintaining-spec-md` — SPEC.md 建立 / 維護
- `maintaining-claude-md` — CLAUDE.md 更新 + CLAUDE-CHANGELOG.md 同步
- `maintaining-readme-md` — README.md + docs/ 更新（含 3 種文檔 templates）
- `tdd-feature-workflow` — 4 階段 TDD 開發編排

### 4 Slash Commands
- `/project-status` — 快速狀態快照
- `/pre-dev-check` — 開發前檢查
- `/pre-pr-check` — PR 前完整檢查（tests、coverage、code-simplifier、SPEC、README hints）
- `/agent-cheatsheet` — 可用資源速查

### 1 Advisory Hook
- `commit-message-advisory.sh` — Claude Code PreToolUse hook，檢查 commit message 的 Authored-By trailer（advisory only，不阻擋）

### 4 Reference Rules
- `code-style.md` — Python 代碼風格（Required Standards + Recommended Tools 分層）
- `testing-rules.md` — pytest 測試慣例 + 完整範例（parametrize、async fixtures、mocking、coverage config）
- `git-rules.md` — Git workflow + commit convention
- `documentation-style.md` — 文檔撰寫風格

### 4 Pointer Rules（已遷移至 skills）
- `spec-update-rules.md` → `maintaining-spec-md`
- `claude-update-rules.md` → `maintaining-claude-md`
- `readme-update-rules.md` → `maintaining-readme-md`
- `development-workflow-details.md` → `tdd-feature-workflow`

### 8 Local Agents
AI / LLM 導向的 sub-agents：
- `ai-engineer`, `architect-reviewer`, `code-reviewer`, `documentation-engineer`
- `llm-architect`, `prompt-engineer`, `qa-expert`, `test-automator`

---

## Prerequisites

本 template 依賴以下外部資源，需預先在 Claude Code 環境安裝。

### Plugins / Skills
| Plugin | 用途 | 引用位置 |
|--------|------|---------|
| `superpowers` | brainstorming / writing-plans / executing-plans / test-driven-development / verification-before-completion / finishing-a-development-branch 等 skills | `tdd-feature-workflow` skill |
| `code-simplifier` | 代碼審查（`code-simplifier:code-simplifier` agent） | CLAUDE.md、git-rules.md、`/pre-pr-check` |
| `code-review` | PR review workflow | CLAUDE.md |

### MCP Servers
| MCP | 用途 |
|-----|------|
| `context7` | 最新 library 文檔查詢 |
| `github` | GitHub 操作（PR、issues 等） |

### CLI 工具
| 工具 | 用途 |
|------|------|
| `gh` | GitHub CLI（建立 / 合併 PR） |
| `uv` | Python 套件管理與執行 |
| `python` 3.11+ | Hook script 與 pytest 執行 |

---

## Quick Start（5 步驟）

### Step 1：複製 setup

將整個 `.claude/` 目錄複製到你的新專案根目錄：

```bash
cp -r path/to/claude-code-setup-v1/.claude /path/to/your-project/
```

### Step 2：客製 CLAUDE.md

開啟 `.claude/CLAUDE.md` 進行：

1. **刪除頂端的 `<!-- TEMPLATE NOTICE ... -->` 區塊**（採用後不再需要）
2. 替換所有 `<!-- TEMPLATE: ... -->` 標示的區塊與 `<Placeholder>` 佔位符：
   - **Project Overview**：你的專案名稱與一句話描述
   - **Tech Stack**：framework 選擇、其他依賴
   - **Architecture**：你的實際目錄結構

### Step 3：讓 Claude Code 建立 SPEC.md

Template 刻意**不**包含 SPEC.md（它是專案特定需求規格）。在新專案啟動 Claude Code，直接提出需求：

```
我想建立一個 <專案名稱>，核心功能是 <描述>...
```

`maintaining-spec-md` skill 會偵測到「沒有 SPEC.md」的情境並透過 Workflow A 建立初始版本。

### Step 4：調整 Rules（視團隊需求）

檢視 `.claude/rules/` 並根據團隊調整：

| Rule | 可客製項目 |
|------|-----------|
| `code-style.md` | Formatter / Linter / Type Checker 選擇、docstring 格式 |
| `testing-rules.md` | Markers、Coverage 目標、factory 選擇 |
| `git-rules.md` | Commit convention、`Authored-By` trailer |
| `documentation-style.md` | 模板結構細節 |

### Step 5：更新 Git 身份資訊（重要）

Template 的 commit message trailer 預設為 placeholder：

```
Authored-By: <YourName> <your-email@example.com>
```

**請將 `<YourName>` 與 `<your-email@example.com>` 替換為你的實際資訊**。先掃描所有出現位置：

```bash
grep -rln "your-email@example.com" .claude/
grep -rln "<YourName>" .claude/
```

手動替換，或用 `sed` 批次處理（將 `Your Name` 與 `you@your-domain.com` 改為實際值）：

```bash
# macOS
find .claude -type f -name "*.md" -exec sed -i '' \
  -e 's/<YourName>/Your Name/g' \
  -e 's/your-email@example.com/you@your-domain.com/g' {} +

# Linux
find .claude -type f -name "*.md" -exec sed -i \
  -e 's/<YourName>/Your Name/g' \
  -e 's/your-email@example.com/you@your-domain.com/g' {} +
```

### 完成：開始開發

輸入「我想實作 X 功能」即觸發 `tdd-feature-workflow` skill 啟動 TDD 流程。

---

## Template 結構

```
.claude/
├── CLAUDE.md                 # 開發規範（需客製）
├── CLAUDE-CHANGELOG.md       # CLAUDE.md 變更歷史
├── settings.json             # Claude Code 設定（含 hook 註冊）
├── rules/                    # 開發規範
│   ├── code-style.md
│   ├── testing-rules.md
│   ├── git-rules.md
│   ├── documentation-style.md
│   └── *-rules.md            # 4 個 skill 指標
├── skills/                   # 專案專屬 skills
│   ├── maintaining-spec-md/
│   ├── maintaining-claude-md/
│   ├── maintaining-readme-md/
│   │   └── references/       # 3 份 doc templates
│   └── tdd-feature-workflow/
├── commands/                 # Slash commands
├── agents/                   # Sub-agents
└── hooks/
    └── commit-message-advisory.sh
```

---

## FAQ

### Q: Template 不是 Python 專案可以用嗎？
A: 大部分結構通用，但 rules（code-style、testing-rules）預設 Python。若改為其他語言：
- 重寫 `code-style.md` 為該語言規範
- 重寫 `testing-rules.md` 為該語言測試框架範例
- 其他檔案幾乎不需改

### Q: 我已經有 CLAUDE.md 了，如何整合？
A: 保留你的內容，將本 template 的結構（Available Agents & Skills 章節、Development Checklist、CHANGELOG 配對模式）作為 reference 融合進去。

### Q: 不想用 superpowers skills 怎麼辦？
A: `tdd-feature-workflow` skill 大量引用 superpowers。若不用：
1. 編輯 `.claude/skills/tdd-feature-workflow/SKILL.md` 各階段委派對象
2. 將「啟用 `superpowers:xxx` skill」改為具體指令

### Q: Advisory hook 會擋住我的 commit 嗎？
A: **不會**。Hook 設計為 advisory-only（`exit 0`），只在 stderr 輸出警告。若想升級為阻擋，編輯 `.claude/hooks/commit-message-advisory.sh` 將警告分支的 `exit 0` 改為 `exit 1`。

### Q: 如何關閉 hook？
A: 編輯 `.claude/settings.json`，移除或清空 `hooks` 區塊：

```json
{
  "hooks": {}
}
```

### Q: Skill 沒有自動觸發？
A: Skill 的 description 欄位決定何時觸發。若語境不在 description 涵蓋範圍內，可手動啟用：使用 Claude Code 的 Skill tool，傳入 `skill: "maintaining-spec-md"` 等。

### Q: CLAUDE.md 版本號如何演進？
A: 採 Semantic Versioning。`maintaining-claude-md` skill 會自動處理版本遞增與 CHANGELOG 條目。

---

## Advanced Customization

### 新增 skill
參考 `.claude/skills/` 現有 skill 作為結構範例。或在 Claude Code 啟用 `skill-creator:skill-creator` skill 引導建立。

### 新增 command
於 `.claude/commands/` 建立 `.md` 檔，含 YAML frontmatter `description` 欄位。

### 新增 hook
於 `.claude/hooks/` 建立 shell script，並在 `.claude/settings.json` 的 `hooks` 區塊註冊。

Hook 類型（依 lifecycle 順序）：
- `SessionStart` — Claude Code session 開始時
- `UserPromptSubmit` — User 提交 prompt 時
- `PreToolUse` — tool 執行前觸發（可阻擋）
- `PostToolUse` — tool 執行後觸發
- `Notification` — 通知事件（如 Claude Code idle 等）
- `PreCompact` — context 壓縮前
- `SubagentStop` — subagent 完成時
- `Stop` — Claude 回覆完成後
- `SessionEnd` — session 結束時

### 修改 agent
`.claude/agents/*.md` 為 local agents。修改 description 可改變觸發語境，修改 body 可改變行為。

---

## 相關資源

- [Claude Code 官方文件](https://docs.claude.com/en/docs/claude-code)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [superpowers skills](https://github.com/obra/superpowers)

---

**Template Version**: v1.0.0
**Last Updated**: 2026-04-23
