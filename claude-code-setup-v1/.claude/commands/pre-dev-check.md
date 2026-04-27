---
description: 開發新功能前的環境檢查（git 狀態 + origin/dev 同步）
---

Run lightweight pre-dev environment checks. Heavy checks (full test run, SPEC verification, lint) live in `/pre-pr-check` or in `tdd-feature-workflow` Phase 1; do not duplicate them here.

## Checks

### 1. Uncommitted changes
```bash
git status
```
若有未提交變更 → 詢問 user 處理方式:stash / commit / discard。

### 2. origin/dev 同步狀態
`tdd-feature-workflow` Phase 2.2 即將從 `dev` 開新分支,先 fetch 並比對是否有領先的 commits:
```bash
git fetch origin
git log HEAD..origin/dev --oneline 2>/dev/null
```
若 origin/dev 有領先 commits → 告知 user,Phase 2.2 會以 `git checkout dev && git pull origin dev` 同步;**不在此處先 pull**(避免在 user 當前分支誤動)。

## Report

```
Pre-dev environment check

Branch: <current> (last commit: <hash> <subject>)
Uncommitted: clean | <N> files changed
origin/dev: up to date | <N> commits ahead (Phase 2.2 will pull)

→ Next: Phase 2.2 → git checkout dev && git pull origin dev && git checkout -b <type>/<name>
```

任一 check 出現 blocking 狀況(例:有 staged 但去處未明的 changes、fetch 失敗等)→ surface 給 user;否則無 gate。
