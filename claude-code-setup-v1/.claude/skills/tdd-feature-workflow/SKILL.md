---
name: tdd-feature-workflow
description: Use this skill whenever the user starts implementing a new feature, bug fix, refactor, or any multi-step code change in this project. Triggers include phrases like "實作 X"、"開發 Y"、"新增 Z 功能"、"修 bug A"、"refactor B"、handing over a spec or plan, or saying they want to "繼續" an in-progress feature. Also use when user wants to finalize work and open a PR. The skill orchestrates the full 4-phase TDD lifecycle — requirement → plan & implement → pre-PR verification → review & merge — by delegating to superpowers skills (brainstorming, writing-plans, executing-plans, test-driven-development, verification-before-completion, requesting-code-review, receiving-code-review, finishing-a-development-branch, systematic-debugging), commit-commands (/commit-push-pr), code-review (/code-review), project-local agents (test-automator, code-reviewer), and maintaining-* skills at appropriate checkpoints. The main flow strictly enforces TDD: SPEC.md first → (optional) brainstorming for design discussion → writing-plans → executing-plans with test-first discipline → verification → PR → review → merge with documentation sync. This skill deliberately does NOT integrate /feature-dev command in the main flow because /feature-dev does not enforce TDD. Trigger proactively even when the user does not explicitly mention "TDD" or "workflow" — any conversation about starting feature work, resuming feature work, or finalizing a feature branch in this project should invoke this skill, because stand-alone code changes without the discipline wrapper are exactly how projects accumulate technical debt.
---

# TDD Feature Workflow（本專案開發編排）

這個 skill 是本專案的**開發編排層**——扮演**專案經理**角色：負責完整開發生命週期的編排（需求→實作→PR→merge→文檔同步），在正確的時機委派給正確的 superpowers skill、commands、agents、maintaining-* skills，並注入專案專屬細節（uv、pytest、coverage 目標、專案架構——以 CLAUDE.md 的 Architecture 章節為準）。

**核心原則：嚴格遵守 TDD**——所有實作路徑必須經過 `writing-plans → executing-plans` 的測試先行流程。本 skill 不把 `/feature-dev` command 納入主流程（因其未強制 TDD）。

---

## 為何需要這層編排

散落的 workflow 片段無法保證被全部執行：
- 直接寫 code 而跳過 TDD → 產出沒測試的代碼
- 有測試但沒跑 coverage → 表面通過、實質不足
- 改了功能但沒更新 SPEC / CLAUDE / README → 文檔漂移
- 忘記用 `code-simplifier:code-simplifier` → 代碼品質不穩
- 採用「一鍵全包」的替代流程 → 繞過 TDD 紀律、埋下品質債

這個 skill 把這些點串成**有執行順序、關鍵節點都有 hook、TDD 全程強制**的流程。它是「編排」，不取代既有 superpowers skills。

---

## 與既有資源的分工

| 職責 | 歸屬 |
|------|------|
| 編排 4 階段流程、決定何時啟用什麼 | **本 skill** |
| 需求確認、SPEC.md 建立 / 更新 | `maintaining-spec-md` skill |
| 需求設計討論（對話式，需求模糊時） | `superpowers:brainstorming` skill |
| 寫 plan（bite-sized TDD tasks） | `superpowers:writing-plans` skill |
| 執行 plan（批次 + checkpoint） | `superpowers:executing-plans` skill |
| TDD 紀律（測試先行） | `superpowers:test-driven-development` skill |
| 寫測試（具體產出） | `test-automator` agent（project-local） |
| Codebase 深度探索（選配，手動） | `feature-dev:code-explorer` agent |
| 多方案架構探索（選配，手動） | `feature-dev:code-architect` agent |
| 代碼實作 | Claude 本人 + `executing-plans` 搭配 |
| 代碼簡化審查 | `code-simplifier:code-simplifier` agent（plugin） |
| 完成前驗證 | `superpowers:verification-before-completion` skill |
| PR 前完整檢查 | `/pre-pr-check` command |
| 建立 code review checklist | `superpowers:requesting-code-review` skill |
| Code review（輕量，單 agent） | `code-reviewer` agent（project-local） |
| Code review（深度，多層次並行） | `/code-review` command（plugin） |
| 接收 review 反饋並處理 | `superpowers:receiving-code-review` skill |
| Commit + Push + PR 一體化 | `/commit-push-pr` command（plugin）或手工 `gh pr create` |
| README / docs 更新 | `maintaining-readme-md` skill → `documentation-engineer` agent |
| CLAUDE.md 變更 | `maintaining-claude-md` skill |
| Branch 收尾（merge + cleanup） | `superpowers:finishing-a-development-branch` skill |
| 系統化 debug | `superpowers:systematic-debugging` skill |
| 多任務並行開發 | `superpowers:dispatching-parallel-agents` + `using-git-worktrees` |
| 子任務外包（spec-driven） | `superpowers:subagent-driven-development` skill |

