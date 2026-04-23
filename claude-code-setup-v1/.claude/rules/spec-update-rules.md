# spec-update-rules.md

> **本規則已遷移至 skill**
>
> 本檔案原有的工作流程（何時更新、如何撰寫、初次建立 SPEC.md、版本管理、Change Log 維護等）已完整遷移至：
>
> **`.claude/skills/maintaining-spec-md/SKILL.md`**

---

## 如何使用新版本

當 Claude Code 遇到以下情境時，會自動透過 skill 的 description 觸發 `maintaining-spec-md` skill 並依其 workflow 執行：

- User 提出新需求、修改既有功能、調整 scope 或 acceptance criteria
- 實作過程中發現技術限制影響需求
- API 簽名 / 資料模型 / 架構變更
- 功能完成狀態需更新
- Bug 修復揭示需求理解錯誤
- 專案尚無 SPEC.md 需初次建立

若需手動啟用 skill，使用 Skill tool：

```
skill: "maintaining-spec-md"
```

---

## 為何遷移？

Skill 相比純 markdown rule 提供：
- **更可靠的觸發機制**：description 是 AI 觸發關鍵，比被動等待 AI 讀取 rule 更主動
- **更清楚的 workflow 結構**：多步驟 workflow A/B 更容易遵循
- **更好的跨 skill 協作**：SPEC → CLAUDE → README 形成規範同步鏈
- **領域知識內建**：Semantic Versioning、Keep a Changelog 等最佳實踐隨 skill 一併載入

---

**Status**: Migrated (deprecated)
**Migrated To**: `.claude/skills/maintaining-spec-md/SKILL.md`
**Migration Date**: 2026-04-23
