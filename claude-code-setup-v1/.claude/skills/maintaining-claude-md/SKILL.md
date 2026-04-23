---
name: maintaining-claude-md
description: Use this skill whenever the user proposes new coding conventions, changes to project structure (adding or removing directories, reorganizing modules), workflow adjustments (git flow, CI/CD, documentation processes), testing strategy changes, docstring or naming convention updates, new technical dependencies, changes to the development checklist, or new project-specific constraints. Also use when SPEC.md's Project Overview / Tech Stack / Architecture sections have been updated and CLAUDE.md may need synchronous updating. Also use when CLAUDE.md still contains template placeholders (e.g., `<Project Name>`, `<your framework>`, `<your-modules>`, `<list project-specific dependencies here>`) or the `<!-- TEMPLATE NOTICE -->` block, and the conversation has revealed the corresponding decisions (project name, chosen framework, directory layout, dependencies, git identity for `<YourName>` / `<your-email@example.com>`) — the skill runs Workflow A to replace placeholders in one go. The skill analyzes change impact, shows a diff for user confirmation, then updates `.claude/CLAUDE.md` with proper Semantic Versioning, adds a corresponding entry to `.claude/CLAUDE-CHANGELOG.md` (Keep a Changelog format), and commits both files together using branch-aware strategy (direct commit on feature branches, separate `docs/update-claude-md` branch on `dev`/`qas`/`main`). Trigger this skill proactively even when the user does not explicitly mention "CLAUDE.md" — any conversation touching development rules, coding standards, project structure, or workflow conventions should invoke this skill, because keeping CLAUDE.md synchronized with project practice is load-bearing for every subsequent Claude Code session.
---

# Maintaining CLAUDE.md

這個 skill 讓 Claude Code 能正確地維護 `.claude/CLAUDE.md`——專案的開發規範真實來源，與搭配的 `.claude/CLAUDE-CHANGELOG.md`——變更歷史記錄。當規範隨專案演進時，這個 skill 確保規範不會悄悄漂移、歷史不會無痕遺失。

---

## 為何 CLAUDE.md 需要這層保護

CLAUDE.md 是**每次 Claude Code 對話都會載入**的開發規範。這代表：
- 規範寫什麼，AI 就照什麼做
- 規範過期，AI 就做過期的事
- 規範不一致，AI 就產生不一致的成果

實務上最常見的痛點：
- 團隊決定改用新 linter，但沒改 CLAUDE.md → AI 還是產出舊規則
- 目錄結構重整，但 CLAUDE.md 的 Architecture 沒更新 → AI 建檔到錯的位置
- 測試策略調整，但 Testing Protocols 沒同步 → AI 寫的測試不符合新標準

**CLAUDE.md 與實際 practice 脫節 = AI 行為與團隊共識脫節。** 這個 skill 強制規範變動經過「展示 diff → User 確認 → 同步 changelog」的標準流程，避免漂移。

---

## 與其他規則的關係

| 規則 / skill | 與本 skill 的關係 |
|-------------|------------------|
| `maintaining-spec-md` skill | SPEC.md 的 Project Overview / Tech Stack / Architecture 變更時會建議啟用本 skill（連動更新） |
| `maintaining-readme-md` skill | 本 skill Step 5 在 CLAUDE.md 變更包含 User-facing 項目時會建議啟用 readme skill |
| `.claude/rules/git-rules.md` | 本 skill commit 時須遵循 commit message 格式（含 `Authored-By` trailer）、分支命名規範 |
| `.claude/rules/development-workflow-details.md` | 分支策略須與功能分支流程協同，避免破壞功能 PR 的 commit 邏輯完整性 |
| `.claude/CLAUDE-CHANGELOG.md` | 本 skill 每次更新 CLAUDE.md 時必須同步新增條目，兩檔在同一 commit |

### 優先順序原則
1. **CLAUDE.md 是專案開發規範的真實來源**
2. **更新 CLAUDE.md 必須同步更新 CLAUDE-CHANGELOG.md**，兩者在同一 commit
3. **SPEC.md 與 CLAUDE.md 職責不同**：SPEC.md 定義「要做什麼」（需求），CLAUDE.md 定義「如何做」（規範）

