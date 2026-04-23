---
name: tdd-feature-workflow
description: Use this skill whenever the user starts implementing a new feature, bug fix, refactor, or any multi-step code change in this project. Triggers include phrases like "實作 X"、"開發 Y"、"新增 Z 功能"、"修 bug A"、"refactor B"、handing over a spec or plan, or saying they want to "繼續" an in-progress feature. Also use when user wants to finalize work and open a PR. The skill orchestrates the full 4-phase TDD lifecycle — requirement → plan & implement → pre-PR verification → review & merge — by delegating to existing superpowers skills (brainstorming, writing-plans, executing-plans, test-driven-development, verification-before-completion, requesting-code-review, receiving-code-review, finishing-a-development-branch), feature-dev plugin resources (code-explorer / code-architect agents, /feature-dev command), commit-commands (/commit-push-pr), code-review (/code-review), project-local agents (test-automator, code-reviewer), and maintaining-* skills at appropriate checkpoints. It layers on project-specific details from CLAUDE.md (uv command patterns, pytest configuration, coverage target, project architecture). At Step 2.3 it offers three mutually-exclusive planning paths (A lightweight / B multi-architecture comparison / C /feature-dev full 7-phase) so the adopter can match workflow depth to feature complexity. Trigger proactively even when the user does not explicitly mention "TDD" or "workflow" — any conversation about starting feature work, resuming feature work, or finalizing a feature branch in this project should invoke this skill, because stand-alone code changes without the discipline wrapper are exactly how projects accumulate technical debt.
---

# TDD Feature Workflow（本專案開發編排）

這個 skill 是本專案的**開發編排層**——扮演**專案經理**角色：負責完整開發生命週期的編排（需求→實作→PR→merge→文檔同步），在正確的時機委派給正確的 superpowers skill、feature-dev resources、commands、agents、maintaining-* skills，並注入專案專屬細節（uv、pytest、coverage 目標、專案架構——以 CLAUDE.md 的 Architecture 章節為準）。

---

## 為何需要這層編排

散落的 workflow 片段無法保證被全部執行：
- 直接寫 code 而跳過 TDD → 產出沒測試的代碼
- 有測試但沒跑 coverage → 表面通過、實質不足
- 改了功能但沒更新 SPEC / CLAUDE / README → 文檔漂移
- 忘記用 `code-simplifier:code-simplifier` → 代碼品質不穩
- 對複雜功能用輕量 plan、對簡單改動開大流程 → workflow depth 錯配

這個 skill 把這些點串成**有執行順序、關鍵節點都有 hook、依複雜度選擇 workflow depth** 的流程。它是「編排」，不取代既有 superpowers / feature-dev resources。

---

## 定位澄清：本 skill vs `feature-dev`

| 維度 | **tdd-feature-workflow**（本 skill） | **feature-dev**（plugin） |
|------|---|---|
| 定位 | 專案經理（全生命週期編排） | Staff engineer（實作階段深度） |
| 強制 TDD | ✅ 明確強制（測試先行） | ❌ 無 TDD phase |
| SPEC.md 同步 | ✅ 階段 1 / 2.10 強制 hook | ❌ 無 |
| 文檔同步（README / CLAUDE） | ✅ 階段 4.4 / 4.5 hook | ❌ 無 |
| Branch / PR 管理 | ✅ 階段 2.2 / 3.4 / 4.6 | ❌ 無 |
| 實作階段深度 | 輕量委派（writing-plans / executing-plans） | 7-phase 深度結構化 |

**兩者非互斥，是上下層關係**：本 skill 在階段 2.3 可選擇啟用 `/feature-dev` 作為實作子流程（路徑 C），適合高複雜情境。

---

## 與既有資源的分工

| 職責 | 歸屬 |
|------|------|
| 編排 4 階段流程、決定何時啟用什麼 | **本 skill** |
| 需求確認、SPEC.md 建立 / 更新 | `maintaining-spec-md` skill |
| 需求設計討論（對話式、需求模糊時） | `superpowers:brainstorming` skill |
| 寫 plan（bite-sized TDD tasks） | `superpowers:writing-plans` skill |
| 執行 plan（批次 + checkpoint） | `superpowers:executing-plans` skill |
| TDD 紀律（測試先行） | `superpowers:test-driven-development` skill |
| 寫測試（具體產出） | `test-automator` agent（project-local） |
| Codebase 深度探索（複雜情境） | `feature-dev:code-explorer` agent |
| 多方案架構設計（中等複雜） | `feature-dev:code-architect` agent（2-3 並行） |
| 7-phase 一鍵全包（高複雜情境） | `/feature-dev` command |
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

#### 2.3 選擇規劃路徑（關鍵決策點）

依功能複雜度選擇 3 條互斥路徑之一：

| 情境 | 路徑 | 核心流程 |
|------|------|----------|
| 單檔案 bug fix、小功能、改動範圍明確 | **A（預設）** | `writing-plans` 直接寫 plan |
| 2-3 檔案新功能、需架構方案比較 | **B（中等複雜）** | 並行 `code-architect` agents → User 選 → `writing-plans` |
| 多檔案大重構、陌生 codebase、epic-level | **C（高複雜）** | `/feature-dev` 7-phase 一鍵全包 |

---

##### 路徑 A：輕量直寫（預設）

