# SPEC.md Template

本檔為 `maintaining-spec-md` skill 於 **Workflow A Step A3** 初次建立 `.claude/SPEC.md` 時使用的完整模板。

使用方式:Skill 在首次建立 SPEC.md 時讀取本檔並依下方結構填寫,將 `[...]`、`<...>` 等佔位符替換為 User 提供的實際資訊。

SPEC.md 描述「專案**是**什麼」的靜態契約;「做到哪了」由 git branch / PR merge 反映,SPEC 不追蹤進度。

---

## 完整結構

```markdown
# Project Specification

## Project Overview
[1-2 段話說明專案目的、背景和要解決的問題]

### Out of Scope
專案**不會**處理的功能或範圍(明確邊界):
- [排除項目 1]
- [排除項目 2]

---

## Functional Requirements

### [功能名稱,例如:User Authentication]

- **Description**: [功能的詳細描述,說明做什麼]
- **User Needs**: [使用者為什麼需要這個功能,解決什麼痛點]
- **Acceptance Criteria**:
  - [ ] [驗收標準 1 - 具體可測試的標準]
  - [ ] [驗收標準 2]

**Technical Notes**(選配):
- [實作上的技術考量或注意事項]

---

## Success Criteria

專案 / 產品**層級**的可量化成功指標(回答「整體做成什麼樣算成功」),與單一功能的 Acceptance Criteria 不同層級。每條須**可量化**(有閾值或 yes/no)且 **technology-agnostic**(描述使用者 / 業務結果,不綁實作技術)。

- **SC-001**: [可量化結果,例如「user 能在 2 分鐘內完成註冊」]
- **SC-002**: [可量化結果,例如「主要任務首次成功率 ≥ 90%」]

反模式:`「系統應正確運作」`、`「速度要快」`——無閾值、不可測,不可寫。

---

## Change Log
| Date       | Version | Changes                          |
|------------|---------|----------------------------------|
| YYYY-MM-DD | v1.0.0  | Initial specification            |

---

**Last Updated**: YYYY-MM-DD
**Version**: v1.0.0
```

### 未確定項目用 `[NEEDS CLARIFICATION]` 標記

草擬或更新 SPEC 時,尚未確定的細節一律標 `[NEEDS CLARIFICATION: <具體問題>]`,而非靜默假設一個值。範例:

```markdown
- **Acceptance Criteria**:
  - [ ] 支援匯出格式 [NEEDS CLARIFICATION: CSV / Excel / 兩者皆要?]
```

這些標記是 `/pre-pr-check` 一致性檢查的掃描對象——殘留未解會被提示,確保需求在實作前收斂。

> 技術選型(語言版本、外部依賴、技術限制、架構)屬 `.claude/docs/architecture.md` 的 Tech Stack / Code Structure 範疇,**不寫在 SPEC.md**——避免規範鏈職責重疊。SPEC 建立後若需記錄技術上下文,啟用 `maintaining-architecture-md` skill 處理。
