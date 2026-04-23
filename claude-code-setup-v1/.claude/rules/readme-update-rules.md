# readme-update-rules.md

> ⚠️ **本規則已遷移至 skill**
>
> 本檔案原有的工作流程（何時更新、如何更新、docs/ 同步、documentation-engineer agent 協作等）已完整遷移至：
>
> **`.claude/skills/maintaining-readme-md/SKILL.md`**

---

## 如何使用新版本

當 Claude Code 遇到以下情境時，會自動透過 skill 的 description 觸發 `maintaining-readme-md` skill 並依其 workflow 執行：

- 新增功能（影響 Features 清單、Usage 範例）
- API endpoint / 參數 / 回傳值變更
- CLI 介面變更
- 安裝步驟變更、新增依賴、新的環境變數
- 架構變更（影響 User 理解或使用方式）
- 設定選項變更
- SPEC.md Project Overview / CLAUDE.md Tech Stack 的連動變更

新版 skill 採「廣觸發 + 智慧延後」設計：
- description 偵測範圍廣、觸發率高
- Skill body 判斷當前實作狀態（A 實作中 / B 完成未 PR / C PR 中 / D 已 merge），選擇對應執行時機
- 避免在 TDD 中途干擾，也避免文檔遺忘補上

若需手動啟用 skill，使用 Skill tool：

```
skill: "maintaining-readme-md"
```

---

## 為何遷移？

Skill 相比純 markdown rule 提供：
- **更可靠的觸發機制**：description 是 AI 觸發關鍵，比被動等待 AI 讀取 rule 更主動
- **智慧延後邏輯**：依實作狀態決定執行時機，原 rule 只有「pre-merge」單一觸發點
- **明確委派 agent**：與 `documentation-engineer` agent 的協作模式明確寫入 workflow
- **更好的跨 skill 協作**：與 `maintaining-spec-md`、`maintaining-claude-md` 形成規範同步鏈

---

**Status**: Migrated (deprecated)
**Migrated To**: `.claude/skills/maintaining-readme-md/SKILL.md`
**Migration Date**: 2026-04-23
