---
name: tdd-feature-workflow
description: Use when the user starts implementing a new feature, bug fix, refactor, or any multi-step code change. Triggers include "實作 X"、"開發 Y"、"新增 Z 功能"、"修 bug A"、"refactor B"、handing over a spec or plan, or "繼續" an in-progress feature. Also use when finalizing work and opening a PR. The skill orchestrates the full 4-phase TDD lifecycle — requirement → plan & implement → pre-PR verification → review & merge — by delegating to superpowers skills, commit-commands, code-review, project-local agents, and maintaining-* skills at appropriate checkpoints. The main flow strictly enforces TDD:SPEC.md first → (optional) brainstorming → writing-plans → executing-plans with test-first → verification → PR → review → merge with doc sync. Trigger proactively even without explicit mention of "TDD" or "workflow" — any conversation about starting, resuming, or finalizing feature work should invoke this skill, because stand-alone code changes without the discipline wrapper are exactly how projects accumulate technical debt.
---

# TDD Feature Workflow(本專案開發編排)

這個 skill 是本專案的**開發編排層**——扮演專案經理角色:負責完整開發生命週期的編排(需求 → 實作 → PR → merge → 文檔同步),在正確時機委派給正確的 superpowers skill、commands、agents、maintaining-* skills,並注入專案專屬細節(uv、pytest、coverage 目標、架構——以 CLAUDE.md Architecture 章節為準)。

**核心原則:嚴格遵守 TDD**——所有實作路徑必須經過 `writing-plans → executing-plans` 的測試先行流程。

---

## 為何需要這層編排

散落的 workflow 片段無法保證被全部執行:
- 跳過 TDD 直接寫 code → 產出沒測試的代碼
- 有測試但沒跑 coverage → 表面通過、實質不足
- 改功能但沒更新 SPEC / CLAUDE / README → 文檔漂移
- 忘記用 `code-simplifier:code-simplifier` → 代碼品質不穩

Skill 把這些點串成**有執行順序、關鍵節點都有 hook、TDD 全程強制**的流程。

---

## 關鍵分工

本 skill 只負責**編排**,實際動作委派給:

| 階段關鍵動作 | 委派對象 |
|------------|---------|
| 需求確認 / SPEC 更新 | `maintaining-spec-md` skill |
| 需求設計討論(模糊時) | `superpowers:brainstorming` |
| 寫 plan(bite-sized TDD tasks) | `superpowers:writing-plans` |
| 執行 plan(批次 + checkpoint) | `superpowers:executing-plans` |
| TDD 紀律 | `superpowers:test-driven-development` |
| 寫測試(具體產出) | `test-automator` agent |
| 代碼簡化審查 | `code-simplifier:code-simplifier` agent |
| 完成前驗證 | `superpowers:verification-before-completion` |
| PR 前完整檢查 | `/pre-pr-check` command |
| Code review(輕量 / 深度) | `code-reviewer` agent / `/code-review` command |
| Commit + Push + PR | `/commit-push-pr` command(或手工) |
| 文檔同步 | `maintaining-readme-md` / `maintaining-claude-md` skills |
| Branch 收尾 | `superpowers:finishing-a-development-branch` |

補充資源(選配):`feature-dev:code-explorer` / `code-architect`(深度探索 / 多方案對比)、`superpowers:systematic-debugging`、`superpowers:dispatching-parallel-agents` + `using-git-worktrees`(多任務並行)、`superpowers:subagent-driven-development`。完整動態清單見 `/agent-cheatsheet`。

---

## 4 階段工作流程

### 階段 1:需求確認與設計

**目的**:SPEC.md 先行,實作跟著規範走。

```
User 提需求
    ↓
[啟用 maintaining-spec-md]
    ↓
Skill 產出 SPEC 更新 diff → User 確認
    ↓
(選配)需求仍模糊? → 啟用 superpowers:brainstorming 深化設計
    ↓
SPEC.md 更新完成 → 進入階段 2
```

若 SPEC.md 顯示此功能已 `In Progress`:不需重啟 `maintaining-spec-md`,直接繼續。

**何時啟用 `brainstorming`**:需求描述抽象、有多個實作方向但 trade-off 不明、User 想先聊設計再動手。

---

### 階段 2:規劃與實作(核心階段)

#### 2.1 前置檢查
執行 `/pre-dev-check` command。失敗先解決再進 2.2。

#### 2.2 建立功能分支
```bash
git checkout dev && git pull origin dev
git checkout -b feat/<feature-name>  # 或 fix/* refactor/* hotfix/* 依 git-rules.md
```

#### 2.3 寫 plan
啟用 `superpowers:writing-plans` skill。

**選配加強**(複雜功能):
- 深度探索 codebase → 委派 `feature-dev:code-explorer` agent
- 想對比多個架構方案 → 並行委派 2-3 個 `feature-dev:code-architect` agent(分別聚焦最小改動 / 清潔架構 / 實用平衡)

無論是否使用上述 agent,最終**必須透過 `writing-plans → executing-plans` 走 TDD 流程**。

#### 2.4 撰寫測試(Test-First)
啟用 `superpowers:test-driven-development` skill 指引紀律;實際產出委派 `test-automator`:

```
Agent({
  subagent_type: "test-automator",
  description: "Write tests for <feature>",
  prompt: "Write pytest tests for feature X in tests/unit/<module>/test_<feature>.py. Cover: success, error handling, edge cases. Use pytest-asyncio for async."
})
```