---

## 4 階段工作流程

### 階段 1：需求確認與設計

**目的**：SPEC.md 先行，實作跟著規範走。若需求模糊，加深設計討論後再進入實作。

```
User 提需求
    ↓
[啟用 maintaining-spec-md skill]
    ↓
Skill 產出 SPEC 更新 diff → User 確認
    ↓
（選配）需求仍模糊或設計有多選項？
    ↓ Yes → 啟用 superpowers:brainstorming skill 深化設計
    ↓
SPEC.md 更新完成
    ↓
進入階段 2
```

若 SPEC.md 顯示此功能已為 `In Progress`：不需重新啟用 `maintaining-spec-md`，直接繼續。

**何時啟用 `brainstorming`**：
- 需求描述抽象（例如「讓系統更快」）
- 有多個實作方向但 trade-off 不明
- User 想先聊過設計再動手

---

### 階段 2：規劃與實作（核心階段）

#### 2.1 前置檢查
執行 `/pre-dev-check` command。失敗先解決再進入 2.2。

#### 2.2 建立功能分支
```bash
git checkout dev && git pull origin dev
git checkout -b feat/<feature-name>  # 或 fix/* refactor/* hotfix/* 依 git-rules.md
```

#### 2.3 寫 plan

啟用 `superpowers:writing-plans` skill 寫 plan（bite-sized TDD tasks）。

**選配加強**（複雜功能可用，但**不取代**本流程）：
- **深度探索 codebase** → 委派 `feature-dev:code-explorer` agent 做架構層探索
- **想對比多個架構方案** → 並行委派 2-3 個 `feature-dev:code-architect` agent（分別聚焦最小改動 / 清潔架構 / 實用平衡）

無論是否使用上述 agent，最終**必須透過 `writing-plans → executing-plans` 走 TDD 流程**。本 skill 不採用 `/feature-dev` command 作為實作入口，避免繞過 TDD 強制。

#### 2.4 撰寫測試（Test-First）

啟用 `superpowers:test-driven-development` skill 指引 TDD 紀律；實際產出可委派 `test-automator` agent：

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
啟用 `superpowers:executing-plans` skill 批次執行 plan（含 checkpoint review）。

**專案專屬提醒**：
- 依 CLAUDE.md Architecture 章節將代碼放到對應模組
- 新增模組時考慮是否連動更新 SPEC.md / CLAUDE.md Architecture（啟用 `maintaining-spec-md` / `maintaining-claude-md`）
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

---

### 階段 3：完成前驗證與 PR

#### 3.1 完成前強制自檢
啟用 `superpowers:verification-before-completion` skill — 強制回答「真的完成了嗎？」防止誤報已完成。

#### 3.2 執行 `/pre-pr-check` command
- Level 1（tests hard gate）失敗 → 回到 2.7 修復
- Level 2（coverage / code-simplifier / lint / format / type-check 軟警告）→ 視情況處理
- Level 3（SPEC / README 提示）→ 啟用對應 maintaining-* skill

#### 3.3 處理 `code-simplifier:code-simplifier` 建議
若採納建議且修改代碼 → 遵循 TDD：
1. 更新測試（若需）
2. 重跑相關測試
3. 重跑所有測試確認無 regression

#### 3.4 Commit + Push + PR（二選一）

**選項 A：手工**
```bash
git add <relevant-files>
git commit -m "<type>(<scope>): <description>

Authored-By: <YourName> <your-email@example.com>"
git push origin feat/<feature-name>
gh pr create --base dev --title "..." --body "..."
```

**選項 B：`/commit-push-pr` 一體化**（若已安裝 commit-commands plugin）
```bash
/commit-push-pr
```
此 command 自動編排 commit + push + PR 建立。

