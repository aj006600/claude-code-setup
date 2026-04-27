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
- `maintaining-claude-md` — CLAUDE.md 更新 + 專案內 CLAUDE-CHANGELOG.md 同步
- `maintaining-readme-md` — README.md + docs/ 更新（含 3 種文檔 templates）
- `tdd-feature-workflow` — 4 階段 TDD 開發編排

### 4 Slash Commands
- `/project-status` — 快速狀態快照
- `/pre-dev-check` — 開發前檢查
- `/pre-pr-check` — PR 前完整檢查（tests、coverage、code-simplifier、SPEC、README hints）
- `/agent-cheatsheet` — 可用資源速查

### 1 Advisory Hook + 1 Guard Hook
- `secrets-scan-advisory.sh` — PreToolUse hook：`git commit` / `git add` 前掃 staged 檔名（`.env`、`*.pem`、`*.key`、`credentials.json` 等）與 staged diff 中的已知 secret pattern（AWS key、GitHub token、OpenAI key、Slack token、私鑰 header）（advisory）
- `external-ref-guard.sh` — PreToolUse hook：`git commit` / `gh pr create|edit|comment` / `gh issue create|edit|comment` 前掃 command text，偵測到指向外部 repo 的裸 reference（`owner/repo#N`、`https://github.com/owner/repo/(issues|pull)/N`）即**直接阻擋**，防止 GitHub cross-repo "mentioned in ..." backlink 外洩內容。反引號包起來的引用視為安全、放行

`secrets-scan-advisory.sh` 為 `exit 0` 不阻擋；`external-ref-guard.sh` 為 `exit 1` 阻擋（leak 不可逆、逃生門只需反引號包即可）。

### 1 CI Workflow
- `.github/workflows/ci.yml` — GitHub Actions，PR 與 push 觸發 `ruff check` + `ruff format --check` + `mypy` + `pytest --cov`（與 `/pre-pr-check` 檢查項一致）

### 4 Reference Rules
- `code-style.md` — Python 代碼風格（Required Standards + Recommended Tools 分層）
- `testing-rules.md` — pytest 測試慣例 + 完整範例（parametrize、async fixtures、mocking、coverage config）
- `git-rules.md` — Git workflow + commit convention
- `documentation-style.md` — 文檔撰寫風格

### 3 Local Agents
- `code-reviewer` — 本地版 code review agent
- `documentation-engineer` — 文件撰寫 / 維護
- `test-automator` — 大規模 test framework / CI 整合

---

## Prerequisites

本 template 依賴以下外部資源，需預先在 Claude Code 環境安裝。

### Plugins / Skills
| Plugin | 用途 | 引用位置 |
|--------|------|---------|
| `superpowers` | brainstorming / writing-plans / executing-plans / test-driven-development / verification-before-completion / finishing-a-development-branch 等 skills | `tdd-feature-workflow` skill |
| `code-simplifier` | 代碼審查（`code-simplifier:code-simplifier` agent） | `tdd-feature-workflow` skill 階段 3.3、`/pre-pr-check` Level 2.2 |
| `code-review` | PR review workflow(`/code-review` command 寫回 PR comment) | `tdd-feature-workflow` skill 階段 4.1 |

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

## Quick Start（4 步驟）

### Step 1：初始化 Python 專案

```bash
mkdir my-project && cd my-project
uv init
```

`uv init` 會產生 `pyproject.toml`（含 `[project]` / `[build-system]`）、`README.md`、`main.py`、`.python-version`。

### Step 2：複製 template setup

將 `.claude/`、`.github/` 複製到你的專案根目錄：

```bash
cp -r path/to/claude-code-setup-v1/.claude .
cp -r path/to/claude-code-setup-v1/.github .
```

### Step 3：Merge 推薦工具配置

將 `.claude/references/pyproject-tooling.example.toml` 的 `[tool.*]` 區塊（ruff / mypy / pytest / coverage）merge 進 `uv init` 產生的 `pyproject.toml`：

```bash
# 簡單方式：append 到檔尾（若 pyproject.toml 尚無 [tool.*] 區塊）
cat .claude/references/pyproject-tooling.example.toml >> pyproject.toml
```

