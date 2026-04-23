---
name: maintaining-spec-md
description: Use this skill whenever the user proposes new features, modifies existing requirements, adjusts in-scope or out-of-scope boundaries, changes acceptance criteria, discovers technical constraints that affect requirements, updates feature completion status, or when API signatures / data models / architecture change in ways that affect specifications. Also use when bug fixes reveal requirement misunderstandings or when the project has no SPEC.md yet and needs one. The skill analyzes change impact, shows a diff for user confirmation, then updates `.claude/SPEC.md` with proper Semantic Versioning and a Change Log entry. Trigger this skill proactively even when the user does not explicitly mention "SPEC.md" — any conversation touching requirements, features, scope, priority, acceptance criteria, or project goals should invoke this skill, because keeping specifications synchronized with implementation is a load-bearing invariant of this project.
---

# Maintaining SPEC.md

這個 skill 讓 Claude Code 能正確地建立與維護 `.claude/SPEC.md`——專案的需求真實來源（single source of truth）。當需求演進時，實作不能偷偷跑在規格前面；規格也不能停留在過期的狀態。這個 skill 確保兩者同步。

---

## 為何 SPEC.md 需要這層保護

實務上最常見的痛點是「規格 / 實作 / AI 記憶」三者脫節：
- User 提新需求 → Claude 直接動手 → 規格沒更新 → 下次對話失去 context
- 實作遇到技術限制 → Claude 靜默調整需求 → 規格描述變成謊言
- 功能完成 → 沒人標記 Status → 無法判斷進度

SPEC.md 是需求的契約。**修改實作而不修改 SPEC.md 就是契約違約。** 這個 skill 強制在動手前先校準規格。

---

## 與其他規則的關係

| 規則 | 與本 skill 的關係 |
|------|------------------|
| `.claude/CLAUDE.md` | 當 SPEC.md 的 Overview / Tech Stack / Architecture 變更時，連動觸發 `maintaining-claude-md` skill（若已建立） |
| `.claude/rules/git-rules.md` | 本 skill commit SPEC.md 時須遵循 commit message 格式（含 `Authored-By` trailer）；SPEC.md 變更應獨立成一個 commit |
| `.claude/rules/development-workflow-details.md` | 本 skill 的更新流程對應「需求確認階段」——先更新 SPEC.md，User 確認後才進入 TDD 實作 |

### 優先順序原則
1. **SPEC.md 是需求的 single source of truth**——先讀 SPEC.md，再動手
2. **SPEC.md 變更須 User 確認**——不得擅自修改
3. **實作跑在 SPEC 前面時暫停**——回頭更新 SPEC，再繼續

---

## 觸發情境清單

遇到下列任一情況時，**暫停實作並啟用本 skill**：

### 1. User 提出新需求或變更
- 新功能請求 → 新增 Functional Requirement
- 現有功能描述 / 驗收標準改變 → 修改對應條目
- 優先級調整 → 更新 Priority
- 範圍調整 → 更新 In Scope / Out of Scope

### 2. 實作過程中的技術發現
- 遇到技術限制導致需求需調整 → 更新 Constraints 或修改 Acceptance Criteria
- 原需求描述不明確需補充 → 更新 Description
- 需新增技術依賴 → 更新 Dependencies
- 效能或安全需求需明確化 → 更新 Non-Functional Requirements

### 3. 程式碼改動影響規格
- API endpoint / 參數 / 回傳值變更
- 資料模型 schema 結構調整
- 系統架構變更（模組拆分、服務邊界調整）
- 外部依賴升級 / 替換

### 4. 功能狀態變化
- 功能開發完成 → 更新 Status：`In Progress` → `Completed`
- 驗收標準達成 → 勾選對應 checkbox
- 功能暫停 / 取消 → 移至 Out of Scope 或加註

