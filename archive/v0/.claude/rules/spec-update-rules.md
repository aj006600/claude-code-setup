# SPEC.md 撰寫與動態更新指引

> **目標**: **這是給 Claude Code 的規則與指引**，讓 Claude Code 理解如何撰寫和維護專案規格文件。
>
> **檔案位置**:
> - 本指引：`.claude/rules/spec-update-rules.md`
> - 專案規格：`.claude/SPEC.md`

---

## 與其他 Claude 規則的整合

**規則層次**：
- 全域規則（`~/.claude/CLAUDE.md`）→ 專案規範（`.claude/CLAUDE.md`）→ SPEC 規則（本檔案）

**開發流程**：
1. 專案啟動：閱讀 CLAUDE.md 和 SPEC.md
2. 開發過程：按 SPEC.md 實作，遵循 CLAUDE.md 原則
3. 功能完成：確認驗收標準，更新 SPEC.md 狀態

### 優先順序原則
1. **先閱讀並遵循 SPEC.md 的需求**（這是需求的唯一真實來源）
2. **按照 CLAUDE.md 的開發流程實作**（TDD、測試優先、避免過度設計）
3. **當發現需求變更時，回到本指引更新 SPEC.md**（保持需求與實作同步）

---

## 何時檢查並更新 SPEC.md

必須檢查 SPEC.md 的情況：
1. **User 提出新需求或變更**
  - 新功能請求（新增 Functional Requirement）
  - 現有功能變更（修改 Description、Acceptance Criteria）
2. **實作過程中發現技術限制**
  - 遇到技術限制，導致需求需要調整（新增/修改 Functional Requirement、Description、Acceptance Criteria）
  - 發現原需求描述不明確，需要補充細節（更新 Description）
3. **程式碼改動影響規格**（API、資料模型、架構變更）
  - API 介面簽名變更（endpoints、參數、回傳值）
  - 資料模型結構調整（schema、欄位、關聯）
  - 系統架構變更（模組拆分、服務邊界調整）
4. **功能狀態更新**（開發完成、驗收標準達成）
  - 功能開發完成（更新 Status 從 `In Progress` → `Completed`）
  - 驗收標準達成（勾選 Acceptance Criteria 的 checkbox）
5. **Bug 揭示需求理解錯誤**
  - Bug 揭示了原需求理解錯誤（更新 Description 或 Acceptance Criteria）
  - 需要新增邊界條件或錯誤處理需求（補充 Technical Notes）

---

## SPEC.md 更新流程

### 初次建立 SPEC.md
1. 檢查專案是否已有 SPEC.md
2. 向 User 收集需求（專案目的、核心功能、技術環境）
3. 草擬初始 SPEC.md（使用底部的指定格式）
4. 向 User 展示並確認
5. 建立 SPEC.md 檔案（版本 v1.0.0）

### 更新現有 SPEC.md
#### Step 1: 識別變更觸發點
當遇到上述任一情況時，**暫停實作**並進入 SPEC 評估模式。

**自我檢查清單**：
- [ ] 這個變更是新需求、需求修改、還是實作細節？
- [ ] 影響 SPEC.md 的哪些章節？（Overview / Functional...）
- [ ] 是否需要調整驗收標準或優先級？

---

#### Step 2: 分析影響範圍並草擬更新

**建議格式化輸出給 User**：

    **SPEC.md 更新建議**

    我注意到以下變更需要同步更新 SPEC.md：

    **變更原因**：
    [說明為什麼需要更新，例如：「User 提出新功能需求」或「實作中發現技術限制」]

    **受影響的章節**：
    1. [章節名稱，例如：Functional Requirements > User Authentication]
       - 影響：[具體說明，例如：「需要新增 OAuth 2.0 支援」]

    **建議的更新內容**：
    ```diff
    ## Functional Requirements

    ### User Authentication
    + **Status**: In Progress (原為 Not Started)

    - **Description**: [舊描述]
    + **Description**: [新描述，包含 OAuth 2.0 支援]

    - **Acceptance Criteria**:
      - [ ] 支援 email/password 登入
    +  - [ ] 支援 Google OAuth 2.0 登入
    +  - [ ] 支援 GitHub OAuth 2.0 登入
    ```

    是否確認這些變更？

---

#### Step 3: 等待 User 確認

**重要原則**：
- **必須**先展示 diff 並取得同意
- 如果 User 有其他意見，根據回饋調整更新內容

---