或手動開檔複製對應 section（避免區塊重複）。完成後安裝 dev 依賴：

```bash
uv add --dev ruff mypy pytest pytest-asyncio pytest-cov
uv sync
```

### Step 4：啟動 Claude Code 並提出第一個需求

直接說明你要建立什麼：

```
我想建立一個 <專案名稱>，核心功能是 <描述>...
```

Claude Code 會自動完成：

1. **建立 SPEC.md**：`maintaining-spec-md` skill 偵測到無 SPEC.md → Workflow A 起草
2. **客製 CLAUDE.md**：`maintaining-claude-md` skill 偵測到 `<Placeholder>` 與 `<!-- TEMPLATE NOTICE -->` → Workflow A 填入 Project Name / framework / Architecture 等 placeholder、批次替換 `<YourName>` / `your-email@example.com`、移除 NOTICE 區塊
3. 展示 diff → 你確認 → 一次 commit

若需求尚不明確，skill 會主動詢問；若對話尚未提供足夠資訊（例如 framework 尚未選定），對應 placeholder 暫不替換，由後續對話中的 Workflow B 補上。

### 完成：開始開發

輸入「我想實作 X 功能」即觸發 `tdd-feature-workflow` skill 啟動 TDD 流程。

---

## Template 結構

```
claude-code-setup-v1/
├── README.md                     # Template 使用說明（本檔）
├── CHANGELOG.md                  # Template 自身演進史（不複製到 user 專案）
├── .claude/                      # User 複製此目錄到專案
│   ├── CLAUDE.md                 # 開發規範（需客製；Workflow A 自動處理）
│   ├── CLAUDE-CHANGELOG.md       # 空種子——user 專案自己的 CLAUDE.md 變更歷史
│   ├── settings.json             # Claude Code 設定（含 hook 註冊）
│   ├── rules/                    # 開發規範
│   │   ├── code-style.md
│   │   ├── testing-rules.md
│   │   ├── git-rules.md
│   │   └── documentation-style.md
│   ├── references/               # 跨領域 reference
│   │   └── pyproject-tooling.example.toml   # ruff/mypy/pytest/coverage [tool.*] 配置
│   ├── skills/                   # 專案專屬 skills
│   │   ├── maintaining-spec-md/
│   │   ├── maintaining-claude-md/
│   │   ├── maintaining-readme-md/
│   │   │   └── references/       # 3 份 doc templates
│   │   └── tdd-feature-workflow/
│   ├── commands/                 # Slash commands
│   ├── agents/                   # Sub-agents
│   └── hooks/
│       ├── secrets-scan-advisory.sh
│       └── external-ref-guard.sh
└── .github/                      # User 同時複製此目錄
    └── workflows/
        └── ci.yml                # GitHub Actions CI
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

### Q: Hooks 會擋住我的 commit 嗎？
A: 分兩類：

| 類別 | Hook | 行為 |
|------|------|------|
| Advisory | `secrets-scan-advisory.sh` | `exit 0`，只在 stderr 輸出警告，不阻擋 |
| Guard | `external-ref-guard.sh` | `exit 1`，偵測到外部 repo 裸 reference 直接阻擋 |

Guard hook 設計為阻擋是因為 GitHub cross-repo backlink 一旦建立即不可逆（watcher 已收到通知），且逃生門極簡——只需把引用用反引號 `` ` `` 包起來即可通過（GitHub 對 code span 不做 reference parsing）。

若想把 advisory 升級為阻擋，編輯對應檔案將警告分支的 `exit 0` 改為 `exit 1`；若想把 guard 降為 advisory 或臨時 bypass，見下題。

### Q: 如何關閉或 bypass hook？
A: 編輯 `.claude/settings.json`：

- **全部關閉**：清空 `hooks` 區塊 `{ "hooks": {} }`
- **只關閉某一個**：從 `PreToolUse[].hooks[]` 陣列移除對應 entry
- **臨時 bypass `external-ref-guard`**：移除該 entry、完成操作、再加回來（或用反引號包引用，無須改 settings）

