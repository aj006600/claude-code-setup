---
name: maintaining-claude-md
description: Use when the user proposes new coding conventions, project structure changes, workflow adjustments (git flow, CI/CD), testing strategy changes, docstring / naming updates, new technical dependencies, development checklist changes, or new project-specific constraints. Also use when SPEC.md's Project Overview / Tech Stack / Architecture changed, or when CLAUDE.md still has template placeholders (`<Placeholder>`, `<!-- TEMPLATE NOTICE -->`, `<YourName>`, `your-email@example.com`) and conversation has revealed the corresponding decisions. Trigger proactively even without explicit mention of "CLAUDE.md" — any conversation touching development rules, coding standards, project structure, or workflow conventions should invoke this skill, because keeping CLAUDE.md in sync with practice is load-bearing for every subsequent Claude Code session.
---

# Maintaining CLAUDE.md

這個 skill 讓 Claude Code 正確維護 `.claude/CLAUDE.md`(專案開發規範的真實來源)與搭配的 `.claude/CLAUDE-CHANGELOG.md`(變更歷史)。規範變動經「展示 diff → User 確認 → 同步 CHANGELOG」流程,避免漂移。

---

## 為何需要這層保護

CLAUDE.md 是**每次 Claude Code 對話都會載入**的開發規範。規範寫什麼,AI 就照什麼做;規範過期,AI 就做過期的事。

實務痛點:
- 換 linter 但沒改 CLAUDE.md → AI 仍產出舊規則
- 目錄結構重整但 Architecture 沒更新 → AI 建檔到錯位置
- 測試策略調整但 Testing Protocols 沒同步 → AI 寫的測試不符新標準

**CLAUDE.md 與 practice 脫節 = AI 行為與團隊共識脫節。**

---

## 觸發情境

| 類別 | 何時觸發 |
|------|---------|
| 開發規範 | 新 coding convention、新流程要求、新測試策略(覆蓋率、測試類型) |
| 專案結構 | 新增 / 移除目錄、模組重組、新技術堆疊 |
| 工作流程 | Git workflow、CI/CD、文檔更新流程變更 |
| 專案需求 | User 特殊習慣、效能 / 安全 / 合規限制 |
| SPEC.md 連動 | Project Overview / Functional 新模組 / Dependencies / Constraints / 架構重構 |
| Template 未客製化 | CLAUDE.md 仍有 `<Placeholder>` / `<!-- TEMPLATE NOTICE -->`;`.claude/` 下仍有 `<YourName>` / `your-email@example.com` |

對話揭示決策時觸發:**未客製化 → Workflow A**;**更新既有規範 → Workflow B**。

---

## Workflow A:初次客製化(template placeholder 替換)

適用於採用 template 後首次進入本 skill、對話已提供足夠資訊做替換。

### Step A1:偵測未客製化狀態

```bash
grep -l '<Placeholder>\|<!-- TEMPLATE NOTICE' .claude/CLAUDE.md 2>/dev/null
grep -rln '<YourName>\|your-email@example.com' .claude/ 2>/dev/null
```

任一條件成立 → Workflow A 適用。

### Step A2:從對話推導資訊

| Placeholder | 來源 |
|-------------|------|
| `<Project Name>` | User 提到的專案名 |
| `<One-sentence description...>` | User 第一個需求的摘要 |
| `<your framework, ...>` | User 選擇的 framework(若提及) |
| `<list project-specific dependencies...>` | 明確提到的 SDK / DB / 第三方依賴 |
| Architecture 樹的 `<project-name>` / `<your-modules>` | 從需求推導的模組切分 |
| `<YourName>` / `<your-email@example.com>` | 從 `git config user.name` / `user.email` 讀取 |

資訊不完整 → **一次問清**所有缺失項。尚不能決定(例如詳細模組切分)→ 保留範例結構,告知「待後續決策明確時由 Workflow B 補上」。

### Step A3:展示完整替換計畫

向 User 展示:偵測到的未客製化項目(placeholder 清單、有殘留的 `.claude/` 檔案數)、替換對照表、版本基線決策、待清理的 NOTICE 區塊。請 User 確認。

**版本基線預設**:CLAUDE.md 版本 reset 為 `v1.0.0`、`Last Updated` 改為今日——代表 user 專案自己的規範起點,不繼承 template 版本號。CLAUDE-CHANGELOG.md(空種子)寫入 baseline entry `[v1.0.0]`,標註 `adopted from claude-code-setup-v1 template v<X.Y.Z>`。User 明確要求保留 template 版本號則 skip reset,但仍寫 baseline entry。

User 若只想試跑 template、尚未決定方向 → 尊重並 skip 本 workflow。

### Step A4:批次替換與清理(順序重要)

1. 移除 CLAUDE.md 頂端的 `<!-- TEMPLATE NOTICE -->` 區塊(含前後空行)
2. 替換 CLAUDE.md 各 `<Placeholder>`(用 Step A2 收集的對照)
3. 批次替換 `.claude/` 下的 `<YourName>` / `your-email@example.com`:

