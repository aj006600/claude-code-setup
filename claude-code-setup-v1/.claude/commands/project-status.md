---
description: 快速顯示當前專案狀態（分支、未追蹤變更、SPEC / CLAUDE 版本、最近 commits）
---

Run the following read-only checks and present a consolidated status snapshot.

**Do NOT run tests** — tests take time; use `/pre-pr-check` if test status is needed.

## Checks to run

### Git status
```bash
git branch --show-current
git status -sb
git status --short
git log --oneline -5
```

### File versions
Read the footer of these files to extract `Version` and `Last Updated`:
- `.claude/SPEC.md` (may not exist — handle gracefully)
- `.claude/CLAUDE.md`
- `.claude/CLAUDE-CHANGELOG.md` (first version entry)

### SPEC.md progress (if exists)
Read `.claude/SPEC.md` and count occurrences of:
- `Status: Not Started` → N_not_started
- `Status: In Progress` → N_in_progress
- `Status: Completed` → N_completed

## Present as

```
📊 Project Status

Branch: <branch-name> (<sync status with remote>)
Uncommitted: <N> files changed

SPEC.md: <version> (<date>)
- Not Started: <X> features
- In Progress: <Y> features
- Completed: <Z> features

CLAUDE.md: <version> (<date>)

Recent commits:
- <hash> <subject>
- <hash> <subject>
- ...
```

If any file is missing or state is unusual, report plainly without guessing.
