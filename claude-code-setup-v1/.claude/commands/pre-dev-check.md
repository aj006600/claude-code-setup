---
description: 開發新功能前的準備檢查（git 狀態、遠端同步、測試基線、SPEC.md）
---

Execute pre-development checks before starting any new feature work.

## Checks

### 1. Git uncommitted changes
```bash
git status
```
If uncommitted changes exist → ask User to stash / commit / discard.

### 2. Current branch
```bash
git branch --show-current
```
If NOT on `dev` (or the intended base branch) → ask User whether to:
- Switch to `dev` first
- Stack new work on current branch

### 3. Sync with remote
```bash
git fetch origin
git status -sb
```
If behind remote → suggest `git pull`.

### 4. Test baseline
```bash
uv run pytest tests/ -v
```
If any test fails → **STOP**. Do not proceed with new feature work on a failing baseline. Report failing tests.

### 5. SPEC.md feature check
Read `.claude/SPEC.md`. Ask User what feature they plan to work on. Verify:
- Feature listed in Functional Requirements?
- If not → suggest activating `maintaining-spec-md` skill first
- If yes → report its Acceptance Criteria

## Report format

On all-pass:
```
Pre-dev check passed

Branch: dev (up to date with origin)
Tests: <X> passed / 0 failed
SPEC.md: <feature Y> listed with <N> Acceptance Criteria

Ready to create feature branch: feat/<feature-name>
```

On failure(s):
```
Pre-dev check found <N> issue(s):
- [specific issue 1]
- [specific issue 2]

Please resolve before starting new feature work.
```
