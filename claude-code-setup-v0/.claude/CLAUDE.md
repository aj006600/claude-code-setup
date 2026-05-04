# CLAUDE.md

## Project Overview (專案概述)
**核心原則**：CLAUDE CODE 需查看並遵循 `.claude/SPEC.md` 進行動態調整。

---

## Tech Stack (技術堆疊)
**核心原則**：CLAUDE CODE 需根據專案需求自行動態擴充或調整。

- **Language**: Python 3.11+
- **Package Manager**: uv

---

## Architecture (專案架構)
**核心原則**：功能模組化、漸進式建立、靈活調整。CLAUDE CODE 需依專案更動自行修改、擴展。

採用分層架構：

```
```

---

## Development Workflow (開發流程)
**核心原則**：CLAUDE CODE 需查看並遵循 `.claude/rules/development-workflow-details.md` 流程進行 TDD 開發。注意**開發/修改代碼時**請使用 **superpowers:executing-plans**。

### 1. 需求確認
User 提出需求 → 撰寫/更新 SPEC.md → User 確認 → 開始開發

### 2. 開發（TDD）
建立功能分支 → 撰寫測試 → 實作功能 → 測試通過 → 更新 SPEC.md 狀態

### 3. 提交與 PR
code-simplifier 審查 → 提交變更 → 推送分支 → 在 Github 建立 PR

### 4. Review 與 Merge
Code review → 更新 README.md 及相關文檔 → 合併 → 刪除分支

---

## Coding Conventions (編碼規範)
**核心原則**：遵循命名規範、模組化設計、SOLID 原則。

### Naming
- **Classes**: `PascalCase`
- **Functions/Methods**: `snake_case`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private**: 前綴 `_`

### Modular Design
- **Single Responsibility**: 每個檔案專注於一個功能
- **Loose Coupling**: 模組間通過清晰的介面通訊
- **High Cohesion**: 相關功能放在同一個模組
- **Testability**: 避免全域狀態，方便 mock

### SOLID
- **S - Single Responsibility**: 一個類別只負責一件事
- **O - Open/Closed**: 對擴展開放，對修改封閉
- **L - Liskov Substitution**: 子類別可替換父類別
- **I - Interface Segregation**: 多個專用介面優於通用介面
- **D - Dependency Inversion**: 依賴抽象而非具體實作

---

## Testing Protocols (測試規範)
**核心原則**：**每次只要有任何程式碼改動時**都必須遵循 TDD，先寫測試再實作，並且確保不破壞現有功能。CLAUDE CODE 需查看並遵循 `.claude/rules/testing-rules.md` 進行測試編寫。

### TDD Flow
撰寫測試 → 執行測試（失敗）→ 實作功能 → 執行測試（通過）→ 重構（如需要）→ 執行所有測試（確保無 regression）

### Strategy
- **Unit Test**: 核心功能必須有單元測試
- **Integration Test**: 視需求添加整合測試
- **Coverage**: 目標 70%+

---

## Development Checklist (CLAUDE CODE 開發確認清單)
**核心原則**：CLAUDE CODE 進行開發時必須遵循此清單，並且再每一步驟完成後標記[x]確保是以`.claude/rules/development-workflow-details.md` 的流程進行 TDD 開發以維持品質。

### 開發前
- [ ] 確認 SPEC.md 是否需要更新
  - CLAUDE CODE 需查看並遵循 `.claude/rules/spec-update-rules.md` 流程
- [ ] 檢查當前 git 狀態: `git status`
- [ ] 確認所有測試通過: `uv run pytest tests/ -v`
- [ ] 建立功能分支: `git checkout -b feat/<feature-name>`
  - CLAUDE CODE 需查看並遵從 ```.claude/rules/git-rules.md``` 的 "分支命名規範" 章節

### 開發中
- [ ] 先撰寫測試（TDD）
- [ ] 實作功能
  - 如遇任何問題可透過使用 context7 mcp、github mcp 搜尋技術文檔以及業界最佳實踐的範例來輔助進行開發
- [ ] 執行相關測試確認通過
- [ ] 執行所有測試確認無 regression: `uv run pytest tests/ -v`
- [ ] 檢查測試覆蓋率: `uv run pytest tests/ --cov=src --cov-report=term-missing`
- [ ] 更新 SPEC.md 功能狀態（標記驗收標準完成）

### 提交與 PR
- [ ] 審查和優化代碼 (使用 code-simplifier plugin)
  - 若有修改代碼，須遵循 TDD：更新測試 → 修改代碼 → 執行相關測試確認通過 → 執行所有測試確認無 regression
- [ ] 提交變更並建立 PR 到 `dev`

### Review 與 Merge
- [ ] Code review（使用 code-reviewer agent）
  - 若未通過，回到「開發中」階段遵循流程規範進行修改
- [ ] Review 通過後，更新文檔（README.md, docs/）
  - CLAUDE CODE 需查看並遵從 ```.claude/rules/readme-update-rules.md``` 的 "檢查 README.md 是否需要更新"、"README.md 更新流程" 章節
- [ ] 合併並刪除功能分支

---

**Last Updated**: YYYY-MM-DD
**Version**: v1.0.0