### 5. Bug 修復揭示需求理解錯誤
- Bug 揭示原需求理解錯誤 → 更新 Description / Acceptance Criteria
- 需新增邊界條件或錯誤處理需求 → 補充 Technical Notes

### 6. Open Questions 得到解答
- 未解問題獲得答案 → 從 Open Questions 移除，並更新到相應章節

### 7. 專案還沒有 SPEC.md
- 需建立初始版本 → 使用下方「Workflow A」

---

## Workflow A：初次建立 SPEC.md

### Step A1：確認檔案不存在
使用 Read 或 Glob 檢查 `.claude/SPEC.md`：
- 存在 → 跳到 Workflow B
- 不存在 → 繼續

### Step A2：向 User 收集需求資訊

用自然對話或 AskUserQuestion 收集：
1. **專案目的與背景**：要解決什麼問題？目標使用者是誰？
2. **核心功能需求**（至少 2-3 個）：主要功能清單、優先級（High / Medium / Low）
3. **技術環境**：程式語言 / 版本、外部依賴（API、資料庫）、技術限制（效能、平台）
4. **明確的範圍邊界**：哪些「不在範圍內」？

詢問時要具體，避免讓 User 面對空白頁。可以舉例引導：「例如：Python 3.11+、使用 OpenAI API、回應時間需 < 200ms」

### Step A3：草擬初始 SPEC.md

依「SPEC.md 格式」章節的 template 填寫：
- 所有已知資訊填入對應欄位
- 未知部分標註 `[待確認]`
- Functional Requirements 至少 2-3 個
- 每個功能需有 Priority 和初步 Acceptance Criteria
- 未解決的問題列入 Open Questions
- Change Log 第一行：`Initial specification`
- 版本號：`v1.0.0`
- Last Updated：當前日期

### Step A4：向 User 展示並取得確認

**不要**直接 Write 檔案。先在對話中展示完整內容：

```
已根據您的需求草擬初始 SPEC.md

完整內容：

---
[在此展示完整 markdown]
---

**摘要**：
- 專案目標：[簡述]
- 核心功能：[數量]
- 優先級分布：High (X), Medium (X), Low (X)
- 待解決問題：[數量]

請確認：
1. 需求理解是否正確？
2. 功能優先級是否合理？
3. 驗收標準是否清楚？
4. 有無遺漏的功能或限制？

確認無誤後，我將建立 SPEC.md 檔案。
```

### Step A5：User 確認後建立檔案

- 路徑：`.claude/SPEC.md`
- 使用 Write tool 建立
- 完成後告知 User 檔案位置、版本、功能數、待解決問題數

### Step A6：開始按 Priority 實作
重新 Read SPEC.md 確認理解，然後按 High → Medium → Low 順序實作。實作中若發現需求需調整，轉入 Workflow B。

---

## Workflow B：更新現有 SPEC.md

### Step B1：識別變更觸發點

**暫停實作**，進入 SPEC 評估模式。自問：
- 這個變更是新需求、需求修改、還是單純實作細節？
- 影響 SPEC.md 的哪些章節？（Overview / Functional Requirements / Technical Context / Non-Functional / Open Questions）
- 是否需要調整驗收標準或優先級？
- 是否影響 In Scope / Out of Scope 邊界？

若判斷只是實作細節（例如：換一個內部變數名稱），不需更新 SPEC.md，直接繼續實作。

### Step B2：分析影響範圍並草擬更新

向 User 展示**結構化的變更建議**：

```
SPEC.md 更新建議

**變更原因**：
[為什麼需要更新，例如：「User 提出新功能需求」或「實作中發現技術限制」]

**受影響的章節**：
1. [章節名稱，例如：Functional Requirements > User Authentication]
   - 影響：[具體說明]
2. [其他章節]
   - 影響：[具體說明]

**建議的更新內容**：
\`\`\`diff
## Functional Requirements

### User Authentication
+ **Status**: In Progress (原為 Not Started)

- **Description**: [舊描述]
+ **Description**: [新描述，包含 OAuth 2.0 支援]

- **Acceptance Criteria**:
  - [ ] 支援 email/password 登入
+   - [ ] 支援 Google OAuth 2.0 登入
+   - [ ] 支援 GitHub OAuth 2.0 登入
\`\`\`

**版本影響**：
- 版本號：v1.0.0 → v1.1.0（新增功能）
- Change Log 將新增一行

是否確認這些變更？
```