1. 啟用 `superpowers:writing-plans` skill 寫 plan（bite-sized TDD tasks）
2. 進入 2.4

**何時用**：日常 ticket、bug fix、小功能；已知如何實作，不需要多方案對比。

---

##### 路徑 B：多方案架構比較（中等複雜）

1. 並行委派 2-3 個 `feature-dev:code-architect` agent，各自聚焦不同方向：

```
# 並行呼叫（同一 message 內 3 個 Agent tool）
Agent({
  subagent_type: "feature-dev:code-architect",
  description: "Minimal-change architecture for <feature>",
  prompt: "Design a minimal-change architecture for <feature>. Focus on reusing existing abstractions..."
})
Agent({
  subagent_type: "feature-dev:code-architect",
  description: "Clean architecture for <feature>",
  prompt: "Design a clean architecture for <feature>. Focus on SOLID principles and proper layering..."
})
Agent({
  subagent_type: "feature-dev:code-architect",
  description: "Balanced architecture for <feature>",
  prompt: "Design a balanced architecture for <feature> weighing pragmatism against technical purity..."
})
```

2. 展示 2-3 方案的 trade-off 對比 → User 選擇
3. 啟用 `superpowers:writing-plans` skill 把選定方案轉為可執行 plan
4. 進入 2.4

**何時用**：有多種可行實作方式、想對比 trade-off 再決定；2-3 個檔案同時改動。

---

##### 路徑 C：`/feature-dev` 一鍵全包（高複雜）

執行 command：
```bash
/feature-dev <功能描述>
```

`/feature-dev` 會自動走完 7-phase：
1. Discovery — 釐清需求
2. Codebase Exploration — 2-3 個 `code-explorer` 並行探索
3. Clarifying Questions — 強制系統化澄清（不可跳過）
4. Architecture Design — 2-3 個 `code-architect` 並行產出方案
5. Implementation — 實作
6. Quality Review — 3 個 `code-reviewer` 並行審查
7. Summary — 完成文件

完成後**直接跳到本 skill 的階段 3**（`/feature-dev` 已內含實作與 review）。

**重要注意事項**：
- `/feature-dev` **不包含 TDD 強制**（須自行確保測試充分，建議 Phase 5 實作時搭配 `test-driven-development` skill）
- `/feature-dev` **不包含 SPEC.md 同步**（階段 1 仍須先走 `maintaining-spec-md` skill；結束後回頭更新 Status）
- `/feature-dev` **不包含 branch / PR 管理**（仍由本 skill 處理 2.2 與階段 3、4）

**何時用**：多檔案大重構、onboarding 新成員、陌生 codebase、epic-level 功能、需要強制結構化 clarification 與多方案對比。

---

#### 2.4 撰寫測試（Test-First）

路徑 A / B 必走此步；路徑 C 若 `/feature-dev` 未覆蓋測試，補上。

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
此 command 啟動多個 reviewer agents 並行（類似 `/feature-dev` Phase 6 的 3 維度並行 review：簡潔性 / bug / 慣例）。

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
- 最小修改 + 測試覆蓋該 bug
- PR 到 `main` 與 `dev`（雙分支）
- 事後補 `maintaining-readme-md` 檢查

### Refactor 不增新功能
- 仍遵循 TDD：先保證既有測試通過 → 重構 → 測試仍通過
- SPEC.md 通常不需更新（需求沒變）
- CLAUDE.md 若涉及架構改變則更新

### Spike / Prototype
- 建立 `spike/<name>` 分支（非正式 convention）
- 不強制 TDD
- 完成後：丟棄（刪分支）或採納（走正式階段 1-4）

### Debug 深入（系統化除錯）
啟用 `superpowers:systematic-debugging` skill — 適用於：
- Bug 原因不明需系統化排查
- 需建立 hypothesis → test → refine 循環
- Heisenbug、race condition 等棘手問題

### 多任務並行開發（大型改動）
啟用組合：
- `superpowers:using-git-worktrees` — 多分支隔離環境
- `superpowers:dispatching-parallel-agents` — 獨立任務並行派發

適用於：可拆分為 N 個互相獨立的子任務（例如同時改動 3 個服務）。

### 子任務外包（spec-driven）
啟用 `superpowers:subagent-driven-development` skill — 適用於：
- 子任務有明確規格（可用 yaml/json 或結構化 prompt 定義）
- 希望 subagent 獨立完成並驗證 spec compliance

---

## 自我檢查清單

### 啟動前
- [ ] User 的需求是新功能 / bug fix / refactor 哪一種？
- [ ] SPEC.md 是否已涵蓋此需求？
- [ ] 功能複雜度對應 2.3 哪條路徑（A / B / C）？

### 各階段過渡前
- [ ] 階段 1 → 2：SPEC.md 已更新且 User 確認？
- [ ] 階段 2 → 3：測試全綠 + coverage 達標 + SPEC Status 已更新？
- [ ] 階段 3 → 4：verification-before-completion 已通過 + PR 已建立 + CI 通過？
- [ ] 階段 4 完成：文檔已同步 + 分支已清理？

### 結束後
- [ ] 是否啟用 `maintaining-readme-md` 更新文檔？
- [ ] CLAUDE.md 若影響則啟用 `maintaining-claude-md`？
- [ ] SPEC.md Status 已從 In Progress → Completed？
