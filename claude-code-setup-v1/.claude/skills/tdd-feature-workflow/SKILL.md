---
name: tdd-feature-workflow
description: Use this skill whenever the user starts implementing a new feature, bug fix, refactor, or any multi-step code change in this project. Triggers include phrases like "實作 X"、"開發 Y"、"新增 Z 功能"、"修 bug A"、"refactor B"、handing over a spec or plan, or saying they want to "繼續" an in-progress feature. Also use when user wants to finalize work and open a PR. The skill orchestrates the full 4-phase TDD workflow by delegating to existing superpowers skills (feature-dev, executing-plans, test-driven-development, finishing-a-development-branch, verification-before-completion), project-local agents (test-automator, code-reviewer), plugin agents (code-simplifier:code-simplifier), and maintaining-* skills at appropriate checkpoints. It layers on project-specific details from CLAUDE.md (uv command patterns, pytest configuration, coverage target, project architecture). Trigger proactively even when the user does not explicitly mention "TDD" or "workflow" — any conversation about starting feature work, resuming feature work, or finalizing a feature branch in this project should invoke this skill, because stand-alone code changes without the discipline wrapper are exactly how projects accumulate technical debt.
---

# TDD Feature Workflow（本專案開發編排）

這個 skill 是本專案的**開發編排層**。它不自己做細節工作（寫測試、執行 plan、寫文檔），而是在正確的時機委派給正確的 superpowers skill、agent 或 command，並注入專案專屬細節（uv、pytest、coverage 目標、專案架構——以 CLAUDE.md 的 Architecture 章節為準）。

---

## 為何需要這層編排

散落的 workflow 片段無法保證被全部執行：
- 直接寫 code 而跳過 TDD → 產出沒測試的代碼
- 有測試但沒跑 coverage → 表面通過、實質不足
- 改了功能但沒更新 SPEC / CLAUDE / README → 文檔漂移
- 忘記用 `code-simplifier:code-simplifier` → 代碼品質不穩

這個 skill 把這些點串成一條**有執行順序、關鍵節點都有 hook** 的流程。它是「編排」，不是「取代」既有 superpowers skills。

---

## 與既有資源的分工

| 職責 | 歸屬 |
|------|------|
| 編排 4 階段流程、決定何時啟用什麼 | **本 skill** |
| 需求確認、SPEC.md 建立 / 更新 | `maintaining-spec-md` skill |
| 功能拆解、架構設計 | `superpowers:feature-dev` skill |
| 寫 plan | `superpowers:writing-plans` skill |
| 執行 plan | `superpowers:executing-plans` skill |
| 寫測試 | `test-automator` agent（local）或 `superpowers:test-driven-development` skill |
| 代碼實作 | Claude 本人 + `superpowers:executing-plans` skill 搭配 |
| 代碼簡化審查 | `code-simplifier:code-simplifier` agent（plugin） |
| 完成前驗證 | `superpowers:verification-before-completion` skill |
| PR 前完整檢查 | `/pre-pr-check` command |
| Code review | `code-reviewer` agent（local） |
| README / docs 更新 | `maintaining-readme-md` skill → `documentation-engineer` agent |
| CLAUDE.md 變更 | `maintaining-claude-md` skill |
| Branch 收尾 | `superpowers:finishing-a-development-branch` skill |

---

## 4 階段工作流程

### 階段 1：需求確認

**目的**：SPEC.md 先行，實作跟著規範走。

```
User 提需求
    ↓
[啟用 maintaining-spec-md skill]
    ↓
Skill 產出 SPEC 更新 diff → User 確認
    ↓
SPEC.md 更新完成
    ↓
進入階段 2
```

若 SPEC.md 顯示此功能已為 `In Progress`：不需重新啟用 `maintaining-spec-md`，直接繼續。

### 階段 2：開發（TDD）

#### 2.1 前置檢查
執行 `/pre-dev-check` command。失敗先解決再進入 2.2。

#### 2.2 建立功能分支
```bash
git checkout dev && git pull origin dev
git checkout -b feat/<feature-name>  # 或 fix/* refactor/* hotfix/* 依 git-rules.md
```

#### 2.3 規劃實作
- 複雜度 > 3 步驟 → 啟用 `superpowers:feature-dev` 或 `superpowers:writing-plans` skill 先寫 plan
- 複雜度 ≤ 3 步驟 → 直接進 2.4

#### 2.4 寫測試（Test-First）
啟用 `superpowers:test-driven-development` skill 或委派 `test-automator` agent：

```
Agent({
  subagent_type: "test-automator",
  description: "Write tests for <feature>",
  prompt: "Write pytest tests for feature X in tests/unit/<module>/test_<feature>.py. Cover: success path, error handling, edge cases. Use pytest-asyncio for async code."
})
```

**測試檔案位置慣例**：
- 單元測試：`tests/unit/<module>/test_<feature>.py`
- 整合測試：`tests/integration/test_<feature>_integration.py`
- E2E 測試：`tests/e2e/test_<feature>_e2e.py`

#### 2.5 執行測試（應失敗，因尚未實作）
```bash
uv run pytest tests/unit/<module>/test_<feature>.py -v
```

#### 2.6 實作功能
啟用 `superpowers:executing-plans` skill（若有 plan）或直接實作。

**專案專屬提醒**：
- 依專案架構（見 `.claude/CLAUDE.md` Architecture 章節）將代碼放到對應模組
- 新增模組時考慮是否連動更新 SPEC.md Architecture / CLAUDE.md Architecture（分別啟用 `maintaining-spec-md` / `maintaining-claude-md` skill）
- 遵循 `.claude/rules/code-style.md` 的命名、type hints、docstring 規範
- 技術疑問 → 使用 `context7` MCP 查最新 library 文檔