### Step B3：等待 User 確認

**重要原則**（這三條是 load-bearing，違反會破壞 User 對規格的信任）：
- **不要**在未經 User 確認前直接修改 SPEC.md
- **必須**先展示 diff 並取得同意
- 若 User 有其他意見，先討論後再調整更新內容，而非執著於原草稿

### Step B4：執行 SPEC.md 更新

User 確認後：

1. **用 Edit tool 修改對應章節**，確保格式一致
2. **同步更新版本資訊**：
   - Change Log 表格新增一行（Date / Version / Changes）
   - 底部 `**Last Updated**` 改為當日
   - 底部 `**Version**` 依下方 Semantic Versioning 規則遞增
3. **使用 git commit（若在 git repo 中）**：
   - SPEC.md 變更應**獨立成一個 commit**
   - commit message 使用 `spec` type：
     ```
     spec: <描述變更內容>

     Authored-By: <YourName> <your-email@example.com>
     ```

### Step B5：向 User 確認更新結果

```
SPEC.md 已更新

**更新摘要**：
- [具體變更項目]

**版本資訊**：
- 版本：v1.0.0 → v1.1.0
- 更新日期：YYYY-MM-DD

請確認更新內容是否符合您的需求。如需調整，請告知。
```

### Step B6：若連動影響 CLAUDE.md
當變更影響 Project Overview、Tech Stack、Architecture 時，主動提醒：
「此次變更也影響 CLAUDE.md 的 [章節]。是否要接著啟用 `maintaining-claude-md` skill 同步更新？」

---

## Semantic Versioning 規則

