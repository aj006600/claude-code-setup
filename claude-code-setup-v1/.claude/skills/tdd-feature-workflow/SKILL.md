---
name: tdd-feature-workflow
description: 'Use when starting, resuming, or finalizing any feature / bug fix / refactor / multi-step code change. Triggers include "請幫我重構"、"我想要添加新功能"、"請幫我 debug"、handing over a spec or plan, "繼續" an in-progress feature, or opening a PR. Orchestrates the full 4-phase TDD lifecycle (requirement → plan & implement → pre-PR verification → review & merge) by delegating to superpowers skills, code-review, and maintaining-* skills at the right checkpoints. Trigger proactively even without explicit mention of "TDD" — stand-alone code changes without the discipline wrapper are how projects accumulate technical debt.'
---

# TDD Feature Workflow(本專案開發編排)

這個 skill 是本專案的**開發編排層**——扮演專案經理角色:負責完整開發生命週期的編排(需求 → 實作 → PR → merge → 文檔同步),在正確時機委派給正確的 superpowers skill、commands、agents、maintaining-* skills,並注入專案專屬細節(uv、pytest、coverage 目標、現行架構——以 `.claude/docs/architecture.md` 為準)。

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
| 需求設計討論 | `superpowers:brainstorming`(每次新需求都先走) |
| SPEC 更新 | `maintaining-spec-md` skill |
| 架構決策記錄(2+ 方案 trade-off) | `maintaining-decisions-md` skill(開 ADR 記 Why) |
| 寫 plan(bite-sized TDD tasks) | `superpowers:writing-plans`(plan 本身內建 TDD 循環) |
| 執行 plan(批次 + checkpoint) | `superpowers:executing-plans` |
| TDD 紀律參考 | `superpowers:test-driven-development`(查閱用,非獨立階段——詳見 2.4) |
| Bug 定位(debug 情境) | `superpowers:systematic-debugging`(僅 debug 流程前置;之後同階段 2-4) |
| 代碼簡化審查 | `code-simplifier:code-simplifier` agent |
| 完成前驗證 | `superpowers:verification-before-completion` |
| PR 前完整檢查 | `/pre-pr-check` command |
| Code review(對外寫回 PR / 對內返回對話) | `/code-review` command(5 agents 平行 + 過濾 + `gh pr comment` 寫回 PR)/ `superpowers:requesting-code-review`(dispatch `superpowers:code-reviewer` subagent、結果返回對話) |
| Review 反饋處理 | `superpowers:receiving-code-review`(verify 再實作、禁 performative agreement) |
| Push + PR 建立 | `superpowers:finishing-a-development-branch`(選 Option 2)或手工 |
| 文檔同步 | `maintaining-readme-md` / `maintaining-architecture-md` / `maintaining-claude-md` skills |
| PR Merge + 本地清理 | 手工 `gh pr merge` + `git checkout dev && pull && branch -d <feature-branch>` |

**補充資源(選配)**——以下為流程不變、可額外搭配的工具,Claude 應在符合情境時主動採用:

- `feature-dev:code-explorer` / `code-architect` — 需深度探索 codebase 或對比多個架構方案時

完整動態清單見 `/agent-cheatsheet`。

---

## 4 階段工作流程

### 階段 1:需求確認與設計

**目的**:SPEC.md 先行,實作跟著規範走。先與 User 討論釐清需求,再固化成 SPEC——避免 SPEC 草稿跑在理解前面。

```
User 提需求
    ↓
啟用 superpowers:brainstorming(對話釐清需求,需求明確時自動快速通過)
    ↓
[攔截]brainstorming 對話結束 → 跳過整個 "After the Design" 章節
    ↓
啟用 maintaining-spec-md → SPEC.md diff → User 確認
    ↓
進入階段 2(writing-plans 於階段 2 啟用)
```

**Hand-off 攔截**

`brainstorming` 結尾 "After the Design" 兩動作(階段 1 全部跳過):
1. Write `docs/plans/YYYY-MM-DD-<topic>-design.md` + commit
2. 詢問 "Ready to set up for implementation?" → 銜接 `writing-plans`

