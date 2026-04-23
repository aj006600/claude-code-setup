---
name: maintaining-readme-md
description: Use this skill whenever the user introduces new features, changes API signatures or CLI interfaces, modifies installation or setup steps, adds new dependencies, changes architecture in user-visible ways, updates configuration options, renames or restructures public-facing modules, or when SPEC.md's Project Overview / CLAUDE.md's Tech Stack has been modified in ways that affect how users understand or interact with the project. The skill detects triggers broadly but applies smart delay — if implementation is still in progress it notes and defers; if implementation is complete or PR is in review it executes immediately. It delegates actual content writing to the `documentation-engineer` agent (following style rules: English section titles, Traditional Chinese body, English technical terms) and updates both README.md and docs/ in the same PR as the feature implementation. Trigger this skill proactively even when the user does not explicitly mention "README" or "documentation" — any conversation about user-facing changes, new features, install / setup, or how-to-use aspects should invoke this skill, because user-facing documentation that drifts from implementation is how developers judge whether a project is alive or abandoned.
---

# Maintaining README.md and docs/

這個 skill 讓 Claude Code 能正確地維護 `README.md` 與 `docs/`——專案對外的 User-facing 文檔。當功能隨實作演進時，這個 skill 確保 README 不會停留在過期狀態、docs/ 不會變成文檔墳場。

---

## 為何 README.md 與 docs/ 需要同步維護

README 是大多數人接觸專案的**第一印象**：
- README 過期 → 新用戶照舊指南操作失敗 → 對專案失去信任
- docs/ 過期 → 開發者找不到正確資訊 → 轉而讀 source code 或放棄
- 安裝步驟錯 → 專案看起來像「abandoned project」，即使仍在活躍開發

核心現實：**Open source 的世界裡，文檔即信任。** 大量專案死於文檔落後於程式碼，而非程式碼本身不好。

這個 skill 的設計宗旨：**把文檔更新視為功能的一部分，而非功能完成後的「待辦事項」**——因為後者幾乎總是被遺忘。

---

## 與其他規則的關係

| 規則 / skill / agent | 與本 skill 的關係 |
|---------------------|------------------|
| `maintaining-claude-md` skill | CLAUDE.md 的 User-facing 變更會觸發本 skill（連動更新） |
| `maintaining-spec-md` skill | SPEC.md 的 Project Overview 變更通常同時需更新 README 的專案描述 |
| `documentation-engineer` agent | 本 skill 委派此 agent 產出實際文檔內容（skill 負責 orchestration、agent 負責 writing） |
| `.claude/rules/documentation-style.md` | 本 skill 交給 agent 時須傳達此風格規範（Service / Reference / Guide 三類模板、章節命名標準、Footer 格式） |
| `.claude/rules/code-style.md` | 文檔中的程式碼範例須遵循 docstring / 命名規範 |
| `.claude/rules/git-rules.md` | Commit 時遵循 commit message 格式、文檔更新屬於功能 PR 的一部分 |

### 優先順序原則
1. **Skill 偵測廣、執行謹慎**：description 觸發範圍大，但 skill body 會判斷當前是否適合執行
2. **文檔屬於功能的一部分**：README / docs 更新加入功能 PR，不另開分支（除非已 merge）
3. **委派 specialist**：skill 不自行寫文，交給 `documentation-engineer` agent 處理內容產出

---

## 觸發情境清單（廣觸發設計）

### 1. User-facing 實作變更
- 新功能實作（影響 Features 清單、Usage 範例）
- API endpoint / 參數 / 回傳值變更
- CLI 介面變更（新 command、flag 變動）
- 安裝步驟變更（新依賴、新的環境變數、不同的 setup flow）
- 架構變更（影響 User 理解或使用方式）
- 設定選項變更（config.yaml / env 格式變動）
- 公開模組重新命名或重構

### 2. SPEC.md / CLAUDE.md 連動變更
| 上游變更 | README / docs 需檢查 |
|---------|---------------------|
| SPEC.md Project Overview 調整 | README Overview / About 章節 |
| CLAUDE.md Tech Stack 新增依賴 | README Installation / Requirements |
| CLAUDE.md Architecture 調整 | docs/ architecture.md 或 README Architecture 章節 |

### 3. docs/ 專屬觸發
- 新功能需要詳細 Service 文檔
- 架構變更需要更新 architecture guide
- API 文檔需要更新（endpoint、schema、error codes）
- 新增使用範例、tutorials、troubleshooting 條目

---

## 智慧延後邏輯（本 skill 的核心設計）

**description 觸發後，不要立刻動手寫文檔**——先判斷當前實作狀態，避免在 TDD 中途或 code review 前產出錯的文檔：

```
偵測到觸發 → 判斷當前實作狀態 → 選擇對應執行策略
```

### 狀態判斷表