---

## 觸發情境清單

遇到下列任一情況，**暫停手邊動作並啟用本 skill**：

### 1. 新的開發規範或最佳實踐
- User 建議新的 coding convention
- 特定開發流程要求
- 新測試策略（含覆蓋率標準、測試類型配比）

### 2. 專案結構變更
- 新增 / 移除目錄
- 模組組織方式調整
- 新的技術堆疊加入

### 3. 工作流程調整
- Git workflow 變更（分支策略、commit 規範）
- CI/CD 流程更新
- 文檔更新流程變更

### 4. 專案特定需求
- User 的特殊開發習慣
- 專案限制或約束（效能、安全、合規）

### 5. SPEC.md 變更連動
| SPEC.md 變更 | CLAUDE.md 需檢查章節 |
|-------------|---------------------|
| Project Overview 調整 | Project Overview |
| Functional Requirements 新增功能模組 | Architecture（目錄結構） |
| Technical Context > Dependencies 新增 | Tech Stack |
| Technical Context > Constraints 新增 | Project Overview 或 Tech Stack |
| 架構層級重構 | Architecture |

### 6. Template 未客製化（初次採用 template 後首次）
- CLAUDE.md 仍含 `<Placeholder>`（如 `<Project Name>`、`<your framework>`、`<your-modules>`）
- CLAUDE.md 頂端仍有 `<!-- TEMPLATE NOTICE -->` 區塊
- `.claude/` 目錄內任何檔案仍含 `<YourName>` 或 `your-email@example.com`

→ 對話揭示相應決策時觸發 **Workflow A**（初次客製化）；否則走 **Workflow B**（更新既有規範）。

---

## Workflow A：初次客製化（template placeholder 替換）

適用於採用 template 後首次進入本 skill——偵測到 CLAUDE.md 仍有 `<Placeholder>` 或 `<!-- TEMPLATE NOTICE -->` 區塊，且對話已提供足夠資訊做替換。

### Step A1：偵測未客製化狀態

```bash
grep -l '<Placeholder>\|<!-- TEMPLATE NOTICE' .claude/CLAUDE.md 2>/dev/null
grep -rln '<YourName>\|your-email@example.com' .claude/ 2>/dev/null
```

任一條件成立 → Workflow A 適用。

### Step A2：從對話推導資訊

從 User 的第一個需求或明確表述中提取：

| Placeholder | 來源 |
|-------------|------|
| `<Project Name>` | User 提到的專案名 |
| `<One-sentence description of what this project does>` | User 第一個需求的摘要 |
| `<your framework, e.g., FastAPI / ...>` | User 選擇的 web framework（若提及） |
| `<list project-specific dependencies here, ...>` | 明確提到的 SDK / DB / 第三方依賴 |
| Architecture 目錄樹的 `<project-name>` / `<your-modules>` | 從需求推導的模組切分 |
| `<YourName>` / `<your-email@example.com>` | Git 身份，可從 `git config user.name` / `user.email` 讀取 |

若資訊不完整，**主動詢問缺失項**（一次問清，避免多輪來回）。尚不能決定的項目（例如詳細模組切分），保留既有範例結構並告知 User「待後續決策明確時由 Workflow B 補上」。

### Step A3：展示完整替換計畫

向 User 展示：

```
Template 初次客製化計畫

偵測到未客製化項目：
- CLAUDE.md: <!-- TEMPLATE NOTICE --> 區塊 + N 處 <Placeholder>
- .claude/ 下 M 個檔案含 <YourName> / your-email@example.com

替換對照：
- <Project Name> → [實際名稱]
- <One-sentence description ...> → [描述]
- <your framework, ...> → [framework]
- <YourName> → [Git 用戶名]
- your-email@example.com → [Git email]
- ...

另將清理：
- CLAUDE.md 頂端的 <!-- TEMPLATE NOTICE --> 區塊

版本影響：
- CLAUDE.md 當前版本保持不變（初次客製化為資訊補入，不算規範變動）
- 或升 patch（+0.0.1，視為 Fixed 類）——由 User 選擇

是否確認執行？
```

若 User 只想試跑 template、尚未決定專案方向，尊重其決定並 skip 此 workflow。

