---
name: maintaining-claude-md
description: Use when the user proposes new coding conventions, workflow adjustments (git flow, CI/CD), testing strategy changes, docstring / naming updates, development checklist changes, or new project-specific constraints (performance / security / compliance). Also use when SPEC.md's Project Overview changes in ways that imply new development principles or workflow rules; or when CLAUDE.md still has the `<!-- TEMPLATE NOTICE -->` block at the top and conversation has revealed the corresponding decisions for filling in the inline `<...>` placeholders. Tech stack / architecture / directory-structure changes belong to maintaining-architecture-md (architecture.md), not this skill. Trigger proactively even without explicit mention of "CLAUDE.md" — any conversation touching development rules, coding standards, or workflow conventions should invoke this skill, because keeping CLAUDE.md in sync with practice is load-bearing for every subsequent Claude Code session.
---

# Maintaining CLAUDE.md

這個 skill 讓 Claude Code 正確維護 `.claude/CLAUDE.md`(專案開發規範的真實來源)與搭配的 `.claude/CLAUDE-CHANGELOG.md`(變更歷史)。規範變動經「展示 diff → User 確認 → 同步 CHANGELOG」流程,避免漂移。

---

## 為何需要這層保護

CLAUDE.md 是**每次 Claude Code 對話都會載入**的開發規範。規範寫什麼,AI 就照什麼做;規範過期,AI 就做過期的事。

實務痛點:
- 換 linter 但沒改 CLAUDE.md → AI 仍產出舊規則
- 新增 commit / PR 流程要求但 Development Workflow 沒更新 → AI 不照新流程走
- 測試策略調整但 Testing Protocols 沒同步 → AI 寫的測試不符新標準

**CLAUDE.md 與 practice 脫節 = AI 行為與團隊共識脫節。**

> **範圍邊界**:CLAUDE.md 只放**開發原則與規範**(constitution)。現行**架構、Tech Stack、目錄結構**已移至 `.claude/docs/architecture.md`,由 `maintaining-architecture-md` skill 維護;CLAUDE.md 只保留指向它的連結。涉及技術棧 / 架構 / 目錄變更時,改用該 skill,不在本 skill 處理。

---

## 觸發情境

| 類別 | 何時觸發 |
|------|---------|
| 開發規範 | 新 coding convention、新流程要求、新測試策略(覆蓋率、測試類型) |
| 工作流程 | Git workflow、CI/CD、文檔更新流程變更 |
| 專案需求 | User 特殊習慣、效能 / 安全 / 合規限制 |
| SPEC.md 連動 | Project Overview 變更帶來新開發原則或流程需求 |

技術棧 / 架構 / 目錄結構變更 → 改用 `maintaining-architecture-md`(architecture.md 是其 SoT,不在本 skill 處理)。

(觸發條件以「對話揭示的決策」為主;檔案是否含 placeholder 由下方 entry 邏輯處理,不算觸發條件。)

### Entry 分流邏輯

對話觸發本 skill 後,先執行 Step A1 偵測檔案狀態,再依下表分流:

| 檔案狀態 | 對話內容 | 走向 |
|---------|---------|------|
| 完全有 placeholder 殘留 | (任何內容) | Workflow A(初次客製化) |
| 完全無殘留(已客製化) | 提到規範變更 | Workflow B(更新既有) |
| 部分殘留 + 同時提規範變更 | (兩者並存) | 先告知 user 並讓 user 決定先做哪個——通常先 A 把 placeholder 清掉、再 B 處理規範變更,避免在未定型的 baseline 上累積 diff |

---

## Workflow A:初次客製化(template placeholder 替換)

適用於採用 template 後首次進入本 skill、對話已提供足夠資訊做替換。

### Step A1:確認 entry condition + 列出 placeholder 範圍

先確認檔案處於 template 未客製化狀態——`<!-- TEMPLATE NOTICE` 區塊仍在頂端是唯一可靠訊號:

```bash
grep -n '<!-- TEMPLATE NOTICE' .claude/CLAUDE.md
```

未命中 → 已客製化,改走 Workflow B。

命中 → 接著列出 CLAUDE.md 中所有 `<...>` placeholder 作為後續 dry-run preview 與 Edit 對象:

```bash
grep -n '<[a-zA-Z][^>]*>\|<!-- TEMPLATE NOTICE' .claude/CLAUDE.md
```

### Step A2:從對話推導 placeholder 對應值

若對話尚未揭示專案目的、核心功能(至少 2-3 項)、技術選型方向 → 暫停 Workflow A,告知 user 先用 `superpowers:brainstorming` skill 釐清專案方向,placeholder 暫保留待 brainstorming 完成後一次處理(本 skill 職責是落實規範,不是引導 user 做架構決策)。

資訊基本充足 → 依下表填入:

| Placeholder | 來源 |
|-------------|------|
| `<Project Name>` | User 提到的專案名 |
| `<One-sentence description of what this project does>` | User 第一個需求的摘要 |

> Tech Stack / framework / 目錄結構等 placeholder 不在 CLAUDE.md——它們在 `architecture.md`,由 `maintaining-architecture-md` 的 Workflow A 處理。本 skill 只填 CLAUDE.md 內的 Project Name 與一句話描述。

資訊不完整(例如專案名已定但描述未明)→ 保留 placeholder 並標註,告知「待後續決策明確時由 Workflow B 補上」。

### Step A3:展示替換計畫

以 Step A1 的 grep 結果作為 dry-run preview。向 User 展示:

- **dry-run 結果**:每個匹配的 `<檔案>:<行號>:<片段>`,讓 user 確認替換範圍正確
- **替換對照表**:placeholder → 實際值(用 Step A2 收集)
- **NOTICE 區塊清理計畫**:CLAUDE.md 頂端的 `<!-- TEMPLATE NOTICE -->` 連同前後空行刪除
- **版本基線**:Workflow A 把 CLAUDE.md footer 填為 `Version: v1.0.0` / `Last Updated: 今日`,代表 user 專案規範的起點(獨立於 template 自身演進)。CLAUDE-CHANGELOG.md(空種子)寫入第一個 baseline entry `[v1.0.0]`

請 User 確認後再進 Step A4 執行。User 若只想試跑 template、尚未決定方向 → 尊重並 skip 本 workflow。

### Step A4:逐檔替換與清理(順序重要)

依 Step A3 dry-run 結果,**用 Edit tool 逐檔處理**(每處替換有可見 diff、可回滾,優於 sed 直接改檔):

1. 移除 CLAUDE.md 頂端的 `<!-- TEMPLATE NOTICE -->` 區塊(含前後空行)
2. 替換 CLAUDE.md 的 `<Project Name>` 與 `<One-sentence description of what this project does>`(用 Step A2 收集的對照)

placeholder 數量少(CLAUDE.md 內僅此二處),Edit tool 逐處改可控且每步都能 review。架構 / Tech Stack 的填寫由 `maintaining-architecture-md` 另行處理,本 skill 不碰。

### Step A5:填入版本基線並寫 CHANGELOG baseline

1. 填 CLAUDE.md footer:`Last Updated` → 今日;`Version` → `v1.0.0`
2. 在 `.claude/CLAUDE-CHANGELOG.md` 的 `[Unreleased]` 下方新增:

```markdown
## [v1.0.0] - <今日日期>

### Added
- Initial development guidelines adopted from claude-code-setup-v1 template and customized for <Project Name>
- Project Overview 章節依需求填入(Tech Stack / Architecture 由 architecture.md 維護)
```

### Step A6:Commit

初次客製化通常在尚未有功能分支時,直接在當前分支 commit:

```bash
git add .claude/
git commit -m "chore(template): initial customization

Replaced template placeholders with project-specific values.
Removed TEMPLATE NOTICE block.
Set CLAUDE.md to v1.0.0 as this project's own baseline and wrote
corresponding v1.0.0 entry to CLAUDE-CHANGELOG.md."
```

告知 User:「Template 客製化完畢。後續任何規範 / 架構 / 技術堆疊變更由本 skill 的 Workflow B 處理。」

---

## Workflow B:更新既有 CLAUDE.md

### Step B1:分析影響範圍

自問:
- 這是新增、修改、還是刪除規範?
- 影響哪些章節?(Project Overview / Development Workflow / Coding Conventions / Testing Protocols / Rules Index / Safety & Hooks)
- 連動影響哪些 rules?(`git-rules.md` / `code-style.md` / `testing-rules.md`)
- 是技術棧 / 架構變更嗎?→ 不在本 skill,改用 `maintaining-architecture-md`
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

該功能本身觸發了 CLAUDE.md 更新(例:新增測試策略導致 Testing Protocols 調整),在當前分支 commit。

**重要**:CLAUDE.md / CHANGELOG 改動**獨立成一個 commit**,不混入 feature commit。保持「功能 commit 只動 src/tests、規範 commit 只動 .claude/」的界線——混在一起會讓 git log 分不清「這個 commit 改了功能 + 規範」還是「只改了功能」,違反 git-rules.md「每個 commit 是一個邏輯完整的改動」。

```bash
git add .claude/CLAUDE.md .claude/CLAUDE-CHANGELOG.md
git commit -m "docs(claude): update development guidelines for <feature>"
```

**情況 B:`dev` / `qas` / `main` 分支**

CLAUDE.md 更新與任何功能分支無關(例:User 單獨提規範調整),建立獨立 docs 分支。**分支名以變更主題命名**(`docs/claude-md-<topic>`),避免每次更新都撞同一個 branch:

```bash
# 主題式命名範例
git checkout -b docs/claude-md-pre-commit-hook
# 或:docs/claude-md-google-docstring、docs/claude-md-rabbitmq-deps 等

git add .claude/CLAUDE.md .claude/CLAUDE-CHANGELOG.md
git commit -m "docs(claude): update development guidelines"
git push origin <branch-name>
# 建立 PR 到 dev
```

選 topic 字眼:抓本次 CHANGELOG entry 的核心動詞 / 名詞(例如新增 pre-commit hook 規定 → `pre-commit-hook`;改 docstring 風格 → `google-docstring`)。topic 不需精準,能讓 PR title 一眼分辨即可。

若主題式命名仍意外撞到既有分支(本地或遠端):停下來回報 User,由 User 決定接續 commit 到既有分支、先處理掉既有 PR(merge / close)、或換另一個 topic 命名。

### Step B4:必須同步完成的三項

1. 修改 CLAUDE.md 內容章節
2. 更新 footer:`Last Updated` → 當日;`Version` → 依 SemVer 遞增
3. CLAUDE-CHANGELOG.md 頂部新增對應版本條目(Keep a Changelog 格式)

**兩檔必須在同一個 commit**,確保歷史可追溯。

### Step B5:向 User 確認結果

摘要變更項目 + 版本資訊(舊 → 新 + 日期)+ commit 策略(當前功能分支 / docs 分支)。

### Step B6:連動評估下游

若本次變更包含 **User-facing** 項目(Project Overview 調整、新 CLI 介面 / 環境變數、影響使用方式的流程):

> 此次變更可能也影響 README.md 與 docs/。建議接著啟用 `maintaining-readme-md` skill 同步檢查。要進行嗎?

若對話其實揭示了**技術棧 / 架構**變更(被誤導進本 skill)→ 提示改用 `maintaining-architecture-md`。純內部規範(coding conventions、測試策略)→ 不需啟動下游 hook。

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
- 條目描述**規範變了什麼**(行為差異),而非**改了哪一行**(實作細節),以利後續讀規範的 Claude 與 dev 理解

(commit 同步、版本號一致由 Step B4 + Gotchas 統一處理,此處不重述。)

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

---

## 與其他 skill / rule 的互動

| 對象 | 關係 |
|------|------|
| `maintaining-architecture-md` | Tech Stack / 架構 / 目錄結構已移到 architecture.md;涉及這些的觸發改由它處理,各守各的 SoT |
| `maintaining-spec-md` | SPEC.md 的 Overview 變更帶來新開發原則時連動本 skill |
| `maintaining-decisions-md` | 開發規範背後若有「為什麼這樣定」的決策(2+ 方案 trade-off)→ 連動開 ADR |
| `maintaining-readme-md` | Step B6 在 User-facing 變更時建議啟用 readme skill |
| `.claude/rules/git-rules.md` | Commit message 格式(`docs(claude):` 或 `chore(template):`)、分支命名 |
| `tdd-feature-workflow` | 分支策略須協同,避免破壞功能 PR 的 commit 邏輯完整性 |

---

## Pattern 示例

**觸發**:`User: "docstring 改用 Google Style,而且 commit 前強制跑 pre-commit lint"`

**正確反應**(這是開發規範變更,正屬 CLAUDE.md):

    這影響 CLAUDE.md 的 Coding Conventions + Development Workflow,並連動 code-style.md:

    ```diff
    ## Coding Conventions
    + Docstring 採 Google Style(細節見 code-style.md)
    ## Development Workflow
    + commit 前強制 pre-commit lint
    ```

    版本 v1.1.0 → v1.2.0,CHANGELOG 新增 Changed 條目。是否確認?

**正確反應**(若觸發其實是架構):若 User 說的是「引入 RabbitMQ、把服務拆三組」,那是 **Tech Stack + 架構**變更 → 提示改用 `maintaining-architecture-md`(更新 architecture.md 的 Tech Stack + Code Structure)、`maintaining-decisions-md`(開 ADR 記為什麼引入 / 怎麼拆),CLAUDE.md 僅在因此產生新規範時才動。

**錯誤反應**:把架構 / 技術棧變更硬塞進 CLAUDE.md → 與 architecture.md 雙頭維護。

---

## Gotchas(容易忘記的關鍵點)

- **CLAUDE.md 與 CHANGELOG 必須同一個 commit**:分開 commit 會讓版本歷史對不上,日後 git blame 找不到對應 entry
- **footer 三處版本必須完全一致**:`Last Updated`、`Version`、CHANGELOG 最新條目——任一不一致即等於對 user 撒謊
- **User 未確認前絕不直接改檔**:展示 diff → 等確認 → 才動手;這是 load-bearing 信任原則,違反一次 user 就不再相信本 skill 的 diff preview