**測試檔案位置慣例**:
- 單元:`tests/unit/<module>/test_<feature>.py`
- 整合:`tests/integration/test_<feature>_integration.py`
- E2E:`tests/e2e/test_<feature>_e2e.py`

#### 2.5 執行測試(應失敗,因尚未實作)

#### 2.6 實作功能
啟用 `superpowers:executing-plans` 批次執行 plan(含 checkpoint review)。

**專案專屬提醒**:
- 依 CLAUDE.md Architecture 章節將代碼放到對應模組
- 新增模組時考慮是否連動更新 SPEC.md / CLAUDE.md Architecture
- 遵循 `.claude/rules/code-style.md`(命名、type hints、docstring)
- 技術疑問 → 使用 `context7` MCP 查最新 library 文檔

#### 2.7 ~ 2.9 執行測試
依序:相關測試通過 → 全測試無 regression → 檢查覆蓋率(目標 70%+)。

測試 / 覆蓋率指令依 CLAUDE.md Tech Stack 章節決定;`/pre-pr-check` command 會在階段 3 統一驗證。

#### 2.10 更新 SPEC.md Status
啟用 `maintaining-spec-md` 更新 Status(`In Progress` → `Completed`)、勾選已達成的 Acceptance Criteria。

---

### 階段 3:完成前驗證與 PR

#### 3.1 完成前強制自檢
啟用 `superpowers:verification-before-completion`——強制回答「真的完成了嗎?」,防止誤報。

#### 3.2 執行 `/pre-pr-check` command
- Level 1(tests hard gate)失敗 → 回 2.7 修復
- Level 2(coverage / code-simplifier / lint / format / type-check / external-ref scan)→ 視情況處理
- Level 3(SPEC / README 提示)→ 啟用對應 maintaining-* skill

#### 3.3 處理 `code-simplifier:code-simplifier` 建議
若採納建議修改代碼 → **遵循 TDD**:更新測試 → 重跑相關測試 → 重跑所有測試確認無 regression。

#### 3.4 Commit + Push + PR(二選一)

**手工**:依 `.claude/rules/git-rules.md` 格式 commit → push → `gh pr create --base dev`。

**`/commit-push-pr`**(若已安裝 commit-commands plugin):自動編排 commit + push + PR 建立。

SPEC.md 變更須獨立 commit。

---

### 階段 4:Review 與 Merge

#### 4.1 建立 code review checklist
啟用 `superpowers:requesting-code-review`——產出結構化 checklist。

#### 4.2 Code review(輕量 / 深度二選一)

**輕量(單 reviewer)**:
```
Agent({
  subagent_type: "code-reviewer",
  description: "PR review for <feature>",
  prompt: "Review PR #<N> on feat/<feature-name>. Check bugs, logic, security, adherence to CLAUDE.md and code-style. Report high-confidence issues only."
})
```

**深度(多層次並行)**:`/code-review` — 多 reviewer agents 平行(簡潔性 / bug / 慣例)。

發現問題 → 回階段 2 修改,遵循 TDD。

#### 4.3 處理 review 反饋
啟用 `superpowers:receiving-code-review`——系統化分類 comments(優先級、修或 defer、確認無遺漏)。

#### 4.4 更新 User-facing 文檔(若變更影響 User)
啟用 `maintaining-readme-md`——skill 會判斷狀態並把文檔更新加入同一 PR。

#### 4.5 更新 CLAUDE.md(若影響架構 / tech stack)
啟用 `maintaining-claude-md`。

#### 4.6 合併與清理
啟用 `superpowers:finishing-a-development-branch`——自動完成 PR merge、回 dev 並 pull、刪除本地與遠端分支。

---

## 特殊情境

- **Hotfix**:從 `main` 建 `hotfix/<bug-name>`,最小修改 + 測試覆蓋該 bug(仍 TDD),PR 到 `main` 與 `dev` 雙分支,事後補 `maintaining-readme-md` 檢查
- **Refactor 不增新功能**:仍 TDD(既有測試通過 → 重構 → 測試仍通過);SPEC 通常不需更新;CLAUDE.md 若涉架構改變則更新
- **Spike / Prototype**:建 `spike/<name>` 分支,期間不強制 TDD;**採納必須重寫走正式階段 1-4**,不直接 merge spike 代碼
- **Debug 深入**:啟用 `superpowers:systematic-debugging`(hypothesis → test → refine 循環;Heisenbug / race condition)
- **多任務並行**:`superpowers:using-git-worktrees` + `superpowers:dispatching-parallel-agents`;每個子任務仍各自走 TDD
- **子任務外包(spec-driven)**:`superpowers:subagent-driven-development`

---

## Gotchas(容易忘記的關鍵點)

- **TDD 不可繞過**:無論採用何種 agent 輔助規劃,實作路徑必須經 `writing-plans → executing-plans`——繞過即埋品質債
- **SPEC.md 先行**:階段 1 未完成前不進階段 2;SPEC 變更獨立 commit
- **`code-simplifier` 建議引發修改 → 重跑 TDD**:改代碼後必須重跑相關測試 + 全測試,不能只跑被改的檔案
- **階段 3 → 4 的 gate 是 `verification-before-completion`**:不是「測試過了」就算完,要強制回答「真的完成了嗎?」
- **文檔同步在 merge 前**(階段 4.4 / 4.5):一旦 merge 回 dev,需改走 `maintaining-readme-md` 狀態 D 補救流程,多一步工
