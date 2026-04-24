# SPEC.md Template

本檔為 `maintaining-spec-md` skill 於 **Workflow A Step A3** 初次建立 `.claude/SPEC.md` 時使用的完整模板。

使用方式:Skill 在首次建立 SPEC.md 時讀取本檔並依下方結構填寫,將 `[...]`、`<...>` 等佔位符替換為 User 提供的實際資訊。

---

## 完整結構

```markdown
# Project Specification

## Project Overview
[1-2 段話說明專案目的、背景和要解決的問題]

### In Scope
專案**會**處理的問題領域和核心範圍:
- [問題領域 1]
- [問題領域 2]

### Out of Scope
專案**不會**處理的功能或範圍(明確邊界):
- [排除項目 1]
- [排除項目 2]

### Goals & Success Metrics
- **目標 1**: [可衡量的目標,例如:提升效能 50%]
- **目標 2**: [可衡量的目標]

---

## Technical Context

### Constraints
技術限制、平台限制、效能要求:
- [例如:必須支援 Python 3.11+]
- [例如:回應時間需在 200ms 內]

### Dependencies
外部系統、API、服務依賴:
- [例如:OpenAI API]
- [例如:PostgreSQL 14+]

### Assumptions
專案假設條件:
- [例如:使用者已有基本認證系統]

---

## Functional Requirements

### [功能名稱,例如:User Authentication]
**Priority**: `High` / `Medium` / `Low`
**Status**: `Not Started` / `In Progress` / `Completed`

- **Description**: [功能的詳細描述,說明做什麼]
- **User Needs**: [使用者為什麼需要這個功能,解決什麼痛點]
- **Acceptance Criteria**:
  - [ ] [驗收標準 1 - 具體可測試的標準]
  - [ ] [驗收標準 2]

**Technical Notes**:
- [實作上的技術考量或注意事項]

---

## Non-Functional Requirements

### Performance
- [效能需求,例如:API 回應時間 < 200ms]

### Security
- [安全需求,例如:所有敏感資料需加密]

### Reliability & Availability
- [可靠性需求,例如:系統可用性 99.9%]

### Scalability
- [擴展性需求]

### Maintainability
- [例如:程式碼覆蓋率 > 70%]

### Usability
- [使用者體驗需求]

---

## Open Questions
尚未解決或需進一步釐清的事項:
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