```bash
# macOS
find .claude -type f \( -name "*.md" -o -name "*.sh" \) -exec sed -i '' \
  -e "s|<YourName>|<實際姓名>|g" \
  -e "s|your-email@example.com|<實際 email>|g" {} +

# Linux:去掉 sed 的 '' 參數
```

### Step A5:Reset 版本並寫 CHANGELOG baseline

1. Reset CLAUDE.md footer(預設):`Last Updated` → 今日;`Version` → `v1.0.0`
2. 在 `.claude/CLAUDE-CHANGELOG.md` 的 `[Unreleased]` 下方新增:

```markdown
## [v1.0.0] - <今日日期>

### Added
- Initial development guidelines adopted from claude-code-setup-v1 template (v<template version>) and customized for <Project Name>
- Project Overview / Tech Stack / Architecture 章節依需求填入
- Git 身份批次替換為本專案 Git 設定
```

Template version 從 `claude-code-setup-v1/CHANGELOG.md` 最新 entry 讀;無法取得 → fallback 用 CLAUDE.md 原本 footer 版本。

### Step A6:Commit

初次客製化通常在尚未有功能分支時,直接在當前分支 commit:

```bash
git add .claude/
git commit -m "chore(template): initial customization

Replaced template placeholders with project-specific values.
Removed TEMPLATE NOTICE block.
Reset CLAUDE.md to v1.0.0 as this project's own baseline and wrote
corresponding v1.0.0 entry to CLAUDE-CHANGELOG.md.

Authored-By: <實際姓名> <實際 email>"
```

告知 User:「Template 客製化完畢。後續任何規範 / 架構 / 技術堆疊變更由本 skill 的 Workflow B 處理。」

---

## Workflow B:更新既有 CLAUDE.md

### Step B1:分析影響範圍

自問:
- 這是新增、修改、還是刪除規範?
- 影響哪些章節?(Project Overview / Tech Stack / Architecture / Development Workflow / Coding Conventions / Testing Protocols / Development Checklist)
- 連動影響哪些 rules?(`git-rules.md` / `code-style.md` / `testing-rules.md`)
- 暫時實驗還是正式規範?

若不影響(例:純內部變數命名)→ 向 User 簡短說明後跳出 skill。

### Step B2:展示 diff 取得確認

    CLAUDE.md 更新建議

    **變更原因**:[為什麼要更新]

    **受影響的章節**:
    1. [章節名]
       - 影響:[具體說明]

    **建議的更新內容**:
    ```diff
    [diff]
    ```

    **版本影響**:
    - 版本號:v1.1.0 → v1.2.0
    - CHANGELOG 將新增條目([Added / Changed / ...])

    是否確認這些變更?

三條 load-bearing 原則:
- **不要**未確認前直接修改 CLAUDE.md
- **必須**先展示 diff
- User 有意見先討論,而非執著於原草稿

### Step B3:依分支策略執行更新

```bash
current_branch=$(git branch --show-current)
```

**情況 A:功能分支**(`feat/*`、`fix/*`、`refactor/*`、`hotfix/*`、`docs/*`)

該功能本身觸發了 CLAUDE.md 更新(例:新增功能模組導致 Architecture 調整),直接在當前分支 commit,保持邏輯完整性:

```bash
git add .claude/CLAUDE.md .claude/CLAUDE-CHANGELOG.md
git commit -m "docs(claude): update development guidelines

Authored-By: <YourName> <your-email@example.com>"
```

**情況 B:`dev` / `qas` / `main` 分支**

CLAUDE.md 更新與任何功能分支無關(例:User 單獨提規範調整),建立獨立 docs 分支:

```bash
git checkout -b docs/update-claude-md
# 若分支已存在(同日多次更新、前次 PR 未 merge)用日期後綴避免衝突:
# git checkout -b docs/update-claude-md-$(date +%Y%m%d)

git add .claude/CLAUDE.md .claude/CLAUDE-CHANGELOG.md
git commit -m "docs(claude): update development guidelines

Authored-By: <YourName> <your-email@example.com>"
git push origin docs/update-claude-md
# 建立 PR 到 dev
```

### Step B4:必須同步完成的三項

1. 修改 CLAUDE.md 內容章節
2. 更新 footer:`Last Updated` → 當日;`Version` → 依 SemVer 遞增
3. CLAUDE-CHANGELOG.md 頂部新增對應版本條目(Keep a Changelog 格式)

**兩檔必須在同一個 commit**,確保歷史可追溯。

### Step B5:向 User 確認結果

摘要變更項目 + 版本資訊(舊 → 新 + 日期)+ commit 策略(當前功能分支 / docs 分支)。

### Step B6:連動評估 README.md

若本次變更包含 **User-facing** 項目(Project Overview 調整、Tech Stack 新增依賴、Architecture 變更、新 CLI 介面 / 環境變數):