### Step A4：批次替換與清理

User 確認後執行（順序重要）：

1. **移除 CLAUDE.md 頂端的 `<!-- TEMPLATE NOTICE -->` 區塊**（含前後空行）
2. **替換 CLAUDE.md 各 `<Placeholder>`**（用 Step A2 收集的對照）
3. **批次替換 `.claude/` 下的 `<YourName>` / `your-email@example.com`**：

```bash
# macOS
find .claude -type f \( -name "*.md" -o -name "*.sh" \) -exec sed -i '' \
  -e "s|<YourName>|<實際姓名>|g" \
  -e "s|your-email@example.com|<實際 email>|g" {} +

# Linux
find .claude -type f \( -name "*.md" -o -name "*.sh" \) -exec sed -i \
  -e "s|<YourName>|<實際姓名>|g" \
  -e "s|your-email@example.com|<實際 email>|g" {} +
```

### Step A5：Commit

初次客製化通常在尚未有功能分支時執行，直接在當前分支 commit：

```bash
git add .claude/
git commit -m "chore(template): initial customization

Replaced template placeholders with project-specific values.
Removed TEMPLATE NOTICE block.

Authored-By: <實際姓名> <實際 email>"
```

若 Step A3 選擇升 patch 版本，CLAUDE.md footer 升 `v<current>+0.0.1` 且 CLAUDE-CHANGELOG.md 同步新增一條 `Fixed` 條目（兩檔一起 commit）。

### 完成後

告知 User：「Template 已客製化完畢。後續任何規範 / 架構 / 技術堆疊變更會由本 skill 的 Workflow B 處理。」

---

## Workflow B：更新既有 CLAUDE.md 與 CLAUDE-CHANGELOG.md

### Step 1：分析需求是否影響 CLAUDE.md

**自我檢查**：
- [ ] 這個變更是新增規範、修改規範、還是刪除規範？
- [ ] 影響 CLAUDE.md 的哪些章節？（Project Overview / Tech Stack / Architecture / Development Workflow / Coding Conventions / Testing Protocols / Development Checklist）
- [ ] 是否連動影響其他 rules（如 `git-rules.md`、`code-style.md`、`testing-rules.md`）？
- [ ] 是否為暫時性實驗，還是需納入正式規範？

若判斷不影響 CLAUDE.md（例如純粹的內部變數命名），向 User 簡短說明後跳出本 skill；若有影響，進入 Step 2。

### Step 2：展示 diff 取得 User 確認

```
CLAUDE.md 更新建議

**變更原因**：
[為什麼需要更新]

**受影響的章節**：
1. [章節名稱]
   - 影響：[具體說明]

**建議的更新內容**：
\`\`\`diff
## [章節名]
- [舊內容]
+ [新內容]
\`\`\`

**版本影響**：
- 版本號：v1.1.0 → v1.2.0
- CLAUDE-CHANGELOG.md 將新增對應條目（分類：[Added / Changed / ...]）

是否確認這些變更？
```

**重要原則**：
- **不要**在未經 User 確認前直接修改 CLAUDE.md
- **必須**先展示 diff 並取得同意
- 若 User 有其他意見，根據回饋調整後再次展示（而非執著於原草稿）

### Step 3：User 確認後，依分支策略執行更新

#### 3.1 分支策略判斷

依當前分支決定 commit 策略，避免與 `development-workflow-details.md` 的功能分支流程衝突：

```bash
current_branch=$(git branch --show-current)
```

**情況 A：已在功能分支**（`feat/*`、`fix/*`、`refactor/*`、`hotfix/*`、`docs/*`）

該功能本身觸發了 CLAUDE.md 更新（例如：新增功能模組導致 Architecture 章節調整），直接在當前分支修改並 commit，保持 commit 的邏輯完整性：

```bash
git add .claude/CLAUDE.md .claude/CLAUDE-CHANGELOG.md
git commit -m "docs(claude): update development guidelines

Authored-By: <YourName> <your-email@example.com>"
```

**情況 B：在 `dev` / `qas` / `main` 分支**

CLAUDE.md 的更新與任何功能分支無關（例如：User 單獨提出規範調整），建立獨立的 docs 分支：

