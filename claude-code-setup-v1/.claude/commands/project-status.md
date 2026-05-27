---
description: 快速顯示當前專案狀態（分支、未追蹤變更、SPEC / CLAUDE 版本、最近 commits）
---

Run the following read-only checks and present a consolidated status snapshot.

**Do NOT run tests** — `/project-status` 為 read-only snapshot;若需測試狀態請直接 `uv run pytest` 或看 CI checks(`.github/workflows/ci.yml`)。

## Checks to run

### Git status
```bash
git status -sb       # branch + upstream sync + porcelain status
git log --oneline -5 # recent commits
```

從 `git status -sb` 首行抽 sync state:
- `## branch...origin/branch [ahead N]` → `ahead N`
- `## branch...origin/branch [behind M]` → `behind M`
- `## branch...origin/branch [ahead N, behind M]` → `diverged: ahead N, behind M`
- `## branch...origin/branch`(無 bracket) → `up to date`
- `## branch`(無 `...`) → `no upstream`

### File versions

讀 footer:
- `.claude/SPEC.md` — `Version` + `Last Updated`
- `.claude/docs/architecture.md` — `Version` + `Last Updated`
- `.claude/CLAUDE.md` — 只有 `Last Updated`(無 SemVer)

**Edge cases**:
- 三檔皆以 placeholder 形式 ship;頂端仍有 `<!-- TEMPLATE NOTICE -->`(或 footer 仍是字面 `<...>`) → 顯示「not yet initialized — 執行對應 Workflow A」(SPEC → `maintaining-spec-md`、architecture → `maintaining-architecture-md`、CLAUDE → `maintaining-claude-md`)
- 檔案實際不存在(極少見,被刪) → 顯示「missing」

### SPEC.md overview (if initialized)
若 SPEC.md 已客製化(無 NOTICE),計算 `## Functional Requirements` 章節下 `### ` headings 數 → N_features。仍是 placeholder(含範例骨架)→ 不報 FR 數,顯示 not yet initialized。

SPEC 不追蹤進度(進度由 git branch / PR merge 反映);這裡只展示功能總數作為 baseline。

## Present as

```
Project Status

Branch: <branch-name> (<sync state>)
Uncommitted: clean | <N> files changed

SPEC.md: <version> (<date>) | not yet initialized
- Functional Requirements: <N>

architecture.md: <version> (<date>) | not yet initialized

CLAUDE.md: <date> | not yet initialized

Recent commits:
- <hash> <subject>
- <hash> <subject>
- ...
```

If any file is missing or state is unusual, report plainly without guessing.