> 此次變更可能也影響 README.md 與 docs/。建議接著啟用 `maintaining-readme-md` skill 同步檢查。要進行嗎?

純內部規範(coding conventions、測試策略)→ 不需啟動此 hook。

---

## Semantic Versioning 規則

| 變更類型 | 遞增 | 範例 |
|---------|------|------|
| 重大架構變更(章節重構、移除既有規範、工作流程重大改動) | Major | v1.2.0 → v2.0.0 |
| 新增章節或規範(Added) | Minor | v1.1.0 → v1.2.0 |
| 修改既有規範細節(Changed) | Minor | v1.1.0 → v1.2.0 |
| 文字修正、錯字、格式調整 | Patch | v1.1.0 → v1.1.1 |

---

## CLAUDE-CHANGELOG.md 維護規則

採 [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/) 格式。

| 分類 | 使用時機 |
|------|---------|
| `Added` | 新增章節、新增規範項目 |
| `Changed` | 修改既有規範的內容或細節 |
| `Deprecated` | 即將移除但暫時保留的規範 |
| `Removed` | 移除的章節或規範 |
| `Fixed` | 修正錯字、邏輯錯誤、矛盾描述 |
| `Security` | 安全相關規範的變更 |

撰寫原則:
- 版本反序排列(最新在最上)
- 每次 CLAUDE.md 更新必須同步新增一個版本條目
- 版本號、日期與 CLAUDE.md footer metadata 一致
- 兩檔必須在同一個 commit
- 條目以 **User 視角**撰寫(「變了什麼」,不是「改了哪一行」)

條目範例:

```markdown
## [v1.2.0] - 2026-04-23

### Added
- Development Workflow 章節新增 pre-commit hook 流程,強制 commit 前 lint + 測試

### Changed
- Coding Conventions 的 docstring 格式從 NumPy Style 改為 Google Style(連動 `code-style.md`)

### Removed
- 移除 `notebooks/` 目錄說明,專案不再使用 Jupyter Notebooks
```

**與 template 自身 CHANGELOG 的區分**:
- `.claude/CLAUDE-CHANGELOG.md`:user 專案自己的 CLAUDE.md 演進史,由本 skill 寫入
- `CHANGELOG.md`(template 根目錄):claude-code-setup-v1 template 自身的演進史。User 複製 `.claude/` 時**不會跟著過去**。本 skill **不寫入**此檔。

---

## 特殊情況

- **多個小變更累積**:一次展示所有 diff,版本號僅遞增一次,CHANGELOG 條目可整合多個分類
- **緊急 hotfix**:若不影響規範描述 → 先 hotfix,事後若發現該情境應納入規範再補
- **實驗性規則**:試行確認有效後才納入;期間觀察記於 commit message 或 PR 描述

---

## 與其他 skill / rule 的互動

| 對象 | 關係 |
|------|------|
| `maintaining-spec-md` | SPEC.md 的 Overview / Tech Stack / Architecture 變更時連動觸發本 skill |
| `maintaining-readme-md` | Step B6 在 User-facing 變更時建議啟用 readme skill |
| `.claude/rules/git-rules.md` | Commit message 格式(`docs(claude):` 或 `chore(template):` + `Authored-By` trailer)、分支命名 |
| `tdd-feature-workflow` | 分支策略須協同,避免破壞功能 PR 的 commit 邏輯完整性 |

---

## Pattern 示例

**觸發**:`User: "我更新了 SPEC.md,把 OrderService 拆成 OrderAPI / OrderWorker / OrderNotifier 三個服務"`

**正確反應**(同步更新 + 展示 diff):

    SPEC.md 的架構變更影響 CLAUDE.md 的 Project Overview、Tech Stack、Architecture 三個章節,先同步更新:

    **建議的更新內容**:
    ```diff
    ## Tech Stack
    + Message Queue: RabbitMQ

    ## Architecture
      src/
    +   order_api/              # REST API 服務
    +   order_worker/           # 背景工作執行
    +   order_notifier/         # 事件通知服務
    ```

    版本號:v1.1.0 → v1.2.0;CHANGELOG 新增 Added + Changed 條目。是否確認?

**錯誤反應**(規範漂移):

    Claude: 好的,我知道了,繼續下一個任務。

→ SPEC 變了但 CLAUDE.md 沒動,下次對話 AI 仍以為是單體架構。

---

## Gotchas(容易忘記的關鍵點)

- **CLAUDE.md 與 CHANGELOG 必須同一個 commit**:兩檔分開提交會讓版本歷史對不上
- **footer 三處版本必須一致**:`Last Updated`、`Version`、CHANGELOG 最新條目
- **分支策略依 current branch**:功能分支直接 commit / 主幹分支開 `docs/update-claude-md`
- **Workflow A 的 baseline reset**:新專案第一次客製化時要把版本 reset 回 `v1.0.0`,不能繼承 template 版本號
- **User 未確認前絕不直接改檔**:load-bearing 原則,違反會破壞信任
