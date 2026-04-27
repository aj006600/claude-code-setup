---
name: maintaining-spec-md
description: Use when the user proposes new features, modifies requirements, changes scope or acceptance criteria, discovers technical constraints affecting requirements, or when API / data model / architecture changes affect specs. Also use when bug fixes reveal requirement misunderstandings, or when the project has no SPEC.md yet. Trigger proactively even without explicit mention of "SPEC.md" — any conversation touching requirements, features, scope, acceptance criteria, or project goals should invoke this skill. Keeping SPEC.md synchronized with implementation is load-bearing for this project.
---

# Maintaining SPEC.md

這個 skill 讓 Claude Code 正確建立與維護 `.claude/SPEC.md`——專案的需求 single source of truth。

---

## 為何需要這層保護

實務痛點是「規格 / 實作 / AI 記憶」三者脫節:
- 新需求 → 直接動手 → 規格沒更新 → 下次對話失去 context
- 技術限制 → 靜默調整需求 → 規格描述變成謊言
- 實作中新發現的 Acceptance / 邊界條件沒寫回 SPEC → 規格漂移

**修改實作而不修改 SPEC.md 就是契約違約。** 本 skill 強制在動手前校準規格。

SPEC 描述「專案**是**什麼」的靜態契約;「做到哪了」由 git branch / PR merge 反映,SPEC 不追蹤進度。

---

## 觸發情境

| 類別 | 何時觸發 |
|------|---------|
| 需求變更 | 新功能 / 需求修改 / 範圍調整 |
| 實作發現 | 需求不明、Acceptance 需修訂、邊界條件需補充 |
| 程式碼改動 | user-facing API / schema 改變(影響 FR / Acceptance) |
| Acceptance 達成 | 功能完成 → 勾選已達成的 Acceptance Criteria checkbox |
| Bug 揭示 | Bug 揭示原需求錯誤 → 更新 Description / Acceptance |
| 專案無 SPEC.md | 執行 Workflow A 建立初始版本 |

---

## Workflow A:初次建立 SPEC.md

### Step A1:確認檔案不存在
Read 或 Glob `.claude/SPEC.md` → 存在則改走 Workflow B。

### Step A2:向 User 收集需求
用自然對話或 AskUserQuestion 收集:
1. **專案目的與背景**:要解決什麼問題?目標使用者?
2. **核心功能需求**(至少 2-3 個):功能清單,各含 User Needs 與初步 Acceptance Criteria
3. **範圍邊界**:哪些**不在**範圍內?

具體提問避免空白頁困境。可舉例引導:「例如:不處理批次匯入、不支援多語系」。

> **不在本 workflow 收集的事項**:技術選型(語言版本、外部依賴、技術限制、架構)屬 CLAUDE.md 的 Tech Stack / Architecture 章節範疇——SPEC 建立後若需記錄,啟用 `maintaining-claude-md` skill 接手處理。職責切分清楚,規範鏈才不會重疊漂移。

### Step A3:草擬初始 SPEC.md
讀 `references/spec-template.md` 並依結構填寫:
- 已知資訊填入對應欄位;未知標 `[待確認]`
- Functional Requirements 至少 2-3 個,各含初步 Acceptance Criteria
- Change Log 第一行:`Initial specification`
- 版本號 `v1.0.0`、Last Updated 為當日

### Step A4:展示並確認
**不要**直接 Write 檔案。在對話中展示完整內容 + 摘要(專案目標、功能數),請 User 確認:
1. 需求理解是否正確?
2. 驗收標準是否清楚?
3. 有無遺漏?

### Step A5:User 確認後建立檔案
Write 到 `.claude/SPEC.md`,告知檔案位置、版本、功能數。

### Step A6:Commit 並 hand-off

初次建立 SPEC.md 後直接在當前分支 commit(獨立 commit,不混入其他改動):

```bash
git add .claude/SPEC.md
git commit -m "spec: initial specification

Authored-By: $(git config user.name) <$(git config user.email)>"
```

告知 User:「SPEC.md 已建立(v1.0.0)。後續實作建議啟用 `tdd-feature-workflow` skill 進入階段 2(`writing-plans` → `executing-plans`)。實作中若發現需求需調整,轉 Workflow B 處理。」

---

## Workflow B:更新現有 SPEC.md

### Step B1:識別變更觸發點
**暫停實作**,自問:
- 這是新需求、需求修改、還是實作細節?
- 影響哪些章節?(Overview / Out of Scope / Functional Requirements)
- 是否調整 Acceptance Criteria / Out of Scope?

只是實作細節 → 不更新 SPEC,繼續實作。

> 若變更涉及技術選型或架構(新依賴、tech stack 換)→ **這不是 SPEC 觸發點**,改啟用 `maintaining-claude-md` 更新 CLAUDE.md。

### Step B2:展示更新建議並等待確認

    SPEC.md 更新建議

    **變更原因**:[例如 "User 提出新需求" 或 "實作中發現技術限制"]

    **受影響的章節**:
    1. [章節名]
       - 影響:[具體說明]

    **建議的更新內容**:
    ```diff
    [diff]
    ```

    **版本影響**:
    - 版本號:v1.0.0 → v1.1.0([升版理由])
    - Change Log 將新增一行

    是否確認這些變更?

三條 load-bearing 原則:
- **不要**在未確認前直接修改 SPEC.md
- **必須**先展示 diff 取得同意
- User 有意見先討論調整,而非執著於原草稿

### Step B3:依分支策略執行更新

User 確認後:
1. Edit 對應章節,確保格式一致
2. 同步更新版本資訊:
   - Change Log 表格新增一行(Date / Version / Changes)
   - 底部 `**Last Updated**` 改為當日
   - 底部 `**Version**` 依 SemVer 遞增
