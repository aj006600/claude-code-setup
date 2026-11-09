# claude-code-setup-v1

> **封存版本**(2026-11-09)。原名 `claude-code-setup-v1`,skill-driven 的 Python 專案 setup,保留供參考與整理,演進史見 `git log`;新專案請用 [`template/`](../../template/)。

Claude Code 專案配置模板 — 第一版:通用 Python 專案的 **skill-driven** setup。一組 skills、commands、rules 與 hooks 讓 Claude Code 在開發 Python 專案時自動維護規範一致性(SPEC / architecture / CLAUDE / README / decisions 各有專責 skill 同步)、以 4 階段 workflow 執行 TDD 紀律、內建 code style / testing / git / documentation 最佳實踐,並用 commands 與 hooks 減少重複操作、提供安全網。設計理念與理由見 [NOTE.md](./NOTE.md)。

## Prerequisites

本 template 依賴以下外部資源，需預先在 Claude Code 環境安裝。

### Plugins / Skills
| Plugin | 用途 | 引用位置 |
|--------|------|---------|
| `superpowers` | `tdd-feature-workflow` 各階段委派的多個 skills（brainstorming、writing-plans、executing-plans、test-driven-development、systematic-debugging、verification-before-completion、requesting-code-review / code-reviewer / receiving-code-review、finishing-a-development-branch）；完整委派表見 `tdd-feature-workflow/SKILL.md`「關鍵分工」 | `tdd-feature-workflow` skill |
| `code-simplifier` | 代碼審查（`code-simplifier:code-simplifier` agent） | `tdd-feature-workflow` skill 階段 3.3、`/pre-pr-check` Level 2.1 |
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

## What's inside

```
archive/v1/
├── README.md                     # 本檔
├── PROMPT.md                     # 使用 V1 時的常用 prompt 模板
├── NOTE.md                       # V1 設計理念與開發筆記
└── template/                     # 整個資料夾的內容複製到專案根目錄
    ├── .claude/
    │   ├── CLAUDE.md             # 開發原則 / constitution,<...> 佔位符由 maintaining-claude-md 首次對話填入
    │   ├── SPEC.md               # 需求規格 placeholder,由 maintaining-spec-md 首次對話填入
    │   ├── settings.json         # hooks 註冊
    │   ├── rules/
    │   │   ├── code-style.md             # Python 代碼風格(Required Standards + Recommended Tools 分層)
    │   │   ├── testing-rules.md          # pytest 慣例與範例(parametrize、async fixtures、mocking、coverage)
    │   │   ├── git-rules.md              # Git workflow + commit convention
    │   │   └── documentation-style.md    # 文檔撰寫風格
    │   ├── references/
    │   │   └── pyproject-tooling.example.toml   # ruff / mypy / pytest / coverage 的 [tool.*] 配置
    │   ├── skills/                       # 一份文件對一個 maintainer:SPEC = 該做什麼、architecture = 現在長怎樣、CLAUDE = 開發原則、decisions = 為何這樣決定、README/docs = 怎麼用
    │   │   ├── maintaining-spec-md/          # SPEC.md:需求 + 可量化 Success Criteria + [NEEDS CLARIFICATION] 標記
    │   │   ├── maintaining-architecture-md/  # architecture.md:現行架構 + Tech Stack + 目錄結構
    │   │   ├── maintaining-claude-md/        # CLAUDE.md:開發原則,演進靠 git log + decisions
    │   │   ├── maintaining-readme-md/        # README + docs/,含 3 份 doc templates(references/)
    │   │   ├── maintaining-decisions-md/     # decisions.md:ADR + Lessons + Timeline
    │   │   └── tdd-feature-workflow/         # 4 階段 TDD 編排(需求 → 實作 → PR → Review & Merge),關鍵節點委派 superpowers / code-review / maintaining-*
    │   ├── commands/
    │   │   ├── project-status.md     # /project-status:分支、未追蹤變更、SPEC / CLAUDE 版本、最近 commits
    │   │   ├── pre-dev-check.md      # /pre-dev-check:開發前 git 狀態與同步檢查
    │   │   ├── pre-pr-check.md       # /pre-pr-check:PR 前補 CI 做不到的檢查(code-simplifier、PR body external-ref scan、文件 hints)
    │   │   └── agent-cheatsheet.md   # /agent-cheatsheet:可用 agents / skills / commands / MCPs 速查
    │   ├── hooks/
    │   │   ├── secrets-scan-advisory.sh  # git add / commit 前掃 staged 檔名與 diff 中的 secret pattern,僅警告(exit 0)
    │   │   └── external-ref-guard.sh     # commit / PR / issue 文字含跨 repo 裸 reference 即阻擋(exit 1),反引號包起來放行
    │   └── docs/
    │       ├── architecture.md       # 現行架構描述,maintaining-architecture-md 維護
    │       ├── decisions/            # CONVENTIONS.md(規範)+ decisions.md(空種子)
    │       └── plans/                # TDD 工作 plan(superpowers:writing-plans 產出,非 user-facing)
    └── .github/
        └── workflows/
            └── ci.yml                # PR 與 push 跑 ruff check + ruff format --check + mypy + pytest --cov(fail-under 70),為 pre-merge 的權威 gate
```

