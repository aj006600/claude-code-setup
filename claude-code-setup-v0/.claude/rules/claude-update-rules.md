# claude-update-rules.md

<!-- 
TODO: 
1. 還有SPEC更新時, 要判斷是否要修改CLAUDE.md的Project Overview, Tech Stack, Architecture 等
2. 新增修改CLAUDE-CHANGELOG.md的規則
-->
## 檢查 CLAUDE.md 是否需要更新
當 User 提出以下類型的需求時,應主動檢查本文件是否需要更新:

1. **新的開發規範或最佳實踐**
   - User 建議新的 coding convention
   - User 要求特定的開發流程
   - User 提出新的測試策略

2. **專案結構變更**
   - 需要新增或移除目錄
   - 模組組織方式調整
   - 新的技術堆疊加入

3. **工作流程調整**
   - Git workflow 變更
   - CI/CD 流程更新
   - 文檔更新流程變更

4. **專案特定需求**
   - User 的特殊開發習慣
   - 專案限制或約束

---

## CLAUDE.md 更新流程

### 1. 分析需求是否影響 CLAUDE.md
思考：這個需求是否需要更新開發規範？

### 2. 向 User 確認更新內容
```
CLAUDE: 我注意到這個需求可能需要更新 CLAUDE.md 的以下部分：
- [列出需要更新的章節]
- [說明更新的原因]

建議的更新內容：
- [具體的更新建議]

是否要進行這些更新？
```

### 3. User 確認後，更新 CLAUDE.md
```bash
git checkout -b docs/update-claude-md
git add CLAUDE.md
git commit -m "docs(claude): update development guidelines based on new requirements"
git push origin docs/update-claude-md
```

### 4. 告知 User 更新完成
```
CLAUDE: 已更新 CLAUDE.md，新增了以下內容：
- [更新摘要]

這些規範將應用於後續的開發工作。
```

---

##  CLAUDE.md 更新範例

**場景 1: User 要求特定的測試流程**
```
User: "之後每次改 code 都要先跑測試,通過了才能 commit"

Claude 分析: 這是測試流程的規範,需要更新 CLAUDE.md

Claude: "我建議在 CLAUDE.md 的 'Development Workflow' 章節新增:
'### Pre-commit 檢查
- 每次 commit 前必須執行: pytest tests/ -v
- 所有測試通過才能進行 commit
- 建議使用 pre-commit hook 自動化此流程'

是否要加入這個規範?"
```

**場景 2: User 要求特定的目錄結構**
```
User: "我們專案不需要 notebooks,把它從結構中移除"

Claude: "了解,我會更新 CLAUDE.md 的 'Project Structure' 章節,
移除 notebooks/ 目錄,並在說明中註記:
'本專案不使用 Jupyter Notebooks 進行實驗'

是否確認這個調整?"
```

**場景 3: User 要求新的 Git 規範**
```
User: "commit message 要包含 ticket number"

Claude: "我建議更新 'Git Commit Guidelines' 章節,
在 commit 格式中加入:
'<type>(<scope>): [TICKET-123] <subject>'

並在範例中說明:
'feat(agent): [PROJ-456] add new research agent'

是否要加入這個規範?"
```

---

**Last Updated**: 2026-01-13
**Version**: v1.0.0