| 狀態 | 判斷依據 | 對應策略 |
|------|---------|---------|
| **A：實作中（TDD 測試未全通過）** | 當前分支有未通過的測試、程式碼未定稿、User 正在迭代中 | **記錄 + 延後**：使用 TodoWrite 記錄「待更新 README」，並口頭告知 User。不立刻進入 Step 1 |
| **B：實作完成、未開 PR** | 測試通過、功能定稿、未建立 PR | **立即執行**：最佳時機，進入 Step 1 |
| **C：已開 PR、Review 中/通過** | PR 存在、branch 未 merge | **立即執行**：加入同一 PR（不另開分支），進入 Step 1 |
| **D：已 merge 到 dev/qas/main** | 功能已 merge、回追發現遺漏文檔更新 | **補救流程**：建立 `docs/update-readme-<feature>` 分支，進入 Step 1 |

### 延後記錄範例（狀態 A）

```
📝 已偵測到本次變更會影響 README.md

偵測內容：新增 CSV 匯出功能
影響文檔：README Features 章節、Usage 章節、可能需新增 docs/export-guide.md

目前判斷：功能實作中（測試尚未全通過），暫不更新文檔。
我已記錄此項待辦，等實作完成後會主動提醒您執行文檔更新。
```

---

## Workflow：更新 README.md 與 docs/

### Step 1：分析本次變更對 User 的影響範圍

自問：
- 這個變更影響 User 如何安裝專案嗎？→ Installation
- 影響 User 如何使用專案嗎？→ Usage / Quick Start
- 影響 User 理解專案架構嗎？→ Architecture
- 影響現有 API / CLI 用法嗎？→ API Reference / CLI docs
- 是否需要新的教學或範例？→ docs/tutorials/
- 是否需要 migration guide（破壞性變更）？→ docs/migration.md

### Step 2：決定更新範圍

| 變更性質 | 更新範圍 |
|---------|---------|
| 小幅功能變更、範例更新 | 僅 README |
| 需詳細說明的新功能 | README（簡述 + 連結）+ docs/（詳細內容） |
| 架構重構、破壞性變更 | README + docs/ architecture + docs/migration |
| 僅內部重構（User 無感） | **不觸發本 skill** |

### Step 3：委派 `documentation-engineer` agent 產出內容

使用 Agent tool 呼叫，傳遞明確的 context：

```
Agent({
  description: "Update README for new feature",
  subagent_type: "documentation-engineer",
  prompt: `
    更新 README.md 與 docs/ 以反映新功能：[功能名稱]

    **變更摘要**：[具體內容]

    **受影響章節**：
    - README.md: [章節清單]
    - docs/: [檔案清單]

    **務必先閱讀以下參考檔案**：
    1. \`.claude/rules/documentation-style.md\` — 通用規範（Footer 格式、標題層級、程式碼區塊、Mermaid 圖表、章節命名標準等）
    2. 依文檔類型選讀對應模板：
       - Service 類（服務說明）→ \`.claude/skills/maintaining-readme-md/references/service-template.md\`
       - Reference 類（CLI、config、API）→ \`.claude/skills/maintaining-readme-md/references/reference-template.md\`
       - Guide 類（troubleshooting、how-to、概念說明）→ \`.claude/skills/maintaining-readme-md/references/guide-template.md\`

    **語言規範**：
    - 章節標題使用英文（Features, Installation, Usage, API Reference 等）
    - 章節內容以繁體中文為主
    - 技術術語使用英文（例如：API endpoint、response schema、throughput）

    **不要直接修改檔案**，請先輸出完整 diff 或新增內容草稿供我 review。
  `
})
```

**為何委派而非自行產出**：`documentation-engineer` agent 專精文檔產出、熟悉 API doc、教學設計、info architecture。Skill 是 orchestrator（決定何時、更新什麼），agent 是 specialist（決定怎麼寫得好）。

### Step 4：展示 diff 取得 User 確認

將 agent 產出的內容組織成：

```
📋 README / docs 更新建議

**變更原因**：
[為什麼需要更新]

**受影響的檔案與章節**：
1. README.md
   - Features：[變更摘要]
   - Usage：[變更摘要]
2. docs/new-feature-guide.md（新增）
   - [內容大綱]

**建議的更新內容**：
\`\`\`diff
[README.md diff]
\`\`\`

**新增檔案 docs/new-feature-guide.md**：
\`\`\`markdown
[完整內容]
\`\`\`

是否確認這些更新？
```

### Step 5：依狀態執行 commit

**狀態 B / C（功能分支或開 PR 中）**：直接在當前分支修改並 commit 到同一 PR：

```bash
git add README.md docs/
git commit -m "docs: update README and docs for <feature-name>

Authored-By: <YourName> <your-email@example.com>"
```

**狀態 D（已 merge，補救）**：

```bash
git checkout dev && git pull
git checkout -b docs/update-readme-<feature>
git add README.md docs/
git commit -m "docs: retroactively update README for <feature>

Authored-By: <YourName> <your-email@example.com>"
git push origin docs/update-readme-<feature>
# 建立 PR 到 dev
```

### Step 6：若連動回查上游 skill 有遺漏

