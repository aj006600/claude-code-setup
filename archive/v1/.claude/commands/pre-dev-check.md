---
description: 開發新功能前的環境檢查（git 狀態 + origin/dev 同步）
---

Run lightweight pre-dev environment checks. Heavy checks (full test run, SPEC verification, lint) live in `/pre-pr-check` or in `tdd-feature-workflow` Phase 1; do not duplicate them here.

## Checks

### 1. Branch topology

`tdd-feature-workflow` 預設 main / qas / dev / feat-fix-... 四層架構(見 `git-rules.md`)。先確認核心三條長期分支存在(local + origin):

```bash
for b in main dev qas; do
  echo -n "$b: "
  git rev-parse --verify "$b" >/dev/null 2>&1 && echo -n "local OK " || echo -n "local MISSING "
  git rev-parse --verify "origin/$b" >/dev/null 2>&1 && echo "origin OK" || echo "origin MISSING"
done
```

任一缺漏 → 列出建立指令給 user 確認,**不在此 command 自動執行**(動 git 結構需 user 同意):

範例(缺 dev / qas)
```bash
git checkout -b dev main && git push -u origin dev
git checkout -b qas main && git push -u origin qas
git checkout dev
```

main 缺 → 罕見情境(repo 預設分支可能是 master / 其他名),停下來與 user 確認 default branch 是什麼,不主動建立 main。

### 2. Uncommitted changes
```bash
git status
```
若有未提交變更 → 詢問 user 處理方式:stash / commit / discard。

### 3. origin/dev 同步狀態
`tdd-feature-workflow` Phase 2.2 即將從 `dev` 開新分支,先 fetch 並比對是否有領先的 commits:
```bash
git fetch origin
git log HEAD..origin/dev --oneline 2>/dev/null
```
若 origin/dev 有領先 commits → 告知 user,Phase 2.2 會以 `git checkout dev && git pull origin dev` 同步;**不在此處先 pull**(避免在 user 當前分支誤動)。

## Report

```
Pre-dev environment check

Branch topology: main(local+origin), dev(local+origin), qas(local+origin) | [缺項 → 列建立指令待確認]
Branch: <current> (last commit: <hash> <subject>)
Uncommitted: clean | <N> files changed
origin/dev: up to date | <N> commits ahead (Phase 2.2 will pull)

→ Next: Phase 2.2 → git checkout dev && git pull origin dev && git checkout -b <type>/<name>
```

任一 check 出現 blocking 狀況(例:有 staged 但去處未明的 changes、fetch 失敗等)→ surface 給 user;否則無 gate。