#### 2.7 執行測試直到通過
```bash
uv run pytest tests/unit/<module>/test_<feature>.py -v
uv run pytest tests/integration/test_<feature>_integration.py -v  # 若有
```

#### 2.8 執行所有測試確認無 regression
```bash
uv run pytest tests/ -v
```

#### 2.9 檢查覆蓋率（目標 70%+）
```bash
uv run pytest tests/ --cov=src --cov-report=term-missing
```
低於目標 → 補測試。

#### 2.10 更新 SPEC.md Status
啟用 `maintaining-spec-md` skill 更新功能 Status（`In Progress` → `Completed`）、勾選已達成的 Acceptance Criteria。

#### 2.11 完成前驗證
啟用 `superpowers:verification-before-completion` skill 確認沒有遺漏。進入階段 3。

### 階段 3：提交與 PR

#### 3.1 執行 `/pre-pr-check` command
- Level 1（測試）失敗 → 回到 2.7 修復
- Level 2（coverage / code-simplifier）警告 → 視情況處理
- Level 3（SPEC / README）提示 → 啟用對應 maintaining-* skill

#### 3.2 處理 `code-simplifier:code-simplifier` 的建議
若採納建議且修改代碼 → 遵循 TDD：
1. 更新測試（若需）
2. 重跑相關測試
3. 重跑所有測試確認無 regression

#### 3.3 提交
```bash
git add <relevant-files>
git commit -m "<type>(<scope>): <description>

Authored-By: <YourName> <your-email@example.com>"
```

Commit 規範見 `.claude/rules/git-rules.md`。SPEC.md 變更須獨立 commit。

#### 3.4 推送分支
```bash
git push origin feat/<feature-name>
```

#### 3.5 建立 PR 到 dev
```bash
gh pr create --base dev --title "<type>(<scope>): <description>" --body "## Summary
[變更摘要]

## Changes
- [變更項目 1]
- [變更項目 2]"
```

### 階段 4：Review 與 Merge

#### 4.1 Code review
呼叫 `code-reviewer` agent：

```
Agent({
  subagent_type: "code-reviewer",
  description: "PR review for <feature>",
  prompt: "Review PR #<N> on feat/<feature-name> branch. Check: bugs, logic errors, security, adherence to CLAUDE.md and code-style conventions. Report high-confidence issues only."
})
```

若發現問題 → 回到階段 2 修改，遵循 TDD 流程。

#### 4.2 更新文檔（若變更影響 User）
- 變更含 user-facing 改動（新功能、API 變更、安裝步驟變更）→ 啟用 `maintaining-readme-md` skill（skill 會將文檔更新加入同一 PR）
- 變更影響 Project Overview / Tech Stack / Architecture → 也啟用 `maintaining-claude-md` skill

#### 4.3 合併並清理
啟用 `superpowers:finishing-a-development-branch` skill 自動完成：
- 合併 PR：`gh pr merge --squash`
- 切回 dev 並 pull：`git checkout dev && git pull origin dev`
- 刪除分支：`git branch -d feat/<feature-name> && git push origin --delete feat/<feature-name>`

---

## 專案專屬指令速查

### 測試
```bash
# 特定測試
uv run pytest tests/unit/<module>/test_<feature>.py -v

# 所有測試
uv run pytest tests/ -v

# 覆蓋率（目標 70%+）
uv run pytest tests/ --cov=src --cov-report=term-missing
```

### Lint / format（若 pyproject.toml 有配置）
```bash
uv run ruff check .
uv run ruff format .
```

### Dependency 管理
```bash
uv add <package>        # 新增依賴
uv remove <package>     # 移除
uv sync                 # 同步環境
```

### Git 快速狀態（或用 `/project-status` command）
```bash
git status -sb
git log --oneline -5
```

---

## 特殊情況處理

### Hotfix 流程（緊急生產問題）
- 從 `main` 分支建立 `hotfix/<bug-name>`
- 最小修改 + 測試覆蓋該 bug
- PR 到 `main` 與 `dev`（雙分支）
- 事後補 `maintaining-readme-md` 檢查

### Refactor 不增新功能
- 仍遵循 TDD：先保證既有測試通過 → 重構 → 測試仍通過
- SPEC.md 通常不需更新（需求沒變）
- CLAUDE.md 若涉及架構改變則更新

### Spike / Prototype
- 建立 `spike/<name>` 分支（非正式 convention，討論後決定）
- 不強制 TDD
- 完成後：丟棄（刪分支）或採納（走正式階段 1-4）

---

## 自我檢查清單

### 啟動前
- [ ] User 的需求是新功能 / bug fix / refactor 哪一種？
- [ ] SPEC.md 是否已涵蓋此需求？

### 各階段過渡前
- [ ] 階段 1 → 2：SPEC.md 已更新且 User 確認？
- [ ] 階段 2 → 3：測試全綠 + coverage 達標 + SPEC Status 已更新？
- [ ] 階段 3 → 4：PR 已建立且 CI 通過？
- [ ] 階段 4 完成：文檔已同步 + 分支已清理？

### 結束後
- [ ] 是否建議 User 啟用 `maintaining-readme-md` 更新文檔？
- [ ] CLAUDE.md 若影響則啟用 `maintaining-claude-md`？
- [ ] SPEC.md Status 已從 In Progress → Completed？
