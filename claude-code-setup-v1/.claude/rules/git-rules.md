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
| SPEC 變更 | `spec/<topic>` | `spec/add-rate-limit-requirement` |

---

## Commit Convention

### 格式
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

遵循 [Conventional Commits 1.0.0](https://www.conventionalcommits.org/)。

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

### 常用 scope 約定

| Scope | 用途 | 由誰約定 |
|-------|------|---------|
| `(template)` | 採用 template 後的初次客製化、template 本體層級的調整 | `maintaining-claude-md` Workflow A |
| `(claude)` | `.claude/CLAUDE.md` 規範變更 | `maintaining-claude-md` Workflow B |
| `(spec)` | `.claude/SPEC.md` 變更(亦可直接用 `spec` type) | `maintaining-spec-md` |
| `(readme)` | `README.md` 與 `docs/` 內容變更 | `maintaining-readme-md` |
| `(<module>)` | 一般功能 / 修復 / 重構針對特定模組 | 開發者依模組命名 |

scope 只是輔助分類,Conventional Commits 允許自定 scope;以上是本 setup 跨 skill 對齊的命名,避免 git log 出現 `chore(template)` 與 `chore(setup)` 混用。

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

- 每個 commit 為**邏輯完整**的單一改動，不混入多個不相關變更
- SPEC.md / CLAUDE.md / 文檔規範變更**獨立成一個 commit**，與功能 commit 分離（避免 git log 分不清「動了功能 + 規範」還是「只動功能」）

---

## Cross-repo 引用安全格式

避免在 commit message 或 PR / issue body 裡直接寫 `owner/repo#N`、`https://github.com/owner/repo/issues/N`、`https://github.com/owner/repo/pull/N` 指向**其他 repo**：GitHub 會自動在該外部 issue 建立 "mentioned in ..." backlink，通知對方 watcher 並把本專案的內容推播過去——一旦發生即不可逆（即使事後 edit message / body 移除引用，通知已送達）。

### 安全寫法

| 情境 | 不安全 | 安全 |
|------|--------|------|
| Commit message | `related to foo/bar#123` | `` related to `foo/bar#123` `` |
| PR body 引用外部 issue | `see https://github.com/foo/bar/issues/42` | `` see `https://github.com/foo/bar/issues/42` `` |
| 完全不要可點連結 | `foo/bar#123` | `foo/bar issue 編號 123` |

**原理**：GitHub 對 inline code span（反引號包起來的內容）不做 reference parsing，不會產生 backlink。

### 本 repo 內部引用不受影響

`#123`（無 `owner/repo` 前綴）或 `https://github.com/<本 repo>/issues/123` 屬於內部引用，屬於預期行為，**不需**用反引號包。

### 自動防護

- `.claude/hooks/external-ref-guard.sh`：PreToolUse hook，`git commit` / `gh pr create|edit|comment` / `gh issue create|edit|comment` 前掃 command text，偵測到指向外部 repo 的裸 reference → **直接阻擋**（`exit 1`）。用反引號包或改寫後即可通過。本 repo 由 `git remote get-url origin` 推導。
- `/pre-pr-check` command 亦會在 PR 建立前執行同樣掃描，補位 `--body-file` 或網頁撰寫情境。
