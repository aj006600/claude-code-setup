# development-workflow-details.md

> ⚠️ **本規則已遷移至 skill**
>
> 本檔案原有的詳細 TDD 開發流程（需求確認、開發、提交與 PR、Review 與 Merge 四階段）已完整遷移至：
>
> **`.claude/skills/tdd-feature-workflow/SKILL.md`**

---

## 如何使用新版本

當 Claude Code 遇到以下情境時，會自動透過 skill 的 description 觸發 `tdd-feature-workflow` skill 並依其 workflow 執行：

- User 提出新功能 / bug 修復 / refactor 需求
- User 說要「開始實作」、「繼續」某功能
- User 要完成某功能並推進 PR
- 功能開發的任一階段都可主動啟用本 skill

若需手動啟用 skill，使用 Skill tool：

```
skill: "tdd-feature-workflow"
```

---

## 相關 commands

新版 workflow 搭配以下 commands 使用：

- `/pre-dev-check` — 開發前檢查（git 狀態、測試基線、SPEC.md）
- `/pre-pr-check` — PR 前完整檢查（跑測試、coverage、code-simplifier、SPEC / README hints）
- `/project-status` — 快速狀態快照
- `/agent-cheatsheet` — 可用 agents / skills / commands / MCPs 速查

---

## 為何遷移？

Skill 相比純 markdown rule 提供：
- **更可靠的觸發機制**：description 是 AI 觸發關鍵，任何與「開始實作」相關的對話都會主動啟用
- **更清楚的編排**：skill 明確委派給 superpowers skills、agents、commands，不依賴 AI 臨場判斷
- **更好的跨 skill 協作**：自動在關鍵節點 hook `maintaining-spec-md`、`maintaining-claude-md`、`maintaining-readme-md`
- **專案專屬細節內建**：uv 指令、pytest 配置、專案架構考量隨 skill 載入

---

**Status**: Migrated (deprecated)
**Migrated To**: `.claude/skills/tdd-feature-workflow/SKILL.md`
**Migration Date**: 2026-04-23