```bash
# 若 docs/update-claude-md 分支已存在（極端情境：同一天多次更新、前次 PR 未 merge、
# local 分支未清理等），改用帶日期後綴避免衝突：
# git checkout -b docs/update-claude-md-$(date +%Y%m%d)

git checkout -b docs/update-claude-md
git add .claude/CLAUDE.md .claude/CLAUDE-CHANGELOG.md
git commit -m "docs(claude): update development guidelines

Authored-By: <YourName> <your-email@example.com>"
git push origin docs/update-claude-md
# 建立 PR 到 dev
```

#### 3.2 必須同步完成的三項

1. **修改 CLAUDE.md 內容章節**
2. **更新 CLAUDE.md 底部 metadata**
   - `**Last Updated**` 改為當日日期
   - `**Version**` 依 Semantic Versioning 規則遞增
3. **CLAUDE-CHANGELOG.md 頂部新增對應版本條目**（格式見下方章節）

**兩個檔案必須在同一個 commit 中提交，確保歷史可追溯。**

### Step 4：向 User 確認更新結果

```
CLAUDE.md 已更新

**更新摘要**：
- [具體變更項目]

**版本資訊**：
- 版本：v1.1.0 → v1.2.0
- 更新日期：YYYY-MM-DD
- CHANGELOG 條目已同步新增

**Commit 策略**：
- 分支：[當前功能分支 / docs/update-claude-md]
- Commit：[已 commit / 已 push / 已建立 PR]

請確認更新內容是否符合您的需求。
```

### Step 5：連動評估 README.md

若本次 CLAUDE.md 變更包含 **User-facing** 項目：
- Project Overview 調整（專案用途、目標使用者）
- Tech Stack 新增 / 替換依賴
- Architecture 變更（影響 User 理解或使用）
- 新增 CLI 介面、環境變數需求

主動提示 User：
「此次 CLAUDE.md 變更可能也影響 README.md 與 docs/。建議接著啟用 `maintaining-readme-md` skill 同步檢查是否需更新 User-facing 文檔。是否進行？」

若變更純粹為內部規範（如 coding conventions、測試策略），不需啟動此 hook。

---

## Semantic Versioning 規則

