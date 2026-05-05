# Git Rules (Git 規範)

## Branch Strategy
```
main (production) ← hotfix/* (緊急修復)
  ↑
qas (testing)
  ↑
dev (development) ← feat/<feature-name>
                  ← fix/<bug-name>
                  ← docs/<doc-name>
                  ← refactor/<scope>
```

### 分支命名規範

| 分支類型 | 命名格式 | 範例 |
|----------|----------|------|
| 功能開發 | `feat/<feature-name>` | `feat/user-authentication` |
| Bug 修復 | `fix/<bug-name>` | `fix/login-timeout` |
| 緊急修復 | `hotfix/<bug-name>` | `hotfix/security-patch` |
| 文檔更新 | `docs/<doc-name>` | `docs/api-reference` |
| 重構 | `refactor/<scope>` | `refactor/database-layer` |

---

## Commit Convention

### 格式
```
<type>(<scope>): <description>
```

### Type 類型

| Type | 說明 | 範例 |
|------|------|------|
| `feat` | 新功能 | `feat(user): add login` |
| `fix` | Bug 修復 | `fix(auth): token expired` |
| `refactor` | 重構 | `refactor(api): simplify routes` |
| `test` | 測試相關 | `test(user): add unit tests` |
| `docs` | 文檔更新 | `docs: update README` |
| `perf` | 性能優化 | `perf(db): add index` |
| `chore` | 雜項 | `chore: update deps` |
| `spec` | SPEC.md 變更 | `spec: add new requirements` |

### 範例
```bash
# 功能開發
git commit -m "feat(user): add registration"

# Bug 修復
git commit -m "fix(auth): handle expired token"

# 測試與文檔
git commit -m "test(user): add login tests"
git commit -m "docs: update API examples"

# 重構與優化
git commit -m "refactor(db): extract query builder"
git commit -m "perf(search): add caching"
```

---

## 最佳實踐

- 每個 commit 是一個**邏輯完整**的改動
- Message 清楚描述「做了什麼」
- 避免一個 commit 包含多個不相關的改動
- SPEC.md 變更應**獨立**成一個 commit
- 提交前使用 `code-simplifier` agent 審查和優化代碼
  - 若有修改代碼，須遵循 TDD：更新測試 → 修改代碼 → 執行相關測試確認通過 → 執行所有測試確認無 regression

---

**Last Updated**: 2026-01-14