依 [Semantic Versioning](https://semver.org/) 決定版本號：

| 變更類型 | 版本遞增 | 範例 |
|---------|---------|------|
| 重大架構變更或破壞性改動（完全重新設計功能、移除既有功能、API 重構） | 主版本號 +1.0.0 | v1.5.2 → v2.0.0 |
| 新功能或需求新增（新增 Functional / Non-Functional Requirement） | 次版本號 +0.1.0 | v1.0.0 → v1.1.0 |
| 需求修改或補充細節（修改驗收標準、調整功能描述、更新技術限制） | 次版本號 +0.1.0 | v1.1.0 → v1.2.0 |
| 文字修正、錯字、格式調整 | 修訂號 +0.0.1 | v1.1.0 → v1.1.1 |

---

## 特殊情況處理

### 多個小變更累積
多個錯字 / 格式調整 / 小細節修改：
- 一次性展示所有 diff
- 版本號僅遞增一次
- Change Log 可用單行記錄多個變更

### 緊急 Bug 修復
- 若 Bug 不影響需求理解 → 先修復，完成後再評估是否需更新 SPEC
- 若 Bug 揭示需求錯誤 → 必須更新 SPEC

### 實驗性 Prototype
- 不需立即更新 SPEC.md
- 等實驗確認方向後，再正式加入 SPEC
- 觀察期間可記於 PR 描述或 commit message

---

## 好做法 vs 不好做法

### 好做法
```
User: "我想新增使用者可以匯出 CSV 的功能"

Claude:
我注意到這是一個新功能需求，先更新 SPEC.md：

SPEC.md 更新建議

**受影響的章節**：
1. Functional Requirements - 新增功能「Data Export」

**建議的更新內容**：
\`\`\`diff
+ ### Data Export
+ **Priority**: Medium
+ **Status**: Not Started
+
+ - **Description**: 允許使用者將資料匯出為 CSV 格式
+ - **User Needs**: 使用者需要在 Excel 中分析數據
+ - **Acceptance Criteria**:
+   - [ ] 支援匯出所有資料列
+   - [ ] CSV 格式符合 RFC 4180 標準
+   - [ ] 檔案名稱包含匯出時間戳
\`\`\`

是否確認新增這個功能到 SPEC？
```

### 不好做法
```
User: "我想新增使用者可以匯出 CSV 的功能"

Claude: 好的，我直接開始實作 CSV 匯出功能...
[沒有先確認需求細節，沒有更新 SPEC]
```
**為什麼不好**：規格脫離實作，下次對話時 Claude 不知道這個功能存在，也不知道驗收標準是什麼。

---

## 自我檢查清單

### 實作任何功能前
- [ ] 已讀取並理解專案的 SPEC.md
- [ ] 清楚這個任務對應 SPEC.md 的哪個 Functional Requirement
- [ ] 知道這個功能的驗收標準是什麼

### 實作過程中若發現
- [ ] 需求描述不明確 → 向 User 詢問並建議更新 SPEC
- [ ] 遇到技術限制 → 向 User 說明並建議調整 SPEC
- [ ] 需要新增功能 → 建議先更新 SPEC 再實作

### 完成功能後
- [ ] 確認所有驗收標準都已達成
- [ ] 建議更新功能 Status 為 `Completed`
- [ ] 如有新發現，建議補充 Technical Notes

---

## SPEC.md 格式（完整 template）

```markdown
# Project Specification

## Project Overview
[1-2 段話說明專案目的、背景和要解決的問題]

### In Scope
專案**會**處理的問題領域和核心範圍：
- [問題領域 1]
- [問題領域 2]

### Out of Scope
專案**不會**處理的功能或範圍（明確邊界）：
- [排除項目 1]
- [排除項目 2]

### Goals & Success Metrics
- **目標 1**: [可衡量的目標，例如：提升效能 50%]
- **目標 2**: [可衡量的目標]

---

## Technical Context

### Constraints
技術限制、平台限制、效能要求：
- [例如：必須支援 Python 3.11+]
- [例如：回應時間需在 200ms 內]

### Dependencies
外部系統、API、服務依賴：
- [例如：OpenAI API]
- [例如：PostgreSQL 14+]

### Assumptions
專案假設條件：
- [例如：使用者已有基本認證系統]

---

## Functional Requirements

### [功能名稱，例如：User Authentication]
**Priority**: `High` / `Medium` / `Low`
**Status**: `Not Started` / `In Progress` / `Completed`

- **Description**: [功能的詳細描述，說明做什麼]
- **User Needs**: [使用者為什麼需要這個功能，解決什麼痛點]
- **Acceptance Criteria**:
  - [ ] [驗收標準 1 - 具體可測試的標準]
  - [ ] [驗收標準 2]

**Technical Notes**:
- [實作上的技術考量或注意事項]

---

## Non-Functional Requirements

### Performance
- [效能需求，例如：API 回應時間 < 200ms]

### Security
- [安全需求，例如：所有敏感資料需加密]

### Reliability & Availability
- [可靠性需求，例如：系統可用性 99.9%]

### Scalability
- [擴展性需求]

### Maintainability
- [例如：程式碼覆蓋率 > 70%]

### Usability
- [使用者體驗需求]

---

## Open Questions
尚未解決或需進一步釐清的事項：
- [ ] [問題 1]
- [ ] [問題 2]

---

## Change Log
| Date       | Version | Changes                          |
|------------|---------|----------------------------------|
| YYYY-MM-DD | v1.0.0  | Initial specification            |
| YYYY-MM-DD | v1.1.0  | Added [feature/change]           |

---

**Last Updated**: YYYY-MM-DD
**Version**: v1.0.0
```
