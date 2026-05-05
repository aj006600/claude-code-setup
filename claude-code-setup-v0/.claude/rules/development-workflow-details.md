# development-workflow-details.md

## Development Workflow Details (詳細開發流程)

### 1. 需求確認階段
1. User 提出需求
2. Claude Code 依照 `.claude/rules/spec-update-rules.md` 撰寫/更新 SPEC.md
3. Claude Code 向 User 展示 SPEC.md diff 並確認
4. User 確認後才開始開發

### 2. 開發階段（TDD）
1. 從 dev 分支建立功能分支 
   ```bash
   git checkout dev && git pull origin dev
   git checkout -b feat/<feature-name> # CLAUDE CODE 需查看並遵從 ```.claude/rules/git-rules.md``` 的分支命名規範章節
   ```

2. 撰寫測試 (Test-First)
   - 撰寫單元測試 tests/unit/<module>/test_<feature>.py
   - 撰寫整合測試 tests/integration/test_<feature>_integration.py

3. 執行測試 (應該失敗，因為功能還沒實作)
   ```bash
   uv run pytest tests/unit/<module>/test_<feature>.py -v
   ```

4. 實作功能，撰寫 src/<module>/<feature>.py
   - 開發、修改代碼時請使用 **superpowers:executing-plans**
   - 如遇任何問題可透過使用 context7 mcp、github mcp 搜尋技術文檔以及業界最佳實踐的範例來輔助進行開發

5. 執行測試直到通過
   ```bash
   uv run pytest tests/unit/<module>/test_<feature>.py -v
   uv run pytest tests/integration/test_<feature>_integration.py
   ```

6. 執行所有測試確保無 regression
   ```bash
   uv run pytest tests/ -v
   ```

7. 檢查測試覆蓋率
   ```bash
   uv run pytest tests/ --cov=src --cov-report=term-missing
   ```
8. 更新 SPEC.md 功能狀態（標記驗收標準完成）

### 3. 提交與 PR 階段
1. 使用 **code-simplifier** 審查和優化代碼（針對本次修改的檔案）
   - 若有修改代碼，須遵循 TDD：更新測試 → 修改代碼 → 執行相關測試確認通過 → 執行所有測試確認無 regression

2. 提交變更
   ```bash
   git add .
   git commit -m "<type>(<scope>): <description>
   ```

3. 推送功能分支
   ```bash
   git push origin feat/<feature-name>
   ```

4. 建立 PR 到 dev（使用 gh CLI）
   ```bash
   gh pr create --base dev --title "<type>(<scope>): <description>" --body "## Summary
   [變更摘要]

   ## Changes
   - [變更項目列表 1]
   - [變更項目列表 2]
   - [...]"
   ```

### 4. Review 與 Merge 階段
1. PR Review（使用 **superpowers:code-reviewer**）
   - 若未通過，回到「開發階段」遵循流程規範進行修改

2. Review 通過後，更新文檔
   - 更新 README.md（如有必要）
   - 更新 docs/（如有必要）
   - 將文檔更新加入同一個 PR

3. 合併到 dev
   ```bash
   gh pr merge --squash
   ```

4. 刪除功能分支
   ```bash
   git checkout dev && git pull origin dev
   git branch -d feat/<feature-name>
   git push origin --delete feat/<feature-name>
   ```

---

**Last Updated**: 2026-01-14
