<!-- TEMPLATE NOTICE
本檔案是 claude-code-setup-v1 template 的一部分。
採用到新專案時,由 maintaining-spec-md skill 的 Workflow A 透過需求對話填入:替換所有 `<...>` / `[...]` 佔位符、移除本 NOTICE 區塊、把 footer 版本設為 v1.0.0。
完整使用說明見 template 根目錄的 `README.md`。
-->

# Project Specification

SPEC.md 描述「專案**是**什麼」的靜態契約(需求 + 驗收);「做到哪了」由 git branch / PR merge 反映,SPEC 不追蹤進度。技術選型 / 架構 / 目錄屬 `.claude/docs/architecture.md`(由 `maintaining-architecture-md` 維護),**不寫在此**,避免規範鏈職責重疊。

## Project Overview

<!-- TEMPLATE: 1-2 段說明專案目的、背景與要解決的問題 -->
`<One or two paragraphs: 專案目的、背景、要解決的問題、目標使用者>`

### Out of Scope

專案**不會**處理的功能或範圍(明確邊界):

- `<排除項目 1,例如:不處理批次匯入>`
- `<排除項目 2,例如:不支援多語系>`

---

## Functional Requirements

<!-- TEMPLATE: 每個功能一個 ### 區塊,至少 2-3 個。未確定處標 [NEEDS CLARIFICATION: <具體問題>],勿靜默假設。 -->

### `<功能名稱,例如:User Authentication>`

- **Description**: `<功能做什麼>`
- **User Needs**: `<使用者為何需要、解決什麼痛點>`
- **Acceptance Criteria**:
  - [ ] `<具體可測試的驗收標準>`
  - [ ] `<...>`

**Technical Notes**(選配):
- `<實作上的技術考量或注意事項>`

---

## Success Criteria

專案 / 產品**層級**的可量化成功指標(回答「整體做成什麼樣算成功」),與單一功能的 Acceptance Criteria 不同層級。每條須**可量化**(有閾值或 yes/no)且 **technology-agnostic**(描述使用者 / 業務結果,不綁實作技術)。

- **SC-001**: `<可量化結果,例如「user 能在 2 分鐘內完成註冊」>`
- **SC-002**: `<可量化結果,例如「主要任務首次成功率 ≥ 90%」>`

反模式:`「系統應正確運作」`、`「速度要快」`——無閾值、不可測,不可寫。

---

## Change Log

| Date           | Version | Changes               |
|----------------|---------|-----------------------|
| `<YYYY-MM-DD>` | v1.0.0  | Initial specification |

---

**Last Updated**: `<YYYY-MM-DD>`
**Version**: `<vX.Y.Z>`(由 maintaining-spec-md Workflow A 首次填入;預設 v1.0.0)