### Q: Skill 沒有自動觸發？
A: Skill 的 description 欄位決定何時觸發。若語境不在 description 涵蓋範圍內，可手動啟用：使用 Claude Code 的 Skill tool，傳入 `skill: "maintaining-spec-md"` 等。

### Q: CLAUDE.md 版本號如何演進？
A: 採 Semantic Versioning。`maintaining-claude-md` skill 會自動處理版本遞增與 CHANGELOG 條目。

### Q: 為什麼有兩個 CHANGELOG？職責怎麼區分？
A: 兩者追蹤不同範圍：

| 檔案 | 追蹤範圍 | 讀者 | 跟隨 `.claude/` 複製嗎？ |
|---|---|---|---|
| `claude-code-setup-v1/CHANGELOG.md` | **Template 自身**的演進（skill / command / hook / rule / README 等） | Template 評估者、升級者 | 否（只存在於 template repo） |
| `.claude/CLAUDE-CHANGELOG.md` | **User 專案**自己的 CLAUDE.md 規範演進 | User 專案的 team | 是（空種子，由 Workflow A 寫入首個 v1.0.0） |

Template ship 出來的 `.claude/CLAUDE-CHANGELOG.md` 是空種子（只有 header 與 `[Unreleased]`）。首次執行 `maintaining-claude-md` Workflow A 時會自動寫入 baseline `v1.0.0` entry，標註 "adopted from claude-code-setup-v1 template vX.Y.Z"。之後所有 CLAUDE.md 變更都累積到這個檔案，和 template 自身的 `CHANGELOG.md` 互不干擾。

---

## Advanced Customization

### 調整 Rules（視團隊需求）

檢視 `.claude/rules/` 並依團隊調整：

| Rule | 可客製項目 |
|------|-----------|
| `code-style.md` | Formatter / Linter / Type Checker 選擇、docstring 格式 |
| `testing-rules.md` | Markers、Coverage 目標、factory 選擇 |
| `git-rules.md` | Commit convention 其他細節 |
| `documentation-style.md` | 模板結構細節 |

工具配置（`[tool.*]`）若需調整，編輯 `.claude/references/pyproject-tooling.example.toml`，再 merge 進 user 專案的 `pyproject.toml`。

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

## Design Rationale

本 template 在 v1.2.0 將原「rule 檔案 + Claude 被動讀取」的設計，全面改為「skill 主動觸發」。選擇 skill 而非 markdown rule 的 5 個理由：

**1. 主動觸發 vs 被動等讀取**
Skill description 是 Claude Code 的觸發關鍵——語意匹配時自動載入，不必仰賴 CLAUDE.md 提示或使用者明確要求。

**2. Workflow 結構比純文字規範更可遵循**
Skill 可內建多步驟 workflow、分支判斷（如 `maintaining-claude-md` 的 Workflow A/B）、輸入輸出樣板。Markdown rule 只能文字敘述，Claude 在臨場判斷上較易漏步驟。

**3. 跨 skill 協作鏈**
`maintaining-spec-md` → `maintaining-claude-md` → `maintaining-readme-md` 在關鍵節點互相 hook，形成規範同步鏈；rule 之間沒有這種機制。

**4. 領域知識隨 skill 一併載入**
Semantic Versioning、Keep a Changelog、TDD 紀律等最佳實踐寫進 skill body，觸發時自動進入 context。Rule 形式需 Claude 主動 Read 才知道細節。

**5. 智慧延後執行時機**（`maintaining-readme-md` 獨有）
依實作狀態（實作中 / 完成未 PR / PR 中 / 已 merge）決定執行時機，避免 TDD 中途干擾也避免文檔遺忘補上。原 rule 只有單一「pre-merge」觸發點。

若想對比原始 rule-driven 設計，可參考 repo 內保留的 v0 snapshot。

---

## 相關資源

- [Claude Code 官方文件](https://docs.claude.com/en/docs/claude-code)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [superpowers skills](https://github.com/obra/superpowers)

---

**Template Version**: v1.16.0
**Last Updated**: 2026-04-27