主對話線編排:
- brainstorming 對話結束 → 啟用 `maintaining-spec-md`(完整跳過第 1、2 步)
- `writing-plans` 銜接由階段 2 接管

**理由**:design.md 無 downstream consumer(`writing-plans` / `executing-plans` 皆不讀此檔,plan 產出基於 brainstorming 對話 context + 主對話線傳遞需求);省去 ceremonial 中介檔,階段 1 唯一必要產出為 `.claude/SPEC.md`。

**SPEC.md 啟動條件**:

- SPEC 完全沒此功能 → 啟動 `maintaining-spec-md` 新增章節
- SPEC 已包含但需修訂(範圍調整、允收標準變更、邊界條件補充、接口變動)→ 仍啟動 `maintaining-spec-md` 處理 diff
- SPEC 已完整覆蓋且無調整需求 → 可跳過 `maintaining-spec-md` 直接進階段 2

判斷原則:**有任何新增 / 修訂 → 一律先過 maintaining-spec-md**;只有「完全照舊」才跳過。

**為何強制先 brainstorming**:`superpowers:brainstorming` skill 本身已自適應——需求明確時 2-3 輪對話就結束,不會拖時間;但允許跳過會讓 Claude 與 User 自判「這個懂了」,誤判成本(先寫錯 SPEC → 實作偏方向 → 回頭重做)遠高於 brainstorming 的時間成本。討論必須在 SPEC 之前。

---

### 階段 2:規劃與實作(核心階段)

#### 2.1 前置檢查
執行 `/pre-dev-check` command;若檢查失敗,先修復再進 2.2。

#### 2.2 建立功能分支
```bash
git checkout dev && git pull origin dev
git checkout -b feat/<feature-name>  # 或 fix/* refactor/* hotfix/* 依 git-rules.md
```

#### 2.3 寫 plan(bite-sized TDD tasks)
啟用 `superpowers:writing-plans` skill。產出的 plan 中每個 task 本身已含完整 TDD 循環:`寫 failing test → 跑它失敗 → 最小實作 → 跑它通過 → commit`(見 writing-plans skill 的 Bite-Sized Task Granularity 章節)。因此階段 2 不需要在 plan 之外另外獨立「寫 failing test」步驟——該動作已是 plan 第一個 task 的第一個 step。

**Plan 路徑 override**:本 template 將 plan 寫到 `.claude/docs/plans/YYYY-MM-DD-<feature>.md`,覆寫 `superpowers:writing-plans` skill L18 預設路徑 `docs/plans/`。理由:plan 屬 Claude TDD 工作 artifact,與 `.claude/SPEC.md` 同 family 住 `.claude/`;`docs/` 留給 user-facing 技術文件(由 `maintaining-readme-md` 的 service / reference / guide 三類 template 管理),避免 `maintaining-readme-md` 掃目錄時難分辨、user team review 時被日期式檔名雜訊干擾。Override 屬純 prompt 層(`superpowers:executing-plans` 不寫死路徑、靠主對話線 hand-off 帶路徑),無需動 superpowers 本體。

**選配加強**(複雜功能):
- 深度探索 codebase → 委派 `feature-dev:code-explorer` agent
- 想對比多個架構方案 → 並行委派 2-3 個 `feature-dev:code-architect` agent(分別聚焦最小改動 / 清潔架構 / 實用平衡)

**測試檔案位置慣例**(寫入 plan 的 `Files` 欄位):
- 單元:`tests/unit/<module>/test_<feature>.py`
- 整合:`tests/integration/test_<feature>_integration.py`
- E2E:`tests/e2e/test_<feature>_e2e.py`