---

## Setup

### Step 1：初始化 Python 專案

```bash
mkdir my-project && cd my-project
uv init
```

`uv init` 會產生 `pyproject.toml`（含 `[project]` / `[build-system]`）、`README.md`、`main.py`、`.python-version`。

### Step 2：複製 template setup

將 `.claude/`、`.github/` 複製到你的專案根目錄：

```bash
cp -r path/to/claude-code-setup/archive/v1/template/. .
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

### Step 4：設定 GitHub remote

先在 GitHub 建好空 repo（不要勾 README / .gitignore / license，避免與 template 衝突），然後設定 remote：

```bash
git remote add origin https://github.com/<user>/<repo>.git
```

`uv init` 已自動跑 `git init`，本 step 只負責設定 remote、不 push。實際 push 在 Step 5 完成首次客製化 commit 後執行。

> 用 Personal Access Token (PAT) 認證的 user 注意：本 template 含 `.github/workflows/ci.yml`，首次 push 可能因 PAT 缺 `workflow` scope 被 GitHub 擋。詳見 FAQ 最後一題。

### Step 5：啟動 Claude Code 並提出第一個需求

直接說明你要建立什麼：

```
我想建立一個 <專案名稱>，核心功能是 <描述>...
```

Claude Code 會自動完成：

1. **客製 SPEC.md**：`maintaining-spec-md` skill 偵測到 SPEC.md 的 `<!-- TEMPLATE NOTICE -->` → Workflow A 經需求對話填入 placeholder、移除 NOTICE
2. **客製 CLAUDE.md**：`maintaining-claude-md` skill 偵測到 `<!-- TEMPLATE NOTICE -->` 區塊 → Workflow A 依對話填入 Project Name 等 `<...>` placeholder、移除 NOTICE 區塊(架構 / Tech Stack 由 `maintaining-architecture-md` 處理 architecture.md)
3. 展示 diff → 你確認 → 一次 commit

若需求尚不明確，skill 會主動詢問；若對話尚未提供足夠資訊（例如 framework 尚未選定），對應 placeholder 暫不替換，由後續對話中的 Workflow B 補上。

### Step 6:依團隊調整 rules

`.claude/rules/` 可客製:`code-style.md` 的 formatter / linter / type checker 與 docstring 格式、`testing-rules.md` 的 markers 與 coverage 目標、`git-rules.md` 的 commit convention 細節、`documentation-style.md` 的模板結構;工具配置改 `.claude/references/pyproject-tooling.example.toml` 後 merge 進 `pyproject.toml`。

### 完成:開始開發

輸入「我想實作 X 功能」即觸發 `tdd-feature-workflow` skill 啟動 TDD 流程。

---

## FAQ

### Q: Template 不是 Python 專案可以用嗎？
A: 大部分結構通用，但 rules（code-style、testing-rules）預設 Python。若改為其他語言：
- 重寫 `code-style.md` 為該語言規範
- 重寫 `testing-rules.md` 為該語言測試框架範例
- 其他檔案幾乎不需改

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

### Q: Push 被拒：`refusing to allow a Personal Access Token to create or update workflow ...`

**症狀**：首次 `git push` 時 GitHub 回覆：

```
! [remote rejected] main -> main (refusing to allow a Personal Access Token to create or update workflow ".github/workflows/ci.yml" without "workflow" scope)
```

**原因**：用 Personal Access Token (PAT) 認證但 token 缺 `workflow` scope。GitHub 對「修改 `.github/workflows/` 內容」的 push 強制要求此 scope，即使是 repo owner 也擋。HTTPS remote 配 git credential helper 儲存 PAT 是最常踩的情境。

**三個解法**（任選）：

- **`gh auth login` 重登**（推薦）：web flow 會發完整 scope 的 token，之後 git CLI 透過 gh 的 credential helper 認證
- **改用 SSH key**：
  ```bash
  git remote set-url origin git@github.com:<user>/<repo>.git
  ```
  SSH 認證無 scope 概念，直接通
- **修補既有 PAT**：GitHub Settings → Developer settings → Personal access tokens → 編輯該 token → 加勾 `workflow` scope → 儲存