CLAUDE.md 的版本號遵循 [Semantic Versioning](https://semver.org/)：

| 變更類型 | 版本遞增 | 範例 |
|---------|---------|------|
| 重大架構變更（章節重構、移除既有規範、工作流程重大改動） | 主版本號 +1.0.0 | v1.2.0 → v2.0.0 |
| 新增章節或規範（Added） | 次版本號 +0.1.0 | v1.1.0 → v1.2.0 |
| 修改既有規範細節（Changed） | 次版本號 +0.1.0 | v1.1.0 → v1.2.0 |
| 文字修正、錯字、格式調整 | 修訂號 +0.0.1 | v1.1.0 → v1.1.1 |

---

## CLAUDE-CHANGELOG.md 維護規則

### 採用格式
[Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/) 業界標準格式。

### 變更分類
| 分類 | 使用時機 |
|------|---------|
| `Added` | 新增章節、新增規範項目 |
| `Changed` | 修改既有規範的內容或細節 |
| `Deprecated` | 即將移除但暫時保留的規範 |
| `Removed` | 移除的章節或規範 |
| `Fixed` | 修正錯字、邏輯錯誤、矛盾描述 |
| `Security` | 安全相關規範的變更 |

### 撰寫規則
1. **版本反序排列**：最新版本放在檔案最上方
2. **每次 CLAUDE.md 更新必須同步新增一個版本條目**
3. **版本號與日期須與 CLAUDE.md 底部 metadata 一致**
4. **兩個檔案必須在同一個 commit 中提交**
5. **條目撰寫以 User 視角為主**：說明「變了什麼」，而非「改了哪一行」

### 條目範例

```markdown
## [v1.2.0] - 2026-04-23

### Added
- Development Workflow 章節新增 pre-commit hook 流程，強制在 commit 前執行 lint 與測試

### Changed
- Coding Conventions 的 docstring 格式從 NumPy Style 改為 Google Style（連動 `code-style.md`）

### Removed
- 移除 `notebooks/` 目錄說明，專案不再使用 Jupyter Notebooks
```

### 與 CLAUDE.md 底部 metadata 的關係
CLAUDE.md 底部的 `**Last Updated**` 與 `**Version**` 是「當前狀態快照」，提供快速識別；CLAUDE-CHANGELOG.md 是「完整變更歷史」。兩者資訊不得衝突。

---

## 特殊情況處理

### 情況 1：多個小變更累積
多個錯字 / 格式調整 / 小細節修改：
- 一次性展示所有 diff
- 版本號僅遞增一次
- CHANGELOG 條目可用多個分類（Added / Changed / Fixed）整合呈現

### 情況 2：緊急 hotfix
若為緊急修復（hotfix 分支）且不影響規範描述：
- 可先完成 hotfix，不立即更新 CLAUDE.md
- Hotfix merge 後，若發現該情境應納入規範，再補 CLAUDE.md 更新

### 情況 3：實驗性規則
若 User 想試行某項規範（例如：新的 agent 使用策略）：
- **不要**立即更新 CLAUDE.md
- 試行確認有效後，再正式納入 CLAUDE.md
- 試行期間的觀察可記於 commit message 或 PR 描述中

---

## 好做法 vs 不好做法

### 好做法
```
User: "我更新了 SPEC.md，將 OrderService 從單體架構拆成
     OrderAPI / OrderWorker / OrderNotifier 三個獨立服務"

Claude:
我注意到 SPEC.md 的架構變更會影響 CLAUDE.md 的 Project Overview、
Tech Stack、Architecture 三個章節，先同步更新：

CLAUDE.md 更新建議

**變更原因**：
SPEC.md 新增服務拆分定義，CLAUDE.md 須同步更新以維持規範一致性

**受影響的章節**：
1. Project Overview - 補充微服務架構說明
2. Tech Stack - 新增訊息佇列依賴
3. Architecture - 新增三個服務的子模組分層

**建議的更新內容**：
\`\`\`diff
## Project Overview
- 核心原則：OrderService 單體服務提供訂單管理
+ 核心原則：Order 微服務系統（OrderAPI + OrderWorker + OrderNotifier）

## Tech Stack
+ Message Queue: RabbitMQ

## Architecture
  src/
+   order_api/              # REST API 服務
+   order_worker/           # 背景工作執行
+   order_notifier/         # 事件通知服務
\`\`\`

**版本影響**：
- 版本號：v1.1.0 → v1.2.0（新增章節內容）
- CHANGELOG 將新增 Added 與 Changed 條目

是否確認這些更新？
```

### 不好做法
```
User: "我更新了 SPEC.md，將 OrderService 拆成微服務架構"

Claude: 好的，我知道了，繼續下一個任務。
[SPEC 變了，但 CLAUDE.md 沒動，下次對話 AI 仍以為是單體架構]
```
**為什麼不好**：CLAUDE.md 與 SPEC.md 脫節，未來對話中 AI 依舊讀到舊規範，會做出與專案現況不符的決策。

---

## 自我檢查清單

### 更新 CLAUDE.md 前
- [ ] 已讀取並理解目前的 CLAUDE.md 內容
- [ ] 已識別變更的具體範圍與影響章節
- [ ] 已判斷是否連動影響其他 rules 或 SPEC.md
- [ ] 已向 User 展示 diff 並取得確認

### 更新 CLAUDE.md 時
- [ ] 同步更新 CLAUDE.md 底部的 `Last Updated` 日期
- [ ] 依 Semantic Versioning 更新 `Version`
- [ ] 同步在 CLAUDE-CHANGELOG.md 頂部新增對應條目
- [ ] 依 Keep a Changelog 格式選用正確的變更分類
- [ ] 檢查當前分支決定 commit 策略（功能分支直接 commit / 其他分支建 docs 分支）
- [ ] commit message 遵循 `git-rules.md` 格式且包含 `Authored-By` trailer

### 更新完成後
- [ ] CLAUDE.md 與 CLAUDE-CHANGELOG.md 在同一個 commit 中提交
- [ ] 向 User 確認更新結果（摘要、版本資訊、commit 策略）
- [ ] 若變更包含 User-facing 項目，主動建議啟用 `maintaining-readme-md` skill