#### 2.4 執行 plan(TDD 循環 × N)
啟用 `superpowers:executing-plans` 批次執行 plan(含 checkpoint review),hand-off 時帶上 2.3 寫入的 `.claude/docs/plans/<filename>.md` 完整路徑(該 skill 不寫死路徑、靠主對話線提供)。每個 task 的 Step 1「寫 failing test」與 Step 2「watch it fail」由**主對話線親自**執行——TDD 紀律的核心是 bite-sized 紅綠節奏與親眼確認「測試真的在測對的行為」,主線親自執行才能保證這份觀察不失真,不委派給 sub-agent。

遇到 TDD 細節疑義(例如「這個 test 該怎麼寫才對」、「watch it fail 時失敗訊息不對」)→ 查閱 `superpowers:test-driven-development` skill 的 Red-Green-Refactor 原則作為紀律參考,**不將其獨立啟用為一個階段**(它的內容已被 plan tasks 內建)。

**專案專屬提醒**:
- 依 `.claude/docs/architecture.md` 的 Code Structure 將代碼放到對應模組
- 新增模組通常意味新 FR → 啟用 `maintaining-spec-md` 處理需求面;同時連動現行架構 → 啟用 `maintaining-architecture-md` 處理架構面;若該設計有 2+ 方案 trade-off → `maintaining-decisions-md` 開 ADR
- 遵循 `.claude/rules/code-style.md`(命名、type hints、docstring)與 `.claude/rules/testing-rules.md`(pytest 慣例、fixture、mocking、parametrize)
- 測試 / 覆蓋率指令依 architecture.md 的 Tech Stack 決定;coverage 目標 70%+ 由階段 3 的 `/pre-pr-check` 統一驗證
- 技術疑問 → 使用 `context7` MCP 查最新 library 文檔

**關於 executing-plans 的收尾行為**:

1. `superpowers:executing-plans` Step 5 在所有 batch 完成後**自動**呼叫 `superpowers:finishing-a-development-branch`(彈出 4 個選項:merge locally / push+PR / keep as-is / discard)
2. 本 skill 的階段 3(完成前驗證)**必須在 Step 5 之前**執行
3. **介入點**:executing-plans 每個 batch 完成時會「Ready for feedback」暫停等 User——主對話線利用此暫停點切入階段 3.1-3.3
4. 階段 3 驗證通過後再讓 `finishing-a-development-branch` 被呼叫,選 **Option 2 (Push and create a Pull Request)**,對應階段 3.4

#### 2.5 回寫 SPEC.md 的實作發現
若實作中產生新的 Acceptance、邊界條件、或需求細節變化 → 啟用 `maintaining-spec-md` 回寫 SPEC,並勾選已達成的 Acceptance Criteria checkbox。沒有變化可跳過;SPEC 本身不追蹤進度(進度由 git branch / PR merge 反映)。

---

### 階段 3:完成前驗證 + Push + PR

#### 3.1 完成前強制自檢
啟用 `superpowers:verification-before-completion`——強制以剛跑過的命令輸出作為 evidence,禁「should pass」「probably works」等未驗證用語。與 3.2 互補:3.1 是紀律(必須 evidence 才能宣稱完成)、3.2 是實際產生 evidence 的動作。

#### 3.2 執行 `/pre-pr-check` command
- Level 1(測試+coverage 合併 hard gate,`pytest --cov-fail-under=70`)失敗 → 回 2.4 修復
- Level 2(code-simplifier、external-ref body scan)→ 視情況處理
- Level 3(SPEC / README 提示)→ 啟用對應 maintaining-* skill

注意:`/pre-pr-check` 不重跑 ruff / format / mypy(CI 為這些工具的權威 pre-merge gate);若需本地驗證請手動跑或裝 IDE / pre-commit hooks。

#### 3.3 處理 `code-simplifier:code-simplifier` 建議

Agent 結果出來後**不是僅 warning**,執行五步:

1. **詳細呈現**給 User 每條建議:具體位置、修改前後對比、agent 的理由
2. **CLAUDE 附上自己的判斷**:每條標 `[強烈建議]` / `[可選]` / `[不同意](理由)`——不要純 relay agent 輸出
3. **與 User 討論**決定採納哪些,明確取得決定
4. 採納的條目 → **回階段 2 走 TDD**:把採納的簡化建議當成新的 plan task(必要時擴充原 plan 或建小型 plan),經 `writing-plans → executing-plans` 處理。即使是「只動兩三行」的小簡化,仍走紅綠循環——red-green-refactor 紀律不因「簡化」二字就豁免。改完回階段 3 重跑 `/pre-pr-check`
5. 不採納的條目 → 記錄理由到 PR description,方便 review 階段討論

#### 3.4 Push + PR 建立(二選一)

**`superpowers:finishing-a-development-branch`**:階段 2.4 結束時 `executing-plans` 已準備呼叫此 skill——3.1-3.3 驗證通過後讓它呼叫,選 **Option 2 (Push and create a Pull Request)**。skill 會自動跑 `git push -u` + `gh pr create`。**注意**:該 skill 預設 PR base 為 `main`;本 template 分支策略為 `feat/* → dev`,故 PR 建立時需覆寫 `--base dev`(或建立後以 `gh pr edit --base dev` retarget)。

**手工**:依 `.claude/rules/git-rules.md` 格式 commit → `git push -u origin <branch>` → `gh pr create --base dev`。

SPEC.md 變更須獨立 commit。

---

### 階段 4:Code Review 與 Merge

#### 4.1 Code review(二選一,或先對內後對外並用)

**結果回寫 PR comment(對外,供 reviewer 參考)**:
執行 `/code-review` command(`code-review` plugin 提供)。command 會用 5 個 Sonnet agents 平行掃 5 個面向(CLAUDE.md 合規 / 淺層 bug / git blame 歷史 / 歷史 PR comments / 代碼註解),每個 issue 經 Haiku 評分(<80 分丟掉),最後以 `gh pr comment` 寫回 PR 頁。

**結果返回對話(對內,主對話線消化)**:
依 `superpowers:requesting-code-review` skill 指引 dispatch `superpowers:code-reviewer` subagent——抓 `BASE_SHA` / `HEAD_SHA`、填 bundled template prompt、問題清單在對話中返回;Critical / Important / Suggestions 分級與 plan alignment 環節適合 TDD workflow。

發現問題 → 回階段 2 修改,遵循 TDD。

#### 4.2 處理 review 反饋
依 `superpowers:receiving-code-review` skill 原則處理:
- **Verify 再實作**:check 建議對 this codebase 是否技術正確、是否會 break 現有功能、是否 YAGNI
- **禁 performative agreement**:直接述技術回應或著手修,不說「You're absolutely right!」「Great point!」「Thanks for catching that!」
- **不懂就問**:不完全理解的 item 先 clarify 再動手,不部分實作
- **錯誤建議 pushback**:以技術理由回應,不為舒適感屈從
- 需要改碼的建議 → 回階段 2 走 TDD

#### 4.3 更新 User-facing 文檔(若變更影響 User)
啟用 `maintaining-readme-md`——skill 會判斷狀態並把文檔更新加入同一 PR(merge 前)。

#### 4.4 同步現行架構 / 決策史 / 規範

逐項對照,命中即啟用對應 skill:

- **現行架構 / Tech Stack / 目錄變更**(新增 / 移除模組、換框架、加依賴、目錄重組)→ `maintaining-architecture-md` 更新 architecture.md
- **架構決策**(2+ 方案 trade-off、引入新機制、推翻既有設計)→ `maintaining-decisions-md` 開 ADR(既有 ADR 被取代則改 Status + 開新 ADR)
- **開發規範 / 流程**(新 coding convention、測試策略、Git / CI 流程、效能 / 安全 / 合規限制)→ `maintaining-claude-md`(+ CLAUDE-CHANGELOG.md)
- **SPEC.md 連動**:Project Overview 變更帶來新開發原則時連動 CLAUDE.md

皆不觸發(純功能新增)→ 跳過。

#### 4.5 Merge 與本地清理
PR 通過 review + CI + 文檔同步後:

```bash
# Merge PR(GitHub 網頁點 merge 或用 gh)
gh pr merge <PR#> --merge   # 或 --squash / --rebase 依專案偏好

# 本地回 dev 同步
git checkout dev
git pull origin dev

# 刪本地 feature 分支(遠端通常由 GitHub 自動刪;若未自動刪:git push origin :feat/<name>)
git branch -d feat/<feature-name>
```

---

## 特殊情境

- **Debug(bug 修復的完整流程)**:階段 1 的需求討論替換為 `superpowers:systematic-debugging`(hypothesis → test → refine 循環)定位 root cause;產出「可重現的 bug 描述 + reproducing 條件」後,之後完全走階段 2-4——`writing-plans` 產出 bite-sized plan(reproducing test 就是 plan 的第一個 task)→ `executing-plans` 執行 → 驗證 → PR → review → merge。**無論單點還是多模組 bug,都走同一條路徑**;避免「這個 bug 很小直接改」的 judgement 誤判(判斷錯了會跳過 plan → 修完才發現其實涉及多處)
- **Hotfix**:流程同 Debug,差別只在分支基底與 PR target——從 `main` 建 `hotfix/<bug-name>`,PR 到 `main` 與 `dev` 雙分支,事後補 `maintaining-readme-md` 檢查
- **Refactor 不增新功能**:仍走 `writing-plans → executing-plans`(既有測試通過 → 重構 → 測試仍通過);SPEC 通常不需更新;architecture.md 若涉現行架構改變則更新(連動 `maintaining-architecture-md`),有決策 trade-off 則 `maintaining-decisions-md` 開 ADR
- **Spike / Prototype**:建 `spike/<name>` 分支,期間不強制 TDD;**採納必須重寫走正式階段 1-4**,不直接 merge spike 代碼

---

## 階段轉場 Gate

每階段進入下一階段前必須滿足的前提。任一 gate 未達 → **不得進入下一階段**:

| 轉場 | Gate |
|------|------|
| 1 → 2 | `.claude/SPEC.md` 已含本次需求的 FR + Acceptance Criteria,User 確認 diff(新增 / 修訂或「完全照舊」明確判斷) |
| 2 → 3 | 所有 plan tasks 完成(executing-plans Step 4 結束)+ 全測試綠 + 實作中產生的新需求 / 細節變化已回寫 SPEC(若有) |
| 3 → 4 | `/pre-pr-check` 全通過(含 coverage 70%+)+ code-simplifier 建議已處理 + verification-before-completion 通過 + PR 已建立 + CI checks 通過 |
| 4 完成 | 文檔同步(README / architecture / decisions / CLAUDE 視情況)+ PR merged + 分支已清理(local + remote) |

這比 TDD 更高層——**即使測試全綠,若本次改動產生的新需求 / 細節變化未寫回 SPEC,下次對話的 Claude 會失去 context 重複踩同樣的坑**。

---

## Gotchas(容易忘記的關鍵點)

- **`code-simplifier` 建議 → 回階段 2 走 TDD,不就地 inline 改**:每條採納建議當新 plan task 處理(寫/更新 failing test → watch fail → 改 → watch pass → 重跑全測試),不在驗證階段直接動代碼;原因見 3.3 step 4
- **文檔同步在 merge 前**(階段 4.3 / 4.4):一旦 merge 回 dev,需改走 `maintaining-readme-md` 狀態 D 補救流程,多一步工
- **`superpowers:finishing-a-development-branch` 對應階段 3.4「Push + PR 建立」,不是 phase 4 的 merge 清理**:該 skill 的 4 個 options(merge locally / push+PR / keep / discard)語意對應「實作完成後如何整合」;`executing-plans` Step 5 為 REQUIRED SUB-SKILL 會自動觸發它,本 skill 利用此時點選 Option 2 完成 push+PR。Phase 4.5 的 PR merge + 本地清理直接用 `gh pr merge` + git 命令(注意 base 預設為 main,本 template 需 `--base dev`)
