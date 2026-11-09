# V1 Setup Development Notes

開發 claude-code-setup-v1 過程中的筆記、Q&A、待辦事項。

## Skills & Plugins 分析

### feature-dev 7-Phase 速覽

| Phase | 說明 |
|-------|------|
| 1. Discovery | User + Claude 釐清需求 |
| 2. Codebase Exploration | 2-3 個 code-explorer agent 並行探索代碼（entry point + file:line） |
| 3. Clarifying Questions | Claude 系統化列出歧義，User 回答（強制、不可跳過） |
| 4. Architecture Design | 2-3 個 code-architect agent 並行產出方案（最小改動 / 清潔架構 / 實用平衡），User 選 |
| 5. Implementation | Claude 實作（需明確核准才開始） |
| 6. Quality Review | 3 個 code-reviewer agent 並行（簡潔 / bug / 慣例），信心度 >= 80 才報告 |
| 7. Summary | 完成文件 + 決策記錄 |

### superpowers Plugin（13 Skills + 1 Agent）

| 資源 | 定位 |
|------|------|
| brainstorming | 需求 -> 設計文檔（對話式） |
| writing-plans | 設計 -> bite-sized TDD tasks（需 worktree） |
| executing-plans | 批次執行 plan + checkpoint review |
| test-driven-development | TDD 紀律（測試先行） |
| subagent-driven-development | spec-compliance + subagent dispatch |
| using-git-worktrees | 多分支隔離環境 |
| dispatching-parallel-agents | 獨立任務並行派發 |
| requesting-code-review | 建立 code review checklist |
| receiving-code-review | 接收 review 反饋並處理 |
| systematic-debugging | 系統化 debug |
| verification-before-completion | 聲稱完成前強制自檢 |
| finishing-a-development-branch | 分支整合決策（merge + cleanup） |
| using-superpowers | meta: skill discovery |
| code-reviewer（agent） | 計劃合規審查 |

### finishing-a-development-branch 重疊分析

此 skill 與 tdd-feature-workflow 的階段高度重疊：

| finishing-a-development-branch 步驟 | 在 tdd-feature-workflow 中的對應 |
|--------------------------------------|----------------------------------|
| Step 1: Verify tests | 已在階段 3 做過 |
| Step 2: Determine base branch | 已在階段 2.2 git checkout -b 確定 |
| Step 3: 呈現 4 個選項（merge / PR / keep / discard） | 階段 4.6「合併與清理」 |
| Step 4: 執行選擇 | 同上 |
| Step 5: Worktree cleanup | 同上 |

### TDD Skill 與 executing-plans 的關係

- `writing-plans` 產出的 plan，每個 task 本身就是 bite-sized TDD 循環（plan SKILL.md L22-28 與 L56-87 明訂）：寫 failing test -> 跑它失敗 -> 最小實作 -> 跑它通過 -> commit 五步
- `executing-plans` 只是「按 plan 逐步執行」 -- plan 已經把 TDD 烙在每個 task 裡，executing-plans 跟著跑就是 TDD
- `test-driven-development` skill 的定位是獨立紀律參考，在「沒有 plan 的情境」或「plan 執行中遇到 TDD 細節問題」時查閱，不是 writing-plans -> executing-plans 之間強插的一環

### Code Review 工具比較

| 工具 | 觸發方式 | 行為 |
|------|----------|------|
| `/code-review` | 只能對已建立的 PR 操作 | 5 個 Sonnet agents 平行跑 5 面向（CLAUDE.md 合規 / 淺層 bug / git blame / 歷史 PR comments / 代碼註解），每個 issue 經 Haiku 評分過濾（<80 丟掉），用 `gh pr comment` 寫回 PR |
| `superpowers:code-reviewer` agent | 對 BASE_SHA..HEAD_SHA 範圍 | 結果直接返回對話，不寫 PR |

## TODO / 待確認事項

### Setup 功能

- [ ] `pre-pr-check` 流程再釐清（好像很複雜？再說明一遍？）
- [ ] 再次確認 `project-status`、`pre-pr-check` 這兩個 command
- [ ] `claude.md` 變成可添加專案特定的 memory 功能
- [ ] 確認幾個常用的 prompt 詞彙測試啟用的 skill
- [ ] 技術疑問 -> 使用 `context7` MCP 查最新 library 文檔 -> 少了 github mcp，未來會增加 `/graphify`
- [ ] global CLAUDE.md 也提到不要 emoji
- [ ] Memory 存哪？可不可以 by project？（Memory 存了兩條：「不用負面描述提及禁用做法」與「CHANGELOG 授權代寫」，下次對話自動帶入）
- [ ] 是不是有重複的 plugin

### 開發流程

- [ ] README.md 要講要怎麼連結到 repo
- [ ] 暫時拿掉 workflow 檔案（CI 有問題）
- [ ] 好像不會自己創 main、dev、qas，且一切以 dev 為主
- [ ] 沒有寫 SPEC
- [ ] 現在是不是只是在 worktree 裡面創分支，而不是真的平行在 worktree 裡面創多個分支平行進行
- [ ] CLAUDE.md 也沒改
- [ ] 平行搬到 v2 去處理，然後要一個 to-be 清單上面說未來想要什麼功能（CI、平行）
- [ ] mypy strict + ruff 是什麼？還有哪些 test 或 CI？
- [ ] 對 main 操作
- [ ] 有時候會沒有進 tdd skill 裡面
- [ ] `docs/plan` 有沒有辦法改到 `.claude/docs/plan/` 或跟 claude 本身一樣放到 `/tmp`

### Bug

- [ ] GitHub CI 都會失敗

## Session 筆記

### Pre-dev 檢查結果（某次 session）

```
Branch:        dev (d76cd52 spec: initial specification)
Uncommitted:   clean
origin/dev:    not exist（尚未 push 到 remote）
```

Phase 2.2 預期從 origin/dev pull，但 remote 還沒任何 branch。推薦先 push 三條 branch：`git push -u origin main dev qas`，remote 與 local 對齊，之後 PR 才能正常建。

### Plan 執行選項

| 選項 | 說明 | 適用情境 |
|------|------|----------|
| 1. Subagent-Driven（本 session） | 每個 task 開一個 fresh subagent 實作，task 之間做 code review，快速迭代 | 想看每個 task 的進展、即時 feedback |
| 2. Parallel Session（另開 session） | 另開 session 用 `superpowers:executing-plans` 批次跑，有 checkpoint review | 想釋放本 session 做別的事 |

`tdd-feature-workflow` Phase 2.4 預設指向 executing-plans（選項 2 的形式）。想留在當前 session 看進度也可以選 1。