3. SPEC.md 變更**獨立成一個 commit**(不混入功能 commit),分支策略視當前情境:

```bash
current_branch=$(git branch --show-current)
```

**情況 A:功能分支**(`feat/*`、`fix/*`、`refactor/*`、`hotfix/*`)

該功能本身觸發了 SPEC 變更(例:實作中發現 acceptance 需修訂),在當前分支 commit:

```bash
git add .claude/SPEC.md
git commit -m "spec: <描述變更內容>

Authored-By: $(git config user.name) <$(git config user.email)>"
```

**情況 B:`dev` / `qas` / `main` 分支**

SPEC 變更與任何功能分支無關(例:User 單獨檢視整體規格、補強 Acceptance Criteria),建立獨立 spec 分支。**分支名以變更主題命名**(`spec/<topic>`),避免每次更新都撞同一個 branch:

```bash
git checkout -b spec/<topic>
# 例:spec/refine-export-acceptance、spec/add-rate-limit-requirement

git add .claude/SPEC.md
git commit -m "spec: <描述變更內容>

Authored-By: $(git config user.name) <$(git config user.email)>"
git push origin spec/<topic>
# 建立 PR 到 dev
```

選 topic 字眼:抓本次 Change Log 條目的核心動詞 / 名詞(例如 refine acceptance → `refine-export-acceptance`)。topic 不需精準,能讓 PR title 一眼分辨即可。

若主題式命名意外撞到既有分支(本地或遠端):停下來回報 User,由 User 決定接續 commit 到既有分支、先處理掉既有 PR、或換另一個 topic 命名。

### Step B4:向 User 確認結果

摘要變更項目 + 版本資訊(舊版 → 新版 + 日期)+ commit 策略(當前功能分支 / spec 分支),開放調整機會。

### Step B5:連動評估下游文檔

SPEC 是最上游,變動通常向下游傳播。依本次變更性質提示 User:

- 影響 **Project Overview / Tech Stack / Architecture** → 提示啟用 `maintaining-claude-md` 同步開發規範
- 影響 **user-facing**(新功能、API / CLI 變更、安裝步驟、新依賴)→ 提示啟用 `maintaining-readme-md` 同步對外文檔

> 此次變更也影響 [CLAUDE.md / README.md] 的 [章節]。要接著啟用 [對應 skill] 同步更新嗎?

兩者都不影響(純內部需求精修)→ 不需啟動下游 hook。

---

## Semantic Versioning 規則

依 [Semantic Versioning](https://semver.org/):

| 變更類型 | 遞增 | 範例 |
|---------|------|------|
| 重大架構變更 / 破壞性改動 / 移除既有功能 / API 重構 | Major | v1.5.2 → v2.0.0 |
| 新需求(Functional Requirements) | Minor | v1.0.0 → v1.1.0 |
| 既有需求**行為**變化(嚴格化 / 放寬 / 新增 Acceptance / 補上 Constraints) | Minor | v1.1.0 → v1.2.0 |
| 既有需求**措辭**釐清(無行為變化,例:把「至少 5 字」改為「至少 5 個字元」) | Patch | v1.1.0 → v1.1.1 |
| 文字修正、錯字、格式 | Patch | v1.1.0 → v1.1.1 |

---

## 特殊情況

- **多個小變更累積**:一次展示所有 diff,版本號僅遞增一次,Change Log 可單行整合
- **緊急 Bug 修復**:不影響需求理解 → 先修復後再評估;揭示需求錯誤 → 必須更新 SPEC
- **實驗性 Prototype**:不立即更新;實驗確認方向後再納入;觀察記於 PR 描述或 commit message

---

## 與其他 skill / rule 的互動

| 對象 | 關係 |
|------|------|
| `maintaining-claude-md` | SPEC.md 的 Overview / Functional Requirements 變更帶來新依賴或架構需求時 Step B5 連動 hint |
| `maintaining-readme-md` | SPEC.md 的 user-facing 變更(新功能 / API / 安裝步驟)時 Step B5 連動 hint |
| `.claude/rules/git-rules.md` | Commit 格式(`spec:` type + `Authored-By` trailer);SPEC 獨立 commit |
| `tdd-feature-workflow` | 本 skill 是 TDD 流程的「需求確認階段」——先更新 SPEC,User 確認後才進入測試先行 |

---

## Pattern 示例

**觸發**:`User: "我想新增使用者可以匯出 CSV 的功能"`

**正確反應**(先規格、後實作):

    這是新功能需求,先更新 SPEC.md:

    SPEC.md 更新建議
    ...
    + ### Data Export
    + - **Description**: 允許匯出資料為 CSV 格式
    + - **Acceptance Criteria**:
    +   - [ ] 支援匯出所有資料列
    +   - [ ] CSV 格式符合 RFC 4180
    ...

    是否確認?

**錯誤反應**(實作跑在規格前):

    Claude: 好的,我直接開始實作 CSV 匯出...

→ 規格脫離實作,下次對話 Claude 不知道這個功能存在。

---

## Gotchas(容易忘記的關鍵點)

- **SPEC.md 變更必須獨立 commit**:不跟 feature code 混在同一 commit,確保規格歷史可追
- **三處版本必須一致**:Change Log、`Last Updated`、`Version`;三者衝突等於謊言,破壞 User 對規格的信任
- **User 未確認前絕不直接寫檔**:違反這條會讓 User 對本 skill 失去信任
- **純實作細節不觸發**:過度觸發會讓 User 忽略 skill 的真正提示

---

SPEC.md 完整 template 見 `references/spec-template.md`。
