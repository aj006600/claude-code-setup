# readme-update-rules.md

## 檢查 README.md 是否需要更新

PR Review 通過後，在 merge 前檢查以下文檔是否需要更新：

1. **README.md** - 當以下情況發生時更新：
   - 有新增功能
   - 使用方式改變
   - 安裝步驟變更
   - API 介面變更
   - 新增依賴或環境需求

2. **docs/** - 當以下情況發生時更新：
   - 新增功能需要詳細說明
   - 架構變更
   - API 文檔需要更新
   - 新增使用範例

> CLAUDE CODE 需查看 `.claude/SPEC.md` 的 Project Overview 確認專案架構、技術框架、功能是否有變更。

---

## README.md 更新流程

### 1. 分析本次 PR 的變更內容
思考：這個變更是否影響使用者？是否需要更新文檔？

### 2. 更新文檔
- **每個章節的標題使用英文，內容以繁體中文為主，技術術語請使用英文** 
- 識別需要文檔更新的部分
- 更新 README.md 的相關章節
- 新增或更新 docs/ 下的技術文檔

### 3. 將文檔更新加入同一個 PR
```bash
git add README.md docs/
git commit -m "docs: update documentation for <feature>
git push origin <branch-name>
```

### 4. 確認 PR 包含文檔更新後，再進行 merge

---

## README.md 更新範例

**場景 1: 新增功能影響使用方式**
```
User 新增了 CSV 匯出功能

Claude 分析: 這是新功能，需要更新 README.md 的 Features 和 Usage 章節

Claude: "我建議更新 README.md：
- 在 Features 章節新增：'CSV 匯出功能'
- 在 Usage 章節新增使用範例

是否要進行這些更新？"
```

**場景 2: API 介面變更**
```
User 修改了 API endpoint 的參數

Claude 分析: API 變更會影響使用者，需要更新文檔

Claude: "我建議更新 README.md 的 API Reference 章節，
並同步更新 docs/api.md 的詳細說明。

是否確認這個調整？"
```

---

**Last Updated**: 2026-01-14
