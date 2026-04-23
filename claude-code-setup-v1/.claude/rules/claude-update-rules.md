# claude-update-rules.md

> **本規則已遷移至 skill**
>
> 本檔案原有的工作流程（何時更新、如何更新、分支策略、Semantic Versioning、CLAUDE-CHANGELOG.md 維護等）已完整遷移至：
>
> **`.claude/skills/maintaining-claude-md/SKILL.md`**

---

## 如何使用新版本

當 Claude Code 遇到以下情境時，會自動透過 skill 的 description 觸發 `maintaining-claude-md` skill 並依其 workflow 執行：

- User 提出新的 coding convention、開發規範或最佳實踐
- 專案結構變更（新增 / 移除目錄、模組組織調整）
- Workflow 調整（Git flow、CI/CD、文檔流程）
- Testing strategy 變更
- SPEC.md 的 Project Overview / Tech Stack / Architecture 連動變更
- 新增技術依賴或專案特定約束

若需手動啟用 skill，使用 Skill tool：

```
skill: "maintaining-claude-md"
```

---

## 為何遷移？

Skill 相比純 markdown rule 提供：
- **更可靠的觸發機制**：description 是 AI 觸發關鍵，比被動等待 AI 讀取 rule 更主動
- **更清楚的 workflow 結構**：含分支判斷邏輯、兩檔同步 commit 流程
- **更好的跨 skill 協作**：與 `maintaining-spec-md`、`maintaining-readme-md` 形成規範同步鏈
- **領域知識內建**：Keep a Changelog 格式、Semantic Versioning 規則隨 skill 載入

---

**Status**: Migrated (deprecated)
**Migrated To**: `.claude/skills/maintaining-claude-md/SKILL.md`
**Migration Date**: 2026-04-23