#### Step 4: 執行 SPEC.md 更新

User 確認後，執行以下操作：

1. **更新相應章節內容**
   - 使用 Edit 工具修改 SPEC.md
   - 確保格式一致（遵循模板結構）

2. **同步更新版本資訊**
   - 更新 **Change Log** 表格（新增一行記錄）
   - 更新底部的 **Last Updated** 日期
   - 根據變更類型決定版本號（採用 Semantic Versioning）：
     - 重大變更 → +1.0.0
     - 新功能 → +0.1.0
     - 修改細節 → +0.1.0
     - 文字修正 → +0.0.1

**版本更新範例**：
```markdown
## Change Log
| Date       | Version | Changes                                    |
|------------|---------|---------------------------------------------|
| 2025-01-10 | v1.0.0  | Initial specification                      |
| 2025-01-15 | v1.1.0  | Added OAuth 2.0 support to authentication  |

---

**Last Updated**: 2025-01-15
**Version**: v1.1.0
```

---

#### Step 5: 向 User 確認更新結果

**建議格式化輸出**：

    **SPEC.md 已更新**

    **更新摘要**：
    - 新增功能：User Authentication 支援 OAuth 2.0

    **版本資訊**：
    - 版本：v1.0.0 → v1.1.0
    - 更新日期：2025-01-15

    請確認更新內容是否符合您的需求。如需調整，請告訴我。

---

## 特殊情況處理

### 情況 1: 多個小變更累積
如果有多個小變更（例如：修正錯字、調整格式），可以合併為單次更新：
- 一次性展示所有 diff
- 版本號僅增加一次
- Change Log 中可以用一行記錄多個變更

### 情況 2: 緊急 Bug 修復
如果是緊急 Bug 修復且不影響需求理解：
- 可以先修復 Bug，完成後再評估是否需要更新 SPEC
- 如果 Bug 揭示需求錯誤，必須更新 SPEC

### 情況 3: 實驗性功能
如果是實驗性功能（Prototype）：
- 不需要立即更新 SPEC.md
- 等實驗確認方向後，再正式加入 SPEC

---

## 自我檢查清單（給 Claude Code）

在實作任何功能前，確認：
- [ ] 我已讀取並理解專案的 SPEC.md
- [ ] 我清楚這個任務對應 SPEC.md 的哪個 Functional Requirement
- [ ] 我知道這個功能的驗收標準是什麼

在實作過程中，如果發現：
- [ ] 需求描述不明確 → 向 User 詢問並建議更新 SPEC
- [ ] 遇到技術限制 → 向 User 說明並建議調整 SPEC
- [ ] 需要新增功能 → 建議先更新 SPEC 再實作

在完成功能後：
- [ ] 確認所有驗收標準都已達成
- [ ] 建議更新功能 Status 為 `Completed`
- [ ] 如有新發現，建議補充 Technical Notes

---

## 成功範例

### 好的做法

    User: "我想新增使用者可以匯出 CSV 的功能"

    Claude:
    我注意到這是一個新功能需求，建議先更新 SPEC.md：

    **SPEC.md 更新建議**

    **受影響的章節**：
    1. Functional Requirements - 新增功能「Data Export」

    **建議的更新內容**：
    ```diff
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
    ```

    是否確認新增這個功能到 SPEC？

---

## SPEC.md 的指定格式

```markdown
# Project Specification

## Project Overview
[專案簡介]

## Functional Requirements
### Feature 1: [功能名稱]
**Priority**: `High` / `Medium` / `Low`
**Status**: `Not Started` / `In Progress` / `Completed`

- Description: [功能描述]
- User Needs: [使用者提出的需求]
- Acceptance Criteria:
  - [ ] [驗收標準 1]
  - [ ] [驗收標準 2]
  - [ ] [...]

### Feature 2: [功能名稱]
**Priority**: `High` / `Medium` / `Low`
**Status**: `Not Started` / `In Progress` / `Completed`

- Description: [功能描述]
- User Needs: [使用者提出的需求]
- Acceptance Criteria:
  - [ ] [驗收標準 1]
  - [ ] [驗收標準 2]
  - [ ] [...]

---

## Change Log
| Date       | Version | Changes                          |
|------------|---------|----------------------------------|
| YYYY-MM-DD | v1.0.0  | Initial specification            |
| YYYY-MM-DD | v1.1.0  | Added [feature/change]           |

---

Last Updated: [日期]
Version: [版本]
```