執行中若發現變更源頭其實來自 SPEC.md 或 CLAUDE.md 但那些檔案還沒同步更新，提醒 User：

「偵測到本次 README 變更對應的功能 / 架構，在 SPEC.md 或 CLAUDE.md 尚未反映。建議回頭啟用 `maintaining-spec-md` / `maintaining-claude-md` skill 先更新上游，避免規範鏈斷裂。」

---

## 與 `documentation-engineer` agent 的協作模式

### 分工
| 職責 | 歸屬 |
|------|------|
| 偵測觸發情境 | Skill |
| 判斷執行時機（智慧延後） | Skill |
| 與 User 互動（展示 diff、取得確認） | Skill |
| 組織 workflow 步驟 | Skill |
| 實際產出文檔內容 | Agent |
| 遵循 documentation-style.md 模板 | Agent |
| API / CLI / Tutorial 的 info architecture | Agent |

### 傳遞給 agent 的必要資訊
1. 變更摘要（what changed）
2. 受影響的檔案與章節
3. 風格要求（標題英文 / 內文繁中 / 術語英文）
4. 不要直接寫檔，先出草稿
5. 遵循的模板類型（Service / Reference / Guide）

---

## README 與 docs/ 分工原則

| 維度 | README.md | docs/ |
|------|-----------|-------|
| 目標讀者 | 首次訪問者、評估是否使用 | 決定使用後、深入查找細節 |
| 長度 | 精簡（避免滾動疲勞） | 可長可分散 |
| 主要內容 | Overview / Quick Start / Features / Installation / 核心 Usage / 連到 docs/ | 詳細 Service 文檔 / Reference / Guide / Troubleshooting |
| 更新頻率 | 重大功能、使用方式、版本 | 任何細節變更 |

**關鍵原則**：README 提供「為什麼要用 + 怎麼立刻開始」，docs/ 提供「完整的使用與維運知識」。

---

## 特殊情況處理

### 情況 1：小型修正（錯字、格式）
- 不每次觸發完整 workflow
- 累積多個小修正後一次性委派 agent 處理
- commit message：`docs: fix typos and formatting in README`

### 情況 2：僅內部重構（不影響 User 介面）
- **不觸發本 skill**
- 例如：將 `utils.py` 拆成多個檔案、內部變數更名
- 若仍有疑慮，問 User：「此變更看起來不影響 User，要跳過 README 更新嗎？」

### 情況 3：功能延後或取消
- 若功能被取消且已寫入 README → 更新 README 移除該功能說明 + 可能需寫 migration / deprecation notice
- 若功能延後實作但已有草稿文檔 → 標記為 `[Coming Soon]` 或暫時移除

### 情況 4：破壞性變更（Breaking Change）
- 強制在 docs/ 新增 `MIGRATION.md` 或 `CHANGELOG.md` 條目
- README 顯著位置標註 breaking change
- 不要悄悄修改舊內容，應保留舊版 + 標註 deprecated + 指向新版

---

## 好做法 vs 不好做法

### ✅ 好做法
```
User: "CSV 匯出功能實作完成，測試都過了"

Claude:
偵測到新功能實作完成（狀態 B：實作完成、未開 PR），
啟用 maintaining-readme-md skill。

📋 README / docs 更新建議

**變更原因**：新增 CSV 匯出功能

**受影響的檔案與章節**：
1. README.md
   - Features 章節：新增「CSV Export」項目
   - Usage 章節：新增匯出範例
2. docs/export-guide.md（新增）
   - CSV 格式說明、匯出選項、錯誤處理

委派 documentation-engineer agent 產出內容中...

[展示 diff]

是否確認這些更新？
```

### ❌ 不好做法
```
User: "CSV 匯出功能實作完成"

Claude: 收到！功能完成了。要不要我幫忙開 PR？
[README 沒更新、docs/ 沒新增說明，User 不會主動想到文檔]
```
**為什麼不好**：功能完成就是文檔更新的最佳時機（狀態 B）。錯過這個時機後，文檔往往永遠不會被補上，形成「功能有、文件無」的情況。

---

## 自我檢查清單

### 觸發判斷前
- [ ] 這個變更是否影響 User 的安裝、使用、理解方式？
- [ ] 當前實作狀態是 A / B / C / D 哪一個？
- [ ] 如果是狀態 A，已用 TodoWrite 記錄待辦並告知 User？
- [ ] 上游 SPEC.md / CLAUDE.md 是否已同步更新？

### 委派 agent 前
- [ ] 變更摘要是否完整？
- [ ] 受影響章節是否列清楚？
- [ ] 已明確告知 agent 風格要求（英文標題、繁中內文、英文術語）？
- [ ] 已要求 agent 先出草稿而非直接修檔？

### Commit 前
- [ ] 已展示 diff 給 User 並取得確認？
- [ ] commit message 遵循 `git-rules.md` 格式且含 `Authored-By`？
- [ ] 依狀態選對 commit 策略（同功能分支 / 新 docs 分支）？
- [ ] README 與 docs/ 更新在同一個 commit（若同時更新）？