Commit 規範見 `.claude/rules/git-rules.md`。SPEC.md 變更須獨立 commit。

---

### 階段 4：Review 與 Merge

#### 4.1 建立 code review checklist
啟用 `superpowers:requesting-code-review` skill — 產出結構化 checklist，指引 reviewer（人或 agent）該關注什麼。

#### 4.2 Code review（輕量 / 深度二選一）

**選項 A：輕量（project-local agent，單 reviewer）**
```
Agent({
  subagent_type: "code-reviewer",
  description: "PR review for <feature>",
  prompt: "Review PR #<N> on feat/<feature-name>. Check: bugs, logic errors, security, adherence to CLAUDE.md and code-style. Report high-confidence issues only."
})
```

**選項 B：深度（plugin command，多層次平行驗證）**
```bash
/code-review
```
此 command 啟動多個 reviewer agents 並行（多維度驗證：簡潔性 / bug / 慣例）。

若發現問題 → 回到階段 2 修改，遵循 TDD。

#### 4.3 處理 review 反饋（若有）
啟用 `superpowers:receiving-code-review` skill — 系統化分類 review comments（分優先級、標記修或 defer、確認無遺漏）。

#### 4.4 更新 User-facing 文檔（若變更影響 User）
啟用 `maintaining-readme-md` skill — skill 會判斷狀態並把文檔更新加入同一 PR。

#### 4.5 更新 CLAUDE.md（若影響架構 / tech stack）
啟用 `maintaining-claude-md` skill — 同步開發規範。

#### 4.6 合併與清理
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

## 特殊情境處理

### Hotfix 流程（緊急生產問題）
- 從 `main` 分支建立 `hotfix/<bug-name>`
- 最小修改 + 測試覆蓋該 bug（仍遵循 TDD）
- PR 到 `main` 與 `dev`（雙分支）
- 事後補 `maintaining-readme-md` 檢查

### Refactor 不增新功能
- 仍遵循 TDD：先保證既有測試通過 → 重構 → 測試仍通過
- SPEC.md 通常不需更新（需求沒變）
- CLAUDE.md 若涉及架構改變則更新

### Spike / Prototype
- 建立 `spike/<name>` 分支（非正式 convention）
- Spike 階段不強制 TDD（純實驗）
- 完成後：丟棄（刪分支）或採納（**採納必須重寫走正式階段 1-4 的 TDD 流程**，不直接 merge spike 代碼）

### Debug 深入（系統化除錯）
啟用 `superpowers:systematic-debugging` skill — 適用於：
- Bug 原因不明需系統化排查
- 需建立 hypothesis → test → refine 循環
- Heisenbug、race condition 等棘手問題

### 多任務並行開發（大型改動）
啟用組合：
- `superpowers:using-git-worktrees` — 多分支隔離環境
- `superpowers:dispatching-parallel-agents` — 獨立任務並行派發

適用於：可拆分為 N 個互相獨立的子任務（例如同時改動 3 個服務）。每個子任務仍各自走 TDD 流程。

### 子任務外包（spec-driven）
啟用 `superpowers:subagent-driven-development` skill — 適用於：
- 子任務有明確規格（可用 yaml/json 或結構化 prompt 定義）
- 希望 subagent 獨立完成並驗證 spec compliance

---

## 自我檢查清單

### 啟動前
- [ ] User 的需求是新功能 / bug fix / refactor 哪一種？
- [ ] SPEC.md 是否已涵蓋此需求？
- [ ] 是否需要 brainstorming 深化設計，或需求已清楚可直接進入 writing-plans？

### 各階段過渡前
- [ ] 階段 1 → 2：SPEC.md 已更新且 User 確認？
- [ ] 階段 2 → 3：測試全綠 + coverage 達標 + SPEC Status 已更新？
- [ ] 階段 3 → 4：verification-before-completion 已通過 + PR 已建立 + CI 通過？
- [ ] 階段 4 完成：文檔已同步 + 分支已清理？

### 結束後
- [ ] 是否啟用 `maintaining-readme-md` 更新文檔？
- [ ] CLAUDE.md 若影響則啟用 `maintaining-claude-md`？
- [ ] SPEC.md Status 已從 In Progress → Completed？
