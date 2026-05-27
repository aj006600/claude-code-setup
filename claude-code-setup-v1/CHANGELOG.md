# Changelog

All notable changes to the **claude-code-setup-v1 template itself** will be documented in this file.

This tracks the evolution of the template (skills, commands, hooks, rules, README, CI workflow, and the bundled `.claude/CLAUDE.md` baseline). For tracking changes to **your own project's** `.claude/CLAUDE.md` after adopting this template, use `.claude/CLAUDE-CHANGELOG.md` — which ships as an empty seed for you to populate.

The format is based on [Keep a Changelog v1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

變更分類說明：
- **Added**：新增功能（skill、command、hook、rule、章節等）
- **Changed**：修改既有功能的內容或細節
- **Deprecated**：即將移除但暫時保留的功能
- **Removed**：移除的功能
- **Fixed**：修正錯字、邏輯錯誤、矛盾描述
- **Security**：安全相關變更

---

## [Unreleased]

<!-- 尚未發布的變更累積於此。發版時改為 `## [vX.Y.Z] - YYYY-MM-DD` 並新增一個新的 Unreleased 區塊。 -->

---

## [v1.26.0] - 2026-05-27

**主軸:** 引入「決策文件系統」,補上 template 一直缺的 **Why 層**(決策史),並用「按軸分離 + 單一真相 + 交叉連結」重整文件架構。對照 work-repo 的 `.claude/docs` 概念、研究 GitHub `spec-kit` 與 `oh-my-claudecode` 後 right-sizing 而成(取精煉版,非照搬重量級 conventions)。決策脈絡見 `docs/journal/journal.md` ADR-0001 ~ ADR-0007。

### Added
- **journal 決策系統(ship 給 adopter)**:新增 `.claude/docs/journal/CONVENTIONS.md`(精煉版 journal 撰寫規範:ADR + Lessons + Timeline 為核心,Postmortem 選配,約 240 行)與 `.claude/docs/journal/journal.md`(空種子,比照 `CLAUDE-CHANGELOG.md` 模式)。補上「為什麼這樣決定」這層——code 說 What/How、git log 說 When,而 Why 最易隨人員流動蒸發。研究發現連 spec-kit 都缺持久 ADR 層,這是最具差異化的一塊。見 ADR-0001
- **`maintaining-journal-md` skill**:在決策點(2+ 方案 + trade-off)觸發寫 ADR、事故寫 Postmortem(選配)、戰術經驗寫 Lesson、里程碑更新 Timeline
- **`.claude/docs/architecture.md`(現行架構描述)**:template placeholder 形態,承接「系統現在長什麼樣」(系統圖 + Components + Tech Stack + Code Structure + Design Decisions 索引,cross-ref ADR)。對齊 spec-kit 的 constitution/spec/plan 軸分離。見 ADR-0002 / ADR-0003
- **`maintaining-architecture-md` skill**:維護 architecture.md,維持「一份 doc SoT 對一個 maintainer」對稱(maintenance skills 由 3 增至 5)。見 ADR-0007
- **SPEC.md 精簡升級**:`spec-template.md` 新增可量化且 technology-agnostic 的 **Success Criteria** section 與 `[NEEDS CLARIFICATION: <問題>]` 標記慣例(取自 spec-kit 的高 CP 值項目,不引入 P1/P2/P3 user stories 全套)。見 ADR-0004
- **`/pre-pr-check` 跨文件一致性掃描(L2.3)**:借 spec-kit `/analyze` 概念,自動驗 `[NEEDS CLARIFICATION]` 殘留、ADR Status 與 Decision Index 一致、cross-ref 連結可解析、footer 版本一致——以工具取代手動 health check。見 ADR-0005
- **`docs/journal/journal.md`(template 自身,不 ship)**:dogfood 本次優化的 ADR-0001 ~ ADR-0007 + Lessons + Timeline,與 `CHANGELOG.md` 同級、用 template 自己 ship 的 CONVENTIONS 維護

### Changed
- **`.claude/CLAUDE.md` 回歸純 constitution**:Architecture 樹與 Tech Stack 兩節移出至 architecture.md,改為指向 architecture.md / SPEC / journal 的指標表;Available Resources 補列兩個新 skill
- **既有 skill 路由全面同步**:`maintaining-claude-md`(範圍邊界、觸發表、placeholder、pattern、互動表、description 去除 tech/arch 觸發避免誤觸)、`maintaining-spec-md`(下游路由改指 architecture.md、加 Success Criteria / NEEDS CLARIFICATION)、`maintaining-readme-md`(上游來源加 architecture.md)、`tdd-feature-workflow`(關鍵分工表加 journal、phase 4 文檔同步加 architecture / journal、架構引用改 architecture.md)
- **`documentation-style.md`**:footer 需 / 不需清單納入新檔;標題語言豁免納入 `journal/CONVENTIONS.md`;architecture.md 適用標準規則、journal.md 比照 CHANGELOG
- **`/project-status`**:File versions 加讀 architecture.md footer
- **`README.md`**:What's Included(3 → 5 maintenance skills + 文件軸分離說明)、Template 結構樹(加 architecture.md / journal / template 自身 docs)、Overview

### Removed
- `.claude/CLAUDE.md` 的 **Tech Stack** 與 **Architecture** 兩節:移至 `.claude/docs/architecture.md`(現行架構單一 SoT);CLAUDE.md 只保留指標連結,避免 constitution 與 how/tech 混居造成雙頭維護。見 ADR-0003

---

## [v1.25.1] - 2026-04-28

### Changed
- `tdd-feature-workflow/SKILL.md` description 中文觸發詞改為更貼近 user 自然中文句式:`"實作 X"、"開發 Y"、"修 bug"、"refactor"` → `"請幫我重構"、"我想要添加新功能"、"請幫我 debug"、"請分析"`。description 是 Claude Code skill 觸發語意匹配對象,觸發詞越貼近 user 實際說法、skill 自動觸發精度越高;原模板化短語(英中混雜「實作 X / 開發 Y」)較少在實際對話中出現,容易讓真實 user query 漏觸發本 skill

---

## [v1.25.0] - 2026-04-28

### Added
- `README.md` Quick Start 新增 Step 4「設定 GitHub remote」(原 Step 4 順移為 Step 5):`uv init` 已自動 `git init` 但 remote 須手動設定;若跳過此步,user 首次 `git push` 才會發現未設 remote 屬可預防的 surprise。明示用 HTTPS remote(`git remote add origin https://...`),Step 4 只設不 push,實際 push 由 Step 5 完成首個客製化 commit 後執行。Quick Start 標題從「4 步驟」改為「5 步驟」
- `README.md` 新增 `## Troubleshooting` 章節(FAQ 與 Advanced Customization 之間):首條覆蓋「Push 被 GitHub 拒,PAT 缺 workflow scope」場景。本 template 含 `.github/workflows/ci.yml`,首次 push 若 user 用 HTTPS + PAT 認證且 token 無 `workflow` scope 會被 GitHub 擋(典型訊息:`refusing to allow a Personal Access Token to create or update workflow ... without "workflow" scope`),屬高頻採用門檻。列三個解法(`gh auth login` 重登、改 SSH、PAT 加 scope);Step 4 末段加 cross-link 指向此區

---

## [v1.24.0] - 2026-04-28

### Changed
- `tdd-feature-workflow/SKILL.md` 階段 2.3 / 2.4 加入 plan 路徑 override:本 template 將 plan 寫到 `.claude/docs/plans/YYYY-MM-DD-<feature>.md`,覆寫 `superpowers:writing-plans` skill L18 預設路徑 `docs/plans/`。理由:plan 屬 Claude TDD 工作 artifact 與 `.claude/SPEC.md` 同 family 住 `.claude/`;`docs/` 留給 user-facing 技術文件(由 `maintaining-readme-md` 的 service / reference / guide 三類 template 管理),兩者混在同一目錄會讓 `maintaining-readme-md` 掃目錄時難分辨、user team review 時 `docs/` 充斥日期式檔名屬雜訊。Override 為純 prompt 層(`superpowers:executing-plans` Step 1 不寫死路徑、由主對話線 hand-off 提供),無需動 superpowers 本體。階段 2.4 同步說明 hand-off 帶 plan 完整路徑給 executing-plans
- `.claude/CLAUDE.md` Architecture 樹與 `README.md` Template 結構樹同步加入 `.claude/docs/plans/` 條目,標註「Claude TDD 工作 plan,由 superpowers:writing-plans 產出,非 user-facing」;README 樹順手調整 `hooks/` 從末位改為倒數第二,讓 `docs/plans/` 接到末位(user 採用 template 後才會自動產生此目錄,放末位語意較對)

---

## [v1.23.0] - 2026-04-28

### Removed
- `tdd-feature-workflow/SKILL.md`「補充資源(選配)」段移除 `superpowers:dispatching-parallel-agents` + `superpowers:using-git-worktrees` bullet:V1 排除原因為單人 dev 對「多獨立 sub-task 並行」痛感不強、心智負擔超過收益,獨立模組變更需有明確並行價值才值得引入相關工具與心智模型。同條目連動移除自 `README.md` Prerequisites 表 superpowers 條目。V2 演進方向移到 `ROADMAP.md` Wishlist
- `tdd-feature-workflow/SKILL.md` 階段 1 design.md 理由段 downstream consumer 列表移除 `superpowers:subagent-driven-development`:該 skill 已在 v1.18.0 評估後不適配本 template 工作模型(衝突 phase 2.4「主對話線親自看紅綠」核心紀律),不再列為 downstream consumer 候選對象。原文剩下 `writing-plans` / `executing-plans` 兩條主流程 consumer,「design.md 無 downstream consumer」論證仍成立。V2 評估方向同步入 `ROADMAP.md` Wishlist

### Added
- `ROADMAP.md` Wishlist 加入兩條 V2 演進方向(`superpowers:subagent-driven-development` 整合評估、`superpowers:using-git-worktrees` + `dispatching-parallel-agents` 並行模式評估),各附 V1 排除原因 + V2 評估點作為 future context;避免 V2 重新評估時失去歷史,循環踩同樣的坑

### Changed
- `README.md` footer 從 v1.20.0 同步至 v1.23.0:v1.21.0 / v1.22.0 兩次 ship 時 footer 漏 bump 屬上版疏漏,本版一次補回。footer 兩欄(`Template Version` / `Last Updated`)恢復與 CHANGELOG 一致

---

## [v1.22.0] - 2026-04-28

### Added
- `claude-code-setup-v1/ROADMAP.md`:V2 設計藍圖與 wishlist 追蹤檔。極簡結構(`# Roadmap` + `## Wishlist` 單一章節)留 placeholder 由 user 自由條列;不承諾時程,純記錄演進方向

### Fixed
- `/pre-pr-check` Level 3 sync hints 缺漏 CLAUDE.md:原 L3.1(SPEC.md)+ L3.2(README)雙 hint 結構漏掉 CLAUDE.md,PR 前無提示「本次改動是否影響開發規範 / 專案結構 / 工作流程 / 專案需求 / SPEC 連動」,造成 CLAUDE.md 即使 `maintaining-claude-md` 觸發情境命中也不會被啟用。新增 L3.3 對照 `maintaining-claude-md` 5 類觸發情境逐項 check,任一命中 → hint 啟用 `maintaining-claude-md`;Final report 範例同步加 L3.3 範例行
- `tdd-feature-workflow/SKILL.md` Phase 4.4 觸發條件過窄:原寫「若影響架構 / tech stack」只蓋 `maintaining-claude-md` 5 類觸發情境的 1 類(專案結構),漏掉開發規範 / 工作流程 / 專案需求 / SPEC 連動 4 類。展開為 5 類清單(與 `maintaining-claude-md` 觸發情境表 SSOT 對齊),Phase 4.4 在 PR review 通過後逐項 check
- `/pre-dev-check` 缺漏 branch topology 檢查:原只檢查 uncommitted + origin/dev 同步,直接假設 main / dev / qas 三條長期分支存在。fresh repo 或只有 main 的 repo 採用 template 後,Phase 2.2 的 `git checkout dev && git pull origin dev` 會直接 fail。新增 Check 1(Branch topology)檢查 local + origin 是否存在三條長期分支;缺漏時列出建立指令給 user 確認(動 git 結構需 user 同意,不自動執行)。原 Check 1 / 2 順移為 2 / 3,Report 同步加 topology 行

### Changed
- `.claude/CLAUDE.md` 常用 commands 清單同步反映新增功能:`/pre-dev-check` 描述加 `branch topology`、`/pre-pr-check` 描述加 `CLAUDE.md hints`

---

## [v1.21.0] - 2026-04-28

### Fixed
- `tdd-feature-workflow/SKILL.md` 階段 1 編排 bug:`superpowers:brainstorming` skill 結尾的 `## After the Design` 章節會自動指示 Claude (a) 寫 `docs/plans/YYYY-MM-DD-<topic>-design.md` + commit、(b) 詢問 "Ready to set up for implementation?" 並銜接 `superpowers:writing-plans`。原階段 1 流程圖只用「啟用 maintaining-spec-md」這類抽象敘事編排,具體性弱於 brainstorming 的明確檔名 + commit 指令——主對話線進入 brainstorming context 後跟隨第三方 skill 的 hand-off,寫了 design.md 並直接進 writing-plans,跳過 `maintaining-spec-md` 整個 SPEC.md 環節,造成需求未經討論就進實作。修正方式:階段 1 新增「Hand-off 攔截」小節,明確列出 brainstorming `## After the Design` 兩動作 + 主對話線 override 路徑(brainstorming 對話結束 → 直接啟用 `maintaining-spec-md`,完整跳過寫 design.md 與 writing-plans 銜接;writing-plans 留到階段 2 啟用)。同時新增 Artifact 分工明示 design.md 在 superpowers 各下游 skill(`writing-plans` / `executing-plans` / `subagent-driven-development`)中皆無 downstream consumer(plan 產出基於 brainstorming 對話 context + 主對話線傳遞需求),屬 ceremonial 中介檔——階段 1 唯一必要產出為 `.claude/SPEC.md`。流程圖同步更新標 `[攔截]` 節點,階段 1 → 2 gate 從「SPEC.md 已更新 + User 確認」精緻化為「`.claude/SPEC.md` 已含本次需求的 FR + Acceptance Criteria,User 確認 diff(新增 / 修訂或『完全照舊』明確判斷)」明示通過條件

---

## [v1.20.0] - 2026-04-27

### Changed
- `README.md` L28 「4 Maintenance Skills」分類錯誤修正:`tdd-feature-workflow` 是開發編排器(於關鍵節點委派 superpowers / code-review / maintaining-* 等 skills),不屬於文檔維護。拆為兩個 section——`### 3 Maintenance Skills`(三個 maintaining-*)+ `### 1 Workflow Orchestrator Skill`(tdd-feature-workflow)。對齊 CLAUDE.md L140-141 既有的「開發編排器 vs 專案文檔維護」分類
- `README.md` Prerequisites 表 `superpowers` 條目從「列 6 個 + 等 skills」改為完整列出 `tdd-feature-workflow` 實際引用的 12 個 skills 並指向 SKILL.md「關鍵分工」表為 SSOT。原寫法的「等」字讓讀者誤以為是「主要那 6 個」,實際上 tdd-feature-workflow 還用到 systematic-debugging / requesting-code-review / code-reviewer / receiving-code-review / dispatching-parallel-agents / using-git-worktrees 等 6 個未列出的 skills

### Fixed
- `documentation-style.md` L3 適用範圍與 rule 自身行為矛盾修正:原寫「適用於所有 markdown 檔案」並規定「章節標題用英文」,但 documentation-style.md 自身與 testing-rules.md 都使用中文章節。明確收緊 scope 為「user-facing markdown 檔案」,並加註 `.claude/rules/*.md` 與 `.claude/skills/**/SKILL.md` 不在「章節標題用英文」規則範圍內(footer / Markdown 結構 / Mermaid 等其他規則仍適用)。避免未來 Claude session 讀到此 rule 後誤判為「需要把所有 rules 改英文」做出不必要的重構提案

---

## [v1.19.0] - 2026-04-27

### Fixed
- `.claude/CLAUDE.md` L45 架構樹遺漏的 `agents/` 目錄行:v1.18.0 已從 template 移除整個 `.claude/agents/` 目錄,但 CLAUDE.md 範例架構樹仍保留 `agents/  # Sub-agents` 條目。CLAUDE.md 每次對話載入,這條過期描述會誤導 Claude 推理「應該有本地 agents」並影響後續委派決策
- `maintaining-claude-md/SKILL.md` Workflow A 的 placeholder 偵測邏輯壞掉:Step A1 的 grep 字面查 `<Placeholder>`(13 個字)、`<YourName>`、`your-email@example.com`,但 template CLAUDE.md 實際使用 `<Project Name>` / `<your framework, ...>` / `<your-modules>` 等語意化命名,且 `<YourName>` / `your-email@example.com` 已在更早版本(見 v1.15.0 CHANGELOG)從 template 移除——整個 grep 唯一會命中的是 `<!-- TEMPLATE NOTICE`,placeholder 偵測實質失效。改為:Step A1 先以 `<!-- TEMPLATE NOTICE` 為唯一可靠的「未客製化」訊號,確認後再用 `<[a-zA-Z][^>]*>` 通用 pattern 列出所有實際 `<...>` placeholder 作為 dry-run 與 Edit 對象。連動清理:skill description、Step A2 placeholder 對照表、Step A4 替換步驟全部移除已不存在的 `<YourName>` / `<your-email@example.com>` 條目
- `README.md` Quick Start L130 描述同步:從「批次替換 `<YourName>` / `your-email@example.com`」改為「依對話填入 `<...>` placeholder」,反映 skill 修正後的真實行為

### Changed
- `tdd-feature-workflow/SKILL.md` L43 與 L159 移除 `/commit-push-pr` command 引用:該 command 來自 `commit-commands` plugin 但 README Prerequisites 從未列入此依賴,user 照 README 安裝後跑到 SKILL 才發現缺。SKILL 同段已並列 `superpowers:finishing-a-development-branch`(選 Option 2)與「手工」兩條完整路徑,中間多列一個需額外裝 plugin 的便利包裝屬冗。移除後 push+PR 路徑收斂為兩條,Prerequisites 表保持只列真正必需的依賴
- `agent-cheatsheet.md` L29 scope tag 範例更新:原寫「例:`feature-dev:code-reviewer` plugin agent vs 任何同名 entry」假設本地 agents 與 plugin agents 可能同名衝突,但 v1.18.0 已移除所有本地 agents 此情境消失。改為「例:plugin agents 與 global skills 同名時」反映實際剩下的衝突情境

---

## [v1.18.0] - 2026-04-27

### Removed
- `.claude/agents/` 整個目錄(`code-reviewer.md` / `documentation-engineer.md` / `test-automator.md` 三檔):這些 local agents 是泛用 boilerplate(疑似從某 generic agent collection 複製),問題密集——(a) 與 setup 完全脫鉤:寫死 `coverage > 80%` 與本 setup 70% target 衝突、`test-automator` 整檔圍繞 UI/Mobile/Selenium 但本 setup 是 pytest backend、`documentation-engineer` 是「文件網站工程師」級別(Sphinx/MkDocs 風格,談 `Page load time < 2s` / `WCAG AA` / `Search functionality`)但本 setup 只寫 markdown;(b) 引用一堆不存在的 agent(`security-auditor` / `performance-engineer` / `frontend-developer` / `mobile-developer` / `devops-engineer` / `technical-writer` / `api-designer` / `cli-developer` / `product-manager` 等);(c) 用了不在 Claude Code 框架內的 JSON RPC 風格 communication protocol 範本;(d) 寫死假指標假成果報告(如 `Automated 842 test cases achieving 83% coverage with 27-minute execution time and 98.5% success rate`)會被當作真實 status 抄回對話;(e) cross-ref 上 `code-reviewer` 與 `test-automator` 沒有任何 skill / command 引用屬孤兒,`documentation-engineer` 雖被 `maintaining-readme-md` Step 3 引用但 agent 內容與 skill 用途嚴重 mismatch
- `agent-cheatsheet.md` 中 `[built-in]` scope tag(L28 標註原則 + L45 output skeleton 對應行):Claude Code 沒有「built-in agent」概念(agents 都來自 plugin 或 local),此 tag 永遠不會匹配對象,屬空殼設計
- `CLAUDE.md` Available Resources 章節「本地 agents...由 skill 透過 Agent tool 委派」整段(原 L146):agents 已全部刪除,描述失效
- `README.md` `### 3 Local Agents` 章節整段、結構樹中 `agents/` 目錄行、Advanced Customization「修改 agent」段:對應 agents/ 目錄已移除

### Changed
- `maintaining-readme-md/SKILL.md` Step 3 從「委派 `documentation-engineer` agent 產出內容」改為「主對話線直接撰寫」。理由:README/docs 屬純內容寫作,sub-agent 隔離 context 沒有實質收益;原本委派的 agent 內容根本不是寫 README/docs 而是設計文件網站,委派路徑壞掉。改為主對話線讀 `documentation-style.md` + 對應 template 後直接產出 diff,移除無效中間層。連動更新該 skill「與其他 skill / rule 的互動」表(移除 `documentation-engineer` 條目、新增三份 template references 條目)、Step 4 措辭「組織 agent 產出」→「組織草稿」、Gotchas 第 3 條從「委派 agent 時要傳風格規範」改為「寫文檔前必讀規範與模板」
- `CLAUDE.md` L107 Testing Protocols 章節超長 bullet(原本一行塞 4 個資訊:測試入口、plan 內建 TDD 循環、`superpowers:test-driven-development` 不獨立啟用、testing-rules.md 位置)精簡為兩句。CLAUDE.md 每次對話都載入,前 3 點屬 `tdd-feature-workflow/SKILL.md` 已詳述細節,CLAUDE.md 不該重述;省下的字符是純 context budget
- `tdd-feature-workflow/SKILL.md` description 從 ~700 字符精簡為 ~470 字符。原 description 過長稀釋觸發精度,核心觸發場景(實作 / 開發 / 修 bug / refactor / 繼續 / 開 PR)與 4 階段編排機制已涵蓋;細節由 skill body 承擔。同時連動移除 description 內「project-local agents」字樣(已隨 agents/ 移除)
- `tdd-feature-workflow/SKILL.md` L41 互動表中 `superpowers:requesting-code-review` dispatch 的 subagent 從無前綴 `code-reviewer` 改為明示 `superpowers:code-reviewer`,避免在 local agent 已移除後 reader 仍可能誤讀為本地 agent
- `pyproject-tooling.example.toml` 在 `[tool.ruff]` section 上方加 inline 註解,提醒 user 改 Python 版本時 `target-version`(ruff)與 `python_version`([tool.mypy])兩處要同步——原本兩個版本字串散落兩 section 沒有互相提示
- `/pre-pr-check` Level 2.2 (external-ref body file scan) 預設掃描範圍從固定 2 路徑(`pr-body.md` / `.github/PULL_REQUEST_TEMPLATE.md` / 「其他常見路徑」這個語焉不詳的 placeholder)精準化為三條明列(專案根 / `.github/` 下的 `pr-body.md`、`.github/PULL_REQUEST_TEMPLATE.md`、對話中 user 明示作為 `--body-file` 的任何路徑),反映實務上 PR body file 路徑常依專案慣例變動

---

## [v1.17.1] - 2026-04-27

### Removed
- `/project-status` 中 `git branch --show-current`:`git status -sb` 首行 `## branch-name...origin/...` 已含 branch name,獨立跑屬冗餘
- `/project-status` 中 `git status --short`:`-sb` 等同 `--short --branch`,porcelain status 已在 `-sb` 輸出中,獨立跑同樣資訊兩次
- `/project-status` 對 `.claude/CLAUDE-CHANGELOG.md` 的 read 指示。Output 模板從未顯示 CHANGELOG 條目,屬 dead instruction——指示 Claude 讀檔卻不告訴它要顯示什麼

### Changed
- `/project-status` L7「use `/pre-pr-check` if test status is needed」改為「直接 `uv run pytest` 或看 CI checks (`.github/workflows/ci.yml`)」。v1.17.0 將 `/pre-pr-check` 收斂為 workflow-aware(PR 補位),不再是 general 測試 runner;指向它查 test status 屬 misuse
- `/project-status` 新增 placeholder / 缺檔 edge case 處理:CLAUDE.md footer Version 仍是字面 `<vX.Y.Z>` → 顯示「not yet initialized,執行 `maintaining-claude-md` Workflow A」;SPEC.md 不存在 → 顯示「not yet created,描述專案需求觸發 `maintaining-spec-md`」。對 template 新 adopter 客製化過程更友善
- `/project-status` 新增 `git status -sb` 首行 sync state parsing 規則(ahead / behind / diverged / up to date / no upstream),原本「sync status with remote」placeholder 沒明示 Claude 該怎麼從 `-sb` 抽資訊

---

## [v1.17.0] - 2026-04-27

### Removed
- `/pre-pr-check` 5 個與 CI 完全重複的 checks:原 Level 1.1 (`pytest tests/ -v`)、原 Level 2.1 獨立 coverage、原 Level 2.3 (`ruff check`)、原 Level 2.4 (`ruff format --check`)、原 Level 2.5 (`mypy src/`)。`.github/workflows/ci.yml` (L33/36/39/42) 已對 PR / push 跑 `ruff check` + `ruff format --check` + `mypy src/` + `pytest --cov-fail-under=70` 為權威 pre-merge gate;本地 pre-pr-check 重跑同樣工具屬「shift-left full mirror」設計但代價是雙倍時間 + 失敗點分散 + 規範不一致(local soft warning vs CI hard fail)。改為:CI 為 ruff / format / mypy / 測試+coverage 的權威 pre-merge gate,`/pre-pr-check` 只處理 CI 做不到的 workflow-aware 項目
- `/pre-pr-check` Level 2.2 (code-simplifier) 內部的 3 步處理流程 + 1 重要備註。同一套處理流程 `tdd-feature-workflow/SKILL.md` 階段 3.3 (L143-151) 已寫 5 步完整版,雙寫導致 SSOT 漂移風險;改為此 command 只負責 dispatch agent + surface 輸出,handling 流程指向 SKILL.md
- `/pre-pr-check` 原 2.6 external-ref scan 中 commit message 部分。`external-ref-guard.sh` PreToolUse hook (L45) 已擋 `git commit` 命令文本含外部 ref——commits 不可能含外部 ref(除非 user `--no-verify` bypass)。掃 commit messages 是假設 hook 被繞過的 paranoia;hook L18 註解明示真正補位是 `--body-file` 內容,因此縮到掃 PR body draft file
- `/pre-pr-check` 所有 `if command -v ruff/mypy >/dev/null` tool-conditional fallback。CI 強制這些工具(README Quick Start L120 為必裝),「optional skip」是禮儀代碼——隨工具一併移除

### Changed
- `/pre-pr-check` Level 1 把原 1.1 (`pytest tests/ -v`) 與 2.1 (`pytest --cov=src --cov-report=term-missing`) 合併為單一 `pytest --cov=src --cov-report=term-missing --cov-fail-under=70`。原本同樣的測試集跑兩次(1.1 通過 → 2.1 必通過),浪費一次完整測試時間;`-v` verbose 不適合 gate 輸出,改用 default verbosity。Coverage 從原本「WARNING(soft)」升為硬 gate 的一部分,對齊 CI L42 `--cov-fail-under=70` 與 `pyproject-tooling.example.toml` L88 `fail_under = 70`,解決原本「pre-pr-check 軟 gate vs CI 硬 gate vs toml 硬 fail_under」三方語義不一致
- `/pre-pr-check` Final report 從 9 行固定狀態行(包含 always-present "clean" 行)改為「只列非 clean 條目;全綠則一行 `All Level 1–3 checks passed`」。降低視覺疲勞,對齊 lean output 慣例
- `.claude/CLAUDE.md` L72 `/pre-pr-check` 描述從「(tests、coverage、code-simplifier、lint / format / type-check、external-ref scan)」改為「(測試+coverage、code-simplifier、external-ref body scan、SPEC / README hints);ruff / format / mypy 由 CI 權威執行不重複」反映實際 scope
- `README.md` L37 `/pre-pr-check` 描述同步更新;L47 `.github/workflows/ci.yml` 註解從「與 `/pre-pr-check` 檢查項一致」改為「CI 為 ruff / format / mypy / 測試+coverage 的權威 pre-merge gate;`/pre-pr-check` 不重複跑這些工具,只補位 CI 做不到的 workflow-aware 項目」,反映兩者 non-overlapping;L70 `code-simplifier` 引用位置從 `/pre-pr-check Level 2.2` 改為 `Level 2.1`(coverage 移到 Level 1 後重新編號)
- `.claude/rules/code-style.md` L152 從「pre-merge 檢查由 `/pre-pr-check` command 統一執行」改為「ruff / mypy 的 pre-merge 檢查由 CI 權威執行;`/pre-pr-check` 不重跑這些工具,只處理 workflow-aware 項目」,對齊新分工
- `tdd-feature-workflow/SKILL.md` 階段 3.2 (L138-141) Level 描述更新:Level 1 改為「測試+coverage 合併 hard gate, `pytest --cov-fail-under=70`」、Level 2 從「coverage / code-simplifier / lint / format / type-check / external-ref scan」精簡為「code-simplifier、external-ref body scan」;新增註解明示「`/pre-pr-check` 不重跑 ruff / format / mypy,CI 為這些工具的權威 pre-merge gate」

---

## [v1.16.0] - 2026-04-27

### Removed
- `/pre-dev-check` Check #4 (Test baseline,跑 `uv run pytest tests/ -v` + STOP on failure):(a) hard gate 跑 full pytest 拖慢工作流啟動;(b) `.github/workflows/ci.yml` 對 PR / push 已驗證 origin/dev 通過 ruff + mypy + pytest --cov,本地 baseline 重複驗證;(c) `tdd-feature-workflow` Phase 2.4 第一個 TDD task 的「watch failing test fail」會自然觸發測試;(d) `-v` verbose 適合 debug 不適合 gate;(e) flaky e2e / 環境依賴測試會誤殺 pre-dev。Test baseline 的責任改由 CI(`.github/workflows/ci.yml`)與 Phase 2.4 共同承擔
- `/pre-dev-check` Check #5 (SPEC.md feature check):與 `tdd-feature-workflow` Phase 1 (SKILL.md L60-83) 強制的 `superpowers:brainstorming → maintaining-spec-md → SPEC diff → User 確認` 重複,且階段轉場 gate (SKILL.md L221) 已明示「1→2 必須 SPEC.md 已更新」;Phase 2.1 跑 pre-dev 時 SPEC 必已處理完,此處再驗會形成循環指令(Phase 2.1 → 啟動 maintaining-spec-md → 回 Phase 1)
- `/pre-dev-check` Check #2 (Current branch) 提供的「Stack new work on current branch」選項:`tdd-feature-workflow` Phase 2.2 (SKILL.md L92-95) 強制 `git checkout dev && git pull origin dev` 後 `git checkout -b`,根本不存在「stack on current」的合法路徑,此選項會誤導 user / Claude

### Changed
- `/pre-dev-check` 整體職責收斂為「環境檢查」單一責任:只保留 git uncommitted 狀態檢查 + `origin/dev` 同步狀態檢查(Phase 2.2 將從 dev 開分支,先 fetch 並比對是否有領先 commits;不在當前分支先 pull 避免誤動)。原 Check #3 的 `git status -sb` 比對「current branch 的 upstream」改為明確比對 `origin/dev`(Phase 2.2 真正的 base),解決原本 user 在 `feat/X` 分支跑 pre-dev 時誤比對 `origin/feat/X` 的語意模糊
- `/pre-dev-check` Report 措辭從「Pre-dev check found <N> issue(s) ... Please resolve before starting new feature work」軟化為 informational「Pre-dev environment check ... Next: Phase 2.2 ...」並指向下一步,反映 pre-dev 多數是對話式檢查而非 hard gate;只有真正 blocking 情況(staged 未確認 / fetch 失敗等)才 surface
- `.claude/CLAUDE.md` L71 `/pre-dev-check` 描述從「(git 狀態、遠端同步、測試基線)」改為「(git 狀態、origin/dev 同步)」反映實際 scope。原描述本就只列 3 項而檔案有 5 項(branch / SPEC 漏列),改後 cross-ref 與檔案行為對齊

---

## [v1.15.3] - 2026-04-27

### Changed
- `agent-cheatsheet.md` 的 `## Present as` 區塊從寫死的靜態清單(列出固定的 plugin / skill / MCP 名稱)改為「Output 骨架 + placeholder」。`CLAUDE.md` L139 與 `tdd-feature-workflow/SKILL.md` L52 都聲稱 `/agent-cheatsheet` 是「完整動態清單」,但原檔內容是 hard-coded 模板;現改為依 `ls` 輸出 + 當前 session system-reminder 動態填入,讓檔案實際行為對齊既有 cross-ref 承諾。新增「標註原則」段落,要求每個 entry 加 `[project-local]` / `[plugin:<name>]` / `[built-in]` / `[global]` scope tag,避免命名衝突誤導(例:本地 `code-reviewer` agent vs `feature-dev:code-reviewer` plugin agent)
- Skill 分類重整:原 `[Project maintenance]` / `[Feature development]` / `[Code quality]` / `[Process]` / `[Cross-cutting]` 五類精簡為 `[Project maintenance]` / `[Feature development]` / `[Code review & verification]` / `[Investigation & process]` 四類。原 `[Code quality]` + `[Process]` 兩類分界武斷(`superpowers:requesting-code-review` 與 `superpowers:brainstorming` 都是 process skill 卻被分到不同類);`[Cross-cutting]` 是 dumping ground(只放兩條來路不明的 entry)

### Removed
- `agent-cheatsheet.md` 寫死於原模板的 user 個人環境條目:`graphify` skill(來自 user `~/.claude/CLAUDE.md` 的 global skill)、`arxiv-mcp-server` / `gitlab` / `claude_ai_Gmail` / `claude_ai_Google_Calendar` / `claude_ai_Google_Drive` MCPs(均不在 README Prerequisites,屬個人安裝)、`claude-api` skill(來路不明)。Template 不應將特定 user 環境的資源當作預設清單,其他 user 採用 template 後會誤以為這些是必備
- `agent-cheatsheet.md` 找不到出處的 entry:`simplify` skill(template 用的是 `code-simplifier:code-simplifier` agent,已在 Plugin 區塊列過,此處重複且名稱錯誤)、`security-review` skill(template 任何文件均未提及)
- `agent-cheatsheet.md` 中 `superpowers:code-reviewer — preferred for TDD workflow` 的「preferred」用詞。`tdd-feature-workflow/SKILL.md` L41 將 `/code-review` command 與 `superpowers:requesting-code-review` 並列為對外寫回 PR / 對內返回對話的雙路徑,沒有 preferred 之分;改為由 Claude 依 cross-ref 既有描述動態填入,不在模板鎖定定位

### Fixed
- `agent-cheatsheet.md` 中 `feature-dev:code-architect / code-explorer / code-reviewer` 原被列為 `feature dev specialists`(無條件推薦),與 `tdd-feature-workflow/SKILL.md` L49 的「**選配**——需深度探索 codebase 或對比多個架構方案時」抵觸。改為在 `[Feature development]` 類別下標註「選配」並註明使用情境

---

## [v1.15.2] - 2026-04-27

### Fixed
- `testing-rules.md` 兩個範例的 import 順序違反 `code-style.md` PEP 8 分組規則。L40-44(`test_get_user`)與 L213-217(`test_get_cached`)把 `pytest`(3rd party)放在 `unittest.mock`(stdlib)之前,且未以空行分隔組別。Claude / user 直接抄此範例會被 ruff `I` rule 抓出,造成「rule 寫的 vs example 教的」自相矛盾。修正為 stdlib → 空行 → 3rd party → 空行 → local 三段式
- `testing-rules.md` async fixture 範例(L152-160)使用多餘的 `try/finally` 包裹 `yield`。pytest 的 yield-style fixture 已保證 `yield` 之後的 cleanup code 在測試結束時執行(包括測試失敗與 raise exception 情境),`try/finally` 不僅冗餘還會誤導讀者以為這是必要保險。移除 `try/finally`,並在章節 intro 加註 pytest 的此行為保證,讓範例反映 pytest 真實機制
- `testing-rules.md` Coverage 配置章節(原 L285)同時寫「配置見 toml」+「本專案預設 fail_under = 70」,後者與 `pyproject-tooling.example.toml` L88(真正 SSOT)及 `CLAUDE.md` L105(user 快速參考)三處重複。移除 testing-rules.md 的具體數字,只保留指向 toml 的 pointer——rule 的職責是「怎麼寫測試」,具體閾值屬於配置層

### Changed
- `testing-rules.md`「測試結構慣例」章節新增 `### Docstring 慣例` 子段,明示「測試函數與 fixture 的 docstring 用一行描述即可,不需完整 Google Style」並說明理由(test 名稱本身已是文檔、fixture 通常無 caller-facing 參數)。原本範例中 `sample_user`(L137)無 docstring、`db_session`(L153)有 one-liner、`test_get_user_success`(L48)有 one-liner——三種寫法並存讀者無從判斷;現規則明示豁免後,範例的 one-liner 風格成為標準
- `testing-rules.md` Redis / Cache 章節(L208)標題改為 `### Redis / Cache (Unit-level Mocking)` 並重寫文字釐清 mock 與 fakeredis 的分工:unit 測試用 `unittest.mock.AsyncMock` 驗證行為(呼叫次數 / 參數);需驗證實際 Redis 命令語義(`EXPIRE` / `ZADD` 等)改用 `fakeredis` 並標 `@pytest.mark.integration`。原文「使用 `fakeredis` 或 mock」+ 範例只示範 mock 造成「標題承諾雙選項、實際只給一個」的不對稱

---

## [v1.15.1] - 2026-04-27

### Fixed
- `git-rules.md` 分支命名表補上 `spec/<topic>` 一行,對齊 `maintaining-spec-md/SKILL.md` L149 已使用的 `spec/<topic>` 命名慣例(範例 `spec/refine-export-acceptance` / `spec/add-rate-limit-requirement`)。原本命名表只列 5 種(feat / fix / hotfix / docs / refactor),Claude 讀 git-rules 不會知道有 `spec/<topic>` 慣例,可能在 SPEC 獨立分支情境下誤用 `docs/spec-update` 之類命名。屬跨檔案命名抵觸修復

---

## [v1.15.0] - 2026-04-27

### Removed
- `Authored-By: <YourName> <your-email@example.com>` trailer 規範。理由:GitHub / GitLab / `git log --format` / `git shortlog` / semantic-release / commitlint 均不識別此 trailer,純文字註記不被當作 metadata、不建立 co-author 關聯、不出現在貢獻者統計;且與 git 內建 `Author:` / `Committer:` 欄位語意重複(由 `user.name` / `user.email` 自動填入)。功能 = 0。曾因 `<<'EOF'` heredoc 字面化導致 6 個 commit 寫入字串而非展開值,純粹引入 bash 構造陷阱卻無對應價值。本 setup 不採 `Co-Authored-By:`(GitHub 標準)的折衷,因為個人 / 內部 template 沒有對外標記 AI 協作的 compliance 需求——「沒功能就不寫」優於「寫一個沒功能的欄位」
- `.claude/hooks/commit-message-advisory.sh` PreToolUse hook 整檔。該 hook 唯一職能是檢查 `git commit` 命令含 `Authored-By` trailer,trailer 規範移除後失去檢查對象;同步從 `.claude/settings.json` `PreToolUse[].hooks[]` 陣列移除註冊
- `git-rules.md`「最佳實踐」第 2 條(Message 清楚描述「做了什麼」,與 Format 章節重複)、第 3 條(避免 commit 包含多個不相關改動,與第 1 條 100% 同義)、第 5 條(提交前用 `code-simplifier:code-simplifier` agent + TDD 兩行)。前者屬內部冗餘;後者跨檔案抵觸:`tdd-feature-workflow/SKILL.md` 階段 3.3 與 `pre-pr-check.md` Level 2.2 已是 code-simplifier 用法的 single source of truth(規定 PR 前跑一次、含「呈現建議 → CLAUDE 標 [強烈建議/可選/不同意] → User 決定 → 採納項回階段 2 走 TDD」5 步流程),git-rules 簡化為 2 行寫「提交前」會破壞 bite-sized TDD commit 節奏(每個 commit 都跑 agent)且抹掉關鍵紀律,違反單一責任原則(git-rules 規定 git 格式,不規定 agent 用法)

### Changed
- `git-rules.md` Commit Convention「格式」段更新為符合 [Conventional Commits 1.0.0](https://www.conventionalcommits.org/) 標準格式（含 optional body / footer 占位符與標準連結引用），並去除 `Authored-By:` trailer 行
- `git-rules.md`「最佳實踐」精簡為 2 條:「每個 commit 為邏輯完整的單一改動」+「SPEC.md / CLAUDE.md / 文檔規範變更獨立 commit」,後者擴充自原「SPEC.md 變更應獨立成一個 commit」並對齊 `maintaining-claude-md/SKILL.md` L180「規範 commit 只動 .claude/」
- `maintaining-claude-md` / `maintaining-spec-md` / `maintaining-readme-md` SKILL.md 共 8 處 commit 範例移除 `Authored-By: $(git config user.name) <$(git config user.email)>` 行(maintaining-claude-md L125 / L186 / L201;maintaining-spec-md L77 / L144 / L158;maintaining-readme-md L136 / L147),同時移除 maintaining-spec-md L206 與 maintaining-claude-md L289 互動表中對「`Authored-By` trailer」的引用
- CLAUDE.md「Safety & Hooks」表從 3 hooks 縮為 2 hooks(secrets-scan-advisory + external-ref-guard);文字「三個 PreToolUse hooks」改「兩個 PreToolUse hooks」
- README.md「2 Advisory Hooks + 1 Guard Hook」改為「1 Advisory Hook + 1 Guard Hook」+ 對應描述、結構樹、FAQ「Hooks 會擋住我的 commit 嗎?」表格、Prerequisites 表中 `code-simplifier` 的「引用位置」欄位(從 `CLAUDE.md、git-rules.md、/pre-pr-check` 改為 `tdd-feature-workflow skill 階段 3.3、/pre-pr-check Level 2.2`,反映 git-rules.md 不再規定 agent 用法的事實)

---

## [v1.14.0] - 2026-04-27

### Added
- `documentation-style.md` 新增「語言規範」章節,正式記錄本專案文檔採用的「章節標題英文、內文繁中、技術術語英文、程式碼註解英文、commit message 英文」慣例,含 5 個元素的範例表與 why 說明。原先此規範僅以 inline 文字散落於 `maintaining-readme-md/SKILL.md` 委派 documentation-engineer agent 的 prompt 中(Step 3 與 Gotchas 各一處),屬「孤兒規定」——規範改了無正式追溯點。提升為 rule 級規範後,語言慣例有 single source of truth

### Changed
- `documentation-style.md` 章節命名標準表從 10 條瘦身為 7 條,移除 `API Endpoints`(對 non-web 專案無意義)、`Examples`(與 Usage 重疊)、`Contributing`(對個人專案造成「需寫」道德壓力)。同時新增註記「依文檔性質選用,非全部必寫」,並提示「專案專屬章節以英文命名即可,不強制統一格式」(把 `API Endpoints` / `Migration` / `Contributing` 改列為 case-by-case 範例),避免 user 誤以為 7 條都是強制章節
- `maintaining-readme-md/SKILL.md` Step 3 委派 documentation-engineer agent 的 prompt 中「**語言規範**:章節標題英文、內文繁中、技術術語英文。」改為指向 `.claude/rules/documentation-style.md` 「語言規範」章節,避免兩處同步維護;Gotchas 第 3 條「委派 agent 時要傳風格規範」同步調整為傳遞 documentation-style.md 引用

### Removed
- `documentation-style.md` 末段「撰寫檢查清單」整段(6 條 checklist:標題層級、程式碼區塊標記、Mermaid、Footer、交叉連結、章節順序)。每一條都是前文規範的重抄——對 Claude 沒新訊號(讀完規範就有 mental checklist),對人類只是「規範 + 規範摘要」雙寫,且規範改 checklist 也要同步改,屬漂移風險而非價值

---

## [v1.13.0] - 2026-04-27

### Added
- 新增 `.claude/references/pyproject-tooling.example.toml` snippet 檔(top-level `references/` 目錄首位居民),整合 `[tool.ruff]` / `[tool.ruff.lint]` / `[tool.ruff.format]` / `[tool.mypy]` / `[tool.pytest.ini_options]` / `[tool.coverage.*]` 全部配置,並含 header comment 指引使用流程(uv init → cat append → uv add --dev → uv sync)。snippet 而非完整 pyproject.toml 是因為夾帶完整 pyproject.toml 會讓 user 採用後跑 `uv init` 直接卡住(uv 拒絕覆寫已存在 pyproject.toml)
- README Quick Start 新增 Step 1「初始化 Python 專案(uv init)」與 Step 3「Merge 推薦工具配置」,從 3 步驟擴為 4 步驟,完整覆蓋 user 從零到能跑 `uv run pytest` 的路徑
- README「Template 結構」樹補 `.claude/references/pyproject-tooling.example.toml` 條目
- README Advanced Customization 章節新增「調整 Rules(視團隊需求)」sub-section,容納原 Quick Start Step 3 內容(team customization 屬 Day-2,不應稀釋 Quick Start 的「快速上手」精神)

### Changed
- `code-style.md` 從 ~289 行重寫為 ~140 行,結構從「Required Standards + Recommended Tools(含完整工具介紹/比較/pyproject.toml 配置/CI 命令)」改為「Required Standards + Tools(本專案約定簡述)」;具體配置統一指向 `.claude/references/pyproject-tooling.example.toml`,pre-merge 檢查指向 `/pre-pr-check` command
- `code-style.md` Naming Conventions 中 type variables 範例從 `T, TUser`(非標準寫法)改為 `T, K, V, UserT`(對齊 Python typing 慣例:短英文或 T 後綴)
- `code-style.md` 其他慣例表「Async-first」改為「Sync / Async 一致性」並加前提「若專案採 async」,避免對 sync-only 專案(CLI 工具、ML pipeline、簡單 script)強加 async-first 預設
- `testing-rules.md` 移除 `### \`pyproject.toml\` 配置` 與 `### \`pyproject.toml\`` 兩個 sub-section(分別在 Pytest Markers 與 Coverage 配置 下),這些 toml 區塊統一搬到 `pyproject-tooling.example.toml`;原章節保留「使用範例」「執行指令」段落,並加一句指引指向 snippet 檔
- README Quick Start 步驟順移:原 Step 1「複製 setup」→ Step 2;原 Step 2「啟動 Claude Code」→ Step 4

### Removed
- `code-style.md` 的「Recommended Tools」整章關於 `ruff` 與 `black` 比較、`mypy` 與 `pyright` 對比、「Rust 實作比 black 快 100x」「2026 年事實標準」「Microsoft 出品」等 marketing-style 工具介紹文字。Rule 文件職責是「規範本身」,不是「技術選型介紹」;且 CLAUDE.md Tech Stack 已選定 ruff + mypy,rule 再 hedging「替代 black」「兩者都推薦」對已採此選擇的專案是噪音
- `code-style.md` 的 ruff lint rule sets 表格(`E/W/F/I/N/UP/B/SIM/RUF` 各組規則作用)。具體 lint rules 仍保留在 `pyproject-tooling.example.toml [tool.ruff.lint] select` 並含 inline comment;rule 文件不重述
- `code-style.md` 的「`pyproject.toml` 推薦配置」整段 toml 區塊(已抽到 snippet)
- `code-style.md` 的「CI 建議」整章(原列 4 條 pre-merge 命令)。CI 規範屬 workflow,不屬 code style;`/pre-pr-check` command + `tdd-feature-workflow` 階段 3.2 + `.github/workflows/ci.yml` 已是該領域的 single source of truth,rule 再列一份即漂移風險

---

## [v1.12.1] - 2026-04-27

### Fixed
- `maintaining-claude-md/SKILL.md` Pattern 示例觸發句從「User: 我更新了 SPEC.md...」改為 User 原始需求對話(「引入 RabbitMQ + OrderService 拆三服務」)。原措辭暗示一個不存在的工作流——SPEC.md / CLAUDE.md 永遠由 Claude 透過 maintaining-* skill 編排更新,User 不會自行編輯;原 Pattern 會誤導未來 Claude 以為「等 User 報告 SPEC 已改」才處理 CLAUDE 連動,而非主動編排兩條規範鏈。修正後正確反應段落明示「先 maintaining-spec-md 後 maintaining-claude-md」鏈條順序,錯誤反應段落同步精簡對齊。同時整段 Pattern 從 22 行縮為 12 行,減少冗詞保留教學重點(觸發句、雙鏈順序、diff、錯誤對比)

---

## [v1.12.0] - 2026-04-27

### Changed
- `maintaining-spec-md/references/spec-template.md` 結構從 7 sub-section 簡化為 3 sub-section:`Project Overview` / `Out of Scope` / `Functional Requirements`(含 `Description` / `User Needs` / `Acceptance Criteria` / 選配 `Technical Notes`)。移除 `In Scope`(與 FR 角色重疊)、移除 `Technical Context`(`Constraints` / `Dependencies` / `Assumptions`,屬 CLAUDE.md Tech Stack / Architecture 範疇,規範鏈職責切分後不應留在 SPEC)。Template 末加 hint 提示技術選型由 `maintaining-claude-md` 處理
- `maintaining-spec-md/SKILL.md` Step A2 收集需求清單從 4 項縮為 3 項(移除「技術環境」),並加 hint 引導 user 後續啟用 `maintaining-claude-md` 處理技術上下文。同時 Step B1 自問清單中「Overview / Functional / Technical Context」改為「Overview / Out of Scope / Functional Requirements」、「Acceptance / In-Out of Scope」改為「Acceptance Criteria / Out of Scope」,對齊 template 新結構
- `maintaining-spec-md/SKILL.md` 觸發情境表第 2-3 行重寫:「實作發現」從「技術限制 / 需新增依賴」改為「需求不明 / Acceptance 需修訂 / 邊界條件需補充」(技術面已歸 CLAUDE.md);「程式碼改動」從「API / schema / 架構 / 外部依賴改變」收斂為「user-facing API / schema 改變(影響 FR / Acceptance)」
- `maintaining-claude-md/SKILL.md` description 中「SPEC.md's Project Overview / Tech Stack / Architecture changed」修正為「SPEC.md's Project Overview or Functional Requirements change in ways that imply new tech stack, dependencies, or architecture」。SPEC 沒有 Tech Stack / Architecture 章節後,觸發鏈應表達為「SPEC FR 變動 → 暗示需要改 CLAUDE.md tech stack/architecture」的因果關係
- `maintaining-claude-md/SKILL.md` 觸發情境表第 5 行「SPEC.md 連動 | Project Overview / Functional 新模組 / Dependencies / Constraints / 架構重構」改為「Project Overview 變更 / Functional Requirements 新增或修改帶來新依賴或架構需求」(SPEC 沒有 Dependencies / Constraints 章節)
- `tdd-feature-workflow/SKILL.md` 階段 2.4 專案專屬提醒「新增模組時考慮是否連動更新 SPEC.md / CLAUDE.md Architecture」改為「新增模組通常意味新 FR → 啟用 maintaining-spec-md;同時連動 CLAUDE.md Architecture → 啟用 maintaining-claude-md」。SPEC 沒有 Architecture 章節後,需精確表達 SPEC 與 CLAUDE.md 各自的觸發切面

### Removed
- `spec-template.md` 的 `### In Scope` 段落:資訊已由 `Functional Requirements` 列具體功能涵蓋,抽象層級的 In Scope 反而造成 user 第一次建 SPEC 時困惑「FR 寫了還要再寫一次抽象版?」
- `spec-template.md` 的 `## Technical Context` 段落(含 `Constraints` / `Dependencies` / `Assumptions` 三個 sub-section):三類邊界在實務上常重疊(如「需 Python 3.11+」三類皆可歸),強迫分類造成內耗。技術上下文的正確家是 CLAUDE.md(Tech Stack + Architecture),SPEC 應只負責「需求 + 範圍」,不重複承擔技術選型記錄職責

---

## [v1.11.8] - 2026-04-27

### Added
- `maintaining-spec-md/SKILL.md` Workflow A 新增 Step A6「Commit 並 hand-off」,補上原本缺漏的初始 SPEC.md commit 動作 + 一句 hand-off 給 `tdd-feature-workflow` 階段 2。原本 Workflow A 從 A5 寫檔後直接到「依 User 決定順序實作」,既無 commit step 又逾本 skill scope(實作順序屬 tdd-feature-workflow 編排職責),容易讓 SPEC.md 隨之被打包進後續功能 commit、違反「SPEC 獨立 commit」規範
- `maintaining-spec-md/SKILL.md` Workflow B Step B3 補上分支策略雙情境處理(情況 A 功能分支當前 commit / 情況 B dev/qas/main 開 `spec/<topic>` 分支 + push + PR),對齊 `maintaining-claude-md` Step B3 與 `maintaining-readme-md` Step 5 的處理風格。原本 Step B4 直接 `git commit` 假設 user 永遠在「正確分支」上,實際 user 在 main / dev 隨手提到 SPEC 變更時會違反分支策略

### Changed
- `maintaining-spec-md/SKILL.md` Workflow B 整段從 6 step 重組為 5 step:原 Step B3「等待 User 確認」整段純為「再三強調」沒有實質動作,併入 Step B2 結尾;後續 step 重編號(原 B4-B6 → 新 B3-B5)。Step 應為「動作節點」,純強調的 step 破壞此定位
- `maintaining-spec-md/SKILL.md` Step B5(原 B6)「連動評估」hint 從只提 CLAUDE.md 擴充為同時 hint CLAUDE.md 與 README.md。SPEC 是最上游,變動通常向下游傳播兩條路徑(內部規範 → CLAUDE / 對外文檔 → README),原本只 hint CLAUDE 是規範鏈不完整。「與其他 skill / rule 的互動」表也對齊新增 `maintaining-readme-md` 條目
- `maintaining-spec-md/SKILL.md` Semantic Versioning 規則第 3 行「修改既有需求細節」拆為兩行:既有需求**行為**變化(嚴格化 / 放寬 / 新增 Acceptance / 補上 Constraints)→ Minor;既有需求**措辭**釐清(無行為變化)→ Patch。原本不分行為與措辭一律 Minor 過嚴,違反 SemVer 「公開介面行為改變才 Minor」慣例,純文字釐清拉升 Minor 會稀釋版本語意
- `maintaining-spec-md/SKILL.md` Step B3 Edit-and-commit 段移除「在 git repo 中:」冗詞前綴。template 採用後一定在 git repo,不需要 conditional

### Removed
- `maintaining-spec-md/SKILL.md` 觸發情境章節最末句「判斷要點:若只是內部實作細節...不需更新 SPEC.md」移除。同樣規則保留在 Gotchas 第 4 條「純實作細節不觸發」(該條附帶 why,更具教學價值),避免兩處規則打架
- `maintaining-spec-md/references/spec-template.md` Change Log table 的 v1.1.0 example row(`| YYYY-MM-DD | v1.1.0 | Added [feature/change] |`)移除,只留 v1.0.0 Initial specification。Step A3 沒指引「初次建立要刪除示意 row」,實際會讓 first-build SPEC.md 殘留 example 行;template 自身應保持「立即可用」狀態

---

## [v1.11.7] - 2026-04-27

### Added
- `maintaining-readme-md/SKILL.md` 新增「README 版本對齊規則」章節:預設 README 跟 SPEC.md 同步共用版號(README 是 SPEC 的 user-facing 投影);純文字修正可獨立 patch bump,避免拉動 SPEC 版號失去語意。原本 skill 沒指引 README 怎麼升版,user 採用 documentation-style 規定的 footer `Version` 後無據可循
- `git-rules.md` 「常用 scope 約定」表新增 `(readme)` 條目,對應 `maintaining-readme-md` 維護的 `README.md` / `docs/` 變更,完成 maintaining-* 三 skill 的 scope 對齊(`(claude)` / `(spec)` / `(readme)`)

### Changed
- `maintaining-readme-md/SKILL.md` description 精簡:移除原本夾帶的「smart delay 行為描述」「委派 agent 細節」「same PR as the feature」「語言規範」等實作層細節。description 應只回答「何時用」,實作細節屬 body 範疇——原描述約 150 words 過長,讀者尚未進 body 就先被 body 細節塞滿
- `maintaining-readme-md/SKILL.md` Step 3 委派 agent 的 prompt 模板路徑統一為完整路徑 `.claude/skills/maintaining-readme-md/references/<name>-template.md`。原本 Service 用全路徑、Reference / Guide 用相對路徑(`references/...`),agent 是子進程沒有相對基準,後兩個 template 可能讀不到
- `maintaining-readme-md/SKILL.md` 狀態 A 延後話術從「測試尚未全通過」改為「功能仍在實作中(尚未到穩定狀態)」。狀態 A 涵蓋的「實作中」不只測試未過,還包含程式碼未定稿、user 仍在迭代等情境,原 phrasing 過窄
- `maintaining-readme-md/SKILL.md` Step 5 兩處 commit 範例:type 補 scope 改為 `docs(readme):`(對齊 `maintaining-claude-md` 的 `docs(claude):` 風格);Authored-By 改用 inline `$(git config user.name) <$(git config user.email)>`(對齊 v1.11.6 maintaining-claude-md 改動,避免 placeholder 被誤讀為殘留)
- `maintaining-spec-md/SKILL.md` Step B4 commit 範例 Authored-By 改為 inline `$(git config user.name) <$(git config user.email)>`,完成 maintaining-* 三 skill 的 commit message 範例對齊

### Removed
- `maintaining-readme-md/SKILL.md` 「廣觸發、謹慎執行」開場一句移除。下一節「智慧延後邏輯(核心設計)」整節就是這句話的展開,重複
- `maintaining-readme-md/SKILL.md` 「特殊情況」章節「僅內部重構不觸發」一條移除。Step 2「決定更新範圍」表格已寫過,改在原表格項補「疑慮時問 User 確認」一句,避免兩處規則打架
- `maintaining-readme-md/SKILL.md` 「與 documentation-engineer agent 的分工」整節移除。Step 3 結尾「為何委派而非自行產出」一句已交代 skill orchestrate / agent specialist 的分工;傳遞給 agent 的必要資訊也已在 Step 3 prompt 模板呈現,獨立一節純屬重複

---

## [v1.11.6] - 2026-04-26

### Changed
- `maintaining-claude-md/SKILL.md` Workflow A 一輪改寫:Step A1 標題從「偵測未客製化狀態」改為「列出 placeholder 範圍」(Workflow A 入口已由 Entry 分流邏輯判定,A1 真正職責是產出後續 dry-run 用的清單);Step A2 「資訊嚴重不足」escape hatch 從 22 行壓到 3 行(常態走 happy path,長解釋喧賓奪主);Step A3 不再重複跑 grep,直接引用 A1 結果;「reset 為 v1.0.0」「不繼承 template 版本號」措辭改為「填為 v1.0.0,獨立於 template 自身演進」(CLAUDE.md template 的 footer 是 placeholder,本來就無版本可 reset / 繼承,原措辭誤導)
- `maintaining-claude-md/SKILL.md` CLAUDE-CHANGELOG.md 維護規則章節瘦身:移除「兩檔同 commit」「版本號日期一致」兩條已在 Step B4 + Gotchas 三處重複的原則,只保留章節獨有資訊(分類用法、條目視角、與 template 自身 CHANGELOG 區分)
- `maintaining-claude-md/SKILL.md` 「條目以 User 視角撰寫」措辭改寫為「描述規範變了什麼(行為差異),而非改了哪一行(實作細節)」。原措辭中「User 視角」對 CLAUDE.md 場景不精確——CLAUDE.md 主要消費者是 future Claude 與 dev,真正想表達的是「行為差異 vs 實作 diff」
- `maintaining-claude-md/SKILL.md` commit message 範例的 `Authored-By: <YourName> <your-email@example.com>` 改為 inline `$(git config user.name) <$(git config user.email)>`。範例夾在實際指令中,placeholder 容易被誤讀為「殘留沒清乾淨」,inline 形式可直接複製貼上
- `git-rules.md` Commit Convention 章節新增「常用 scope 約定」表(`(template)` / `(claude)` / `(spec)` / `(<module>)`),對齊 maintaining-* skill 的 commit message 風格,避免 git log 出現 `chore(template)` 與 `chore(setup)` 混用

### Removed
- `maintaining-claude-md/SKILL.md` 「特殊情況」章節的「緊急 hotfix」「實驗性規則」兩條。內容本質都是「視情況決定」,缺乏 actionable rule;只保留「多個小變更累積」這條真正特殊且可執行的規則

---

## [v1.11.5] - 2026-04-26

### Changed
- `maintaining-claude-md/SKILL.md` Workflow A Step A3 / A4 從「sed 批次直接改檔」改為「先 grep dry-run preview → user 確認 → Edit tool 逐處改」。原 sed 設計不可逆、無 preview、macOS / Linux 寫法分歧;改用 grep + Edit 後每處替換有可見 diff、可回滾、跨平台一致,且 placeholder 數量本就少(< 10),不需要 sed 的批次能力。Step A3 標題改為「展示完整替換計畫(含 dry-run)」、Step A4 標題改為「逐檔替換與清理」反映新流程
- `maintaining-claude-md/SKILL.md` Gotchas 從 5 條精簡到 3 條。移除「分支策略依 current branch」(Step B3 全段就是這個)與「Workflow A 的 baseline reset」(Step A5 就是這個)兩條與 body 高度重複的條目。剩 3 條都是 LLM 真正容易違反的鐵律(雙檔同 commit / 三處版本一致 / user 未確認絕不改檔),Gotchas 退化成「目錄重複」會失去警示功能,精簡後恢復警示力(對齊 maintaining-spec-md / tdd-feature-workflow 的 Gotchas 設計慣例)

### Fixed
- `maintaining-claude-md/SKILL.md` Step A5 baseline CHANGELOG entry 範例移除「Git 身份批次替換為本專案 Git 設定」一條。此條為實作細節(template 怎麼客製化),不是「user 會關心的變動」——user 自己就是設定 Git 身份的人,違反同檔 L246「條目以 User 視角撰寫」原則。範例若不修正會誘導 user 寫出同樣脫離 user 視角的 entry,污染專案 CHANGELOG 品質

---

## [v1.11.4] - 2026-04-26

### Fixed
- `maintaining-claude-md/SKILL.md` 觸發情境表原將「Template 未客製化」(`<Placeholder>` / `<YourName>` 殘留)列為觸發條件,但這實為 Workflow A 的 entry condition——對話進來後由 Step A1 grep 偵測,不靠 user 顯式提及。混入觸發表會誤導 Claude 把「檔案狀態」當成「對話訊號」。已從表格移除,並新增獨立的「Entry 分流邏輯」區塊覆蓋三種狀態(全殘留 → A / 全無殘留 → B / 部分殘留 + 規範變更 → 先告知 user 決定順序),補齊原本二分邏輯漏掉的「並存」情境
- `maintaining-claude-md/SKILL.md` Workflow A Step A2 原 entry assumption 寫「對話已提供足夠資訊做替換」,但內部處理又允許「資訊不完整 → 一次問清」,前後矛盾。實務痛點是 user 剛 clone template、什麼都還沒想時,Step A2 會把 user 推去做專案目的 / 核心功能 / 技術選型這類 brainstorming 級的決策——超出本 skill 職責、產出膚淺草稿。已加 escape hatch:資訊嚴重不足 → 暫停 Workflow A 並建議先用 `superpowers:brainstorming` 釐清,定型後再回來客製化

### Changed
- `maintaining-claude-md/SKILL.md` Workflow B Step B3 情況 B 的固定分支名 `docs/update-claude-md` 改為主題式 `docs/claude-md-<topic>`(例:`docs/claude-md-pre-commit-hook`、`docs/claude-md-google-docstring`)。原固定命名第二次更新就會撞 branch、原 fallback「停下來回報 user」需人工介入,主題式命名既避撞、也讓 PR title 一眼分辨變更主題。Gotchas 對應條目同步更新
- `maintaining-claude-md/SKILL.md` Workflow B Step B3 情況 A 補強「CLAUDE.md / CHANGELOG 改動獨立成一個 commit,不混入 feature commit」的明示要求並引用 git-rules.md「每個 commit 是一個邏輯完整的改動」原則。原寫法只說「直接在當前分支 commit」,user 可能誤解為與 feature 改動混 commit,導致 git log 分不清功能變動 vs 規範變動

---

## [v1.11.3] - 2026-04-26

### Changed
- `tdd-feature-workflow/SKILL.md` 階段 2.4「關於 executing-plans 的收尾行為」段從密集單段改為 4 點 numbered list。內容不變;numbered list 顯著提升 scan-ability——phase 2/3 邊界的 4 個關鍵編排節點(Step 5 自動觸發 finishing-a-development-branch / 階段 3 必須先完成 /「Ready for feedback」暫停作為介入點 / Option 2 push+PR 對應階段 3.4)現在每點獨立分行,降低 Claude 漏看任一節點導致 phase 順序錯位的風險

---

## [v1.11.2] - 2026-04-26

### Changed
- `tdd-feature-workflow/SKILL.md` 關鍵分工表後的「補充資源(選配)」由單行密集列表改為 bullet 列表,每條補上明確的 when-to 觸發信號(深度探索 / 多方案對比、多任務並行的識別條件)。原寫法把工具與情境塞進括號內,Claude 在流程內 mode-lock 時不易自主觸發;改寫後 Claude 可在符合情境時更可靠地主動採用
- `tdd-feature-workflow/SKILL.md` 「特殊情境」段移除「多任務並行」與「子任務外包」兩條 bullet——前者與 L47 補充資源重複(已在強化版條目涵蓋),後者(`superpowers:subagent-driven-development`)經評估不適配本 template 的工作模型(直接衝突 phase 2.4「主對話線親自看紅綠」核心紀律、解決的問題對 solo dev 不痛、review chain 與 phase 4 PR-level review 重複、token 成本高)。「特殊情境」段現在只剩真正改變 4 階段流程結構的 4 條(Debug / Hotfix / Refactor / Spike),語意純化

### Removed
- `tdd-feature-workflow/SKILL.md` 完全不再提及 `superpowers:subagent-driven-development`(原列於 L47 補充資源 + L197 特殊情境)。理由:把它放進 SKILL.md 必須在 phase 2.4 鐵律後加「此規則在 subagent-driven path 不適用」的條件式 disclaimer,等於把 TDD 紀律從鐵律降格為條件建議,削弱核心紀律的警示力。對需要的 user 仍可透過 `/agent-cheatsheet` 動態清單發現並直接 invoke

---

## [v1.11.1] - 2026-04-26

### Fixed
- `tdd-feature-workflow/SKILL.md` 階段 1 的 SPEC.md 啟動條件原為二分(包含 → 跳過 / 沒包含 → 啟動),漏掉「已包含但需修訂」的中間情境(範圍調整、允收標準變更、邊界條件補充、接口變動)會被誤導跳過 `maintaining-spec-md`。改為三分判斷,並補充「有任何新增 / 修訂一律先過 maintaining-spec-md」的判斷原則
- `tdd-feature-workflow/SKILL.md` 階段 3.3 step 4 原寫「採納的條目 → 遵循 TDD:更新測試 → 修改代碼 → 重跑相關測試 → 重跑全測試」,inline 一條繞過 `writing-plans → executing-plans` 的 mini TDD 循環,與本 skill 核心原則(實作路徑必須走 plan)矛盾,且缺 watch-fail / watch-pass 紅綠節奏。改為「回階段 2 走 TDD」——每條採納建議當新 plan task 處理,改完回階段 3 重跑 `/pre-pr-check`

### Changed
- `tdd-feature-workflow/SKILL.md` 關鍵分工表 `superpowers:test-driven-development` 條目簡化為「查閱用,非獨立階段——詳見 2.4」,將完整解釋集中在階段 2.4 內,去除與 L101 的重複描述
- `tdd-feature-workflow/SKILL.md` Gotchas 從 6 條精簡到 3 條,移除與正文重複的條目(TDD 不可繞過、SPEC.md 先行、3→4 gate 細項),保留 3 條真正反直覺易踩雷的提醒(code-simplifier 建議 → 回階段 2、文檔同步 merge 前、`finishing-a-development-branch` 對應階段 3.4 而非 phase 4)。Gotchas 退化成「目錄重複」會失去警示功能,精簡後恢復警示力

---

## [v1.11.0] - 2026-04-24

### Changed
- `tdd-feature-workflow/SKILL.md` 重整 4 階段邊界以對齊 `superpowers:executing-plans → superpowers:finishing-a-development-branch` 的 skill chain:
  - 原階段 3「完成前驗證與 PR」改為**階段 3「完成前驗證 + Push + PR」**,吸收 commit+push+PR 動作;階段 3.4 明示由 `superpowers:finishing-a-development-branch`(選 Option 2)或 `/commit-push-pr` / 手工完成,並註記該 skill 預設 base 為 main、本 template 需 retarget 到 dev
  - 原階段 4「Review 與 Merge」縮減為**階段 4「Code Review 與 Merge」**;4.5 的 merge 後本地清理改為直接 `gh pr merge` + `git checkout dev && pull && branch -d`
  - 理由:原設計把 `finishing-a-development-branch` 擺在階段 4.6「合併與清理」,但該 skill 的 4 個 options(merge locally / push+PR / keep / discard)對應的是「實作完成後如何整合」,不是 review 通過後的 merge;原擺位與階段 3.4 commit+push+PR 重複,並忽視 `executing-plans` Step 5 為 REQUIRED SUB-SKILL 會自動呼叫此 skill 的事實
- `tdd-feature-workflow/SKILL.md` 階段 4.1 code review 從「輕量 / 深度二選一」改為「結果回寫 PR comment(`/code-review`)/ 結果返回對話(`superpowers:requesting-code-review` + `code-reviewer` agent)」。原「輕量 / 深度」框架錯標兩者差異——實際差異是「結果去向」(一個 publish 到 PR 頁、一個返回對話),不是深度;且原 4.1 `requesting-code-review` 已 dispatch 同一 subagent,與 4.2「輕量」路徑重複
- `tdd-feature-workflow/SKILL.md` 階段 4.1(原)`requesting-code-review` 描述從「產出結構化 checklist」修正為該 skill 實際行為(dispatch `superpowers:code-reviewer` subagent 的 protocol,含 SHA 抓取 + template 填充)
- `tdd-feature-workflow/SKILL.md` 階段 4.2 `receiving-code-review` 描述從「系統化分類 comments」修正為該 skill 實際核心(verify 再實作、禁 performative agreement、不懂就問、對錯誤建議 pushback),並列為具體 bullets
- `tdd-feature-workflow/SKILL.md` 階段 2.1 語意修正:「失敗先解決再進 2.2」→「若檢查失敗,先修復再進 2.2」
- `tdd-feature-workflow/SKILL.md` 階段 2.4 加註 `executing-plans` Step 5 會自動觸發 `finishing-a-development-branch` 的行為,說明主對話線如何利用每個 batch 結束的「Ready for feedback」暫停點介入執行階段 3,再讓 finishing 在階段 3.4 被正常呼叫
- `tdd-feature-workflow/SKILL.md` 關鍵分工表重整:Code review 一列分為「對外寫回 PR / 對內返回對話」、新增「Review 反饋處理」一列指向 `receiving-code-review`、原「Branch 收尾」一列改為「Push + PR 建立」指向 `finishing-a-development-branch` Option 2,並新增「PR Merge + 本地清理」一列
- `tdd-feature-workflow/SKILL.md` 階段轉場 Gate 更新:2→3 移除 coverage 70% 要求(該項屬階段 3 `/pre-pr-check`)、3→4 明列 `/pre-pr-check` 全通過 + code-simplifier 處理完畢 + verification-before-completion + PR 建立 + CI 通過
- `tdd-feature-workflow/SKILL.md` Gotchas 更新:3→4 gate 條件擴充、新增「`superpowers:finishing-a-development-branch` 對應階段 3.4 Push+PR」條目釐清 skill 定位
- `tdd-feature-workflow/SKILL.md` 階段 3.1 `verification-before-completion` 描述強化:明列它強制要求以剛跑過的命令 evidence 為斷言依據、禁未驗證用語,並說明與 3.2 `/pre-pr-check` 的互補關係
- `README.md` Prerequisites `code-review` plugin 的「引用位置」欄位由「CLAUDE.md」(誤填)修正為「`tdd-feature-workflow` skill 階段 4.1」,並補述 command 行為
- `README.md` footer Template Version 升至 v1.11.0

---

## [v1.10.0] - 2026-04-24

### Changed
- `tdd-feature-workflow/SKILL.md` 階段 1 移除「需求明確?」分支判斷——每次新需求一律先啟用 `superpowers:brainstorming`(skill 本身對明確需求 2-3 輪即結束,不拖時間)。理由:self-judgement「需求明不明確」容易被 Claude 與 User 自判為「這個懂了」合理化繞過,誤判成本(先寫錯 SPEC → 實作偏方向 → 回頭重做)遠高於 brainstorming 的時間成本。移除後門保證 SPEC 在討論後才產出
- `tdd-feature-workflow/SKILL.md` 階段 2 從 8 個子步驟(2.1-2.10)重組為 5 個(2.1-2.5)。原本 2.3 寫 plan、2.4 獨立寫 failing test、2.5 驗證失敗、2.6 實作、2.7-2.9 跑測試,把 `superpowers:writing-plans` 產出的 plan 裡本就內建的 TDD 循環(`寫 failing test → watch it fail → 最小實作 → watch it pass → commit`)拆到 plan 之外獨立執行,導致 `executing-plans` 批次執行時會與拆出的步驟重疊或遺漏。改為:2.3 `writing-plans` 產出 bite-sized TDD plan → 2.4 `executing-plans` 批次執行(TDD 循環由每個 task 內建)。`superpowers:test-driven-development` skill 定位明確改為紅綠節奏疑義時的紀律參考,不獨立啟用為一個階段
- `tdd-feature-workflow/SKILL.md` 關鍵分工表同步重整:TDD 紀律欄位標示為「紀律參考(非獨立階段)」,新增「Bug 定位(debug 情境)」一列指向 `superpowers:systematic-debugging`,需求設計與 SPEC 更新拆為兩列以對齊新流程
- `tdd-feature-workflow/SKILL.md` 特殊情境的「Debug」段從單句(只點名 `systematic-debugging`)擴充為完整流程描述:階段 1 需求討論替換為 `systematic-debugging` 定位 root cause,之後完全走階段 2-4 的 `writing-plans → executing-plans`。明確規範**無論單點還是多模組 bug 都走同一條路徑**,避免「bug 很小直接改」的 judgement 誤判。Hotfix 改為「流程同 Debug,差別只在分支基底與 PR target」
- `CLAUDE.md` Testing Protocols 章節的「寫測試入口」改寫:正式入口改指向 `tdd-feature-workflow` 階段 2 的 `writing-plans → executing-plans`(plan 內建 TDD 循環);`superpowers:test-driven-development` 定位為紀律參考;移除指向 `test-automator` agent 的舊委派描述(與 v1.9.0 移除主流程委派一致)
- `README.md` footer Template Version 升至 v1.10.0

---

## [v1.9.0] - 2026-04-24

### Changed
- `maintaining-claude-md/SKILL.md` Workflow A baseline 產出簡化:Step A3 不再向 User 額外詢問 template version,baseline CHANGELOG entry 從 `adopted from claude-code-setup-v1 template (v<X.Y.Z>)` 改為 `adopted from claude-code-setup-v1 template`(provenance 實務價值低、多數 user 不會回頭對 diff 升 template;需要時由 git log 可追)。Step A5 移除 `<template version>` 填入說明
- `tdd-feature-workflow/SKILL.md` 階段 2.4(撰寫 failing test)改為主對話線親自執行,不再委派 `test-automator` agent。理由:`superpowers:test-driven-development` 的核心紀律「NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST」要求親眼確認測試在測對的行為,委派出去會失去 bite-sized 紅綠節奏。委派對照表相應精簡「TDD 紀律(含寫 failing test)」為單一委派對象
- `tdd-feature-workflow/SKILL.md` 階段 4.2 輕量 code review 的 `subagent_type` 從 local `code-reviewer` 改為 `superpowers:code-reviewer`。superpowers 版本有 plan alignment 環節與 Critical/Important/Suggestions 分級,與本 skill 的 `writing-plans → executing-plans` 產出緊密對接;local 版本是通用百科全書式 checklist 風格,無 workflow 整合
- `CLAUDE.md` Available Resources 章節的本地 agents 列表同步為保留 3 支(`code-reviewer` / `documentation-engineer` / `test-automator`)
- `README.md` What's Included 的本地 agents 章節從「8 Local Agents(AI / LLM 導向)」改為「3 Local Agents」,並逐條標註用途
- `agent-cheatsheet.md` 的 Plugin / global agents 區塊新增 `superpowers:code-reviewer` 條目(標註為 TDD workflow 的 preferred reviewer)

### Removed
- 5 支本 setup 實際 workflow 未引用的 local agents 檔案:`ai-engineer.md` / `architect-reviewer.md` / `llm-architect.md` / `prompt-engineer.md` / `qa-expert.md`。這批 agent prompt 為通用企業級 agent 集合的複製,與本 setup 的 TDD workflow 無整合,保留只會讓 `/agent-cheatsheet` 輸出變冗
- 保留的 3 支 local agents(`code-reviewer` / `documentation-engineer` / `test-automator`)的 "Integration with other agents" 清單移除提到已刪 agents 的 bullets(`qa-expert` / `architect-reviewer`),避免指向不存在資源

---

## [v1.8.1] - 2026-04-24

### Fixed
- `maintaining-claude-md/SKILL.md` Workflow B Step B3:`docs/update-claude-md` 分支已存在時,原設計建議加日期後綴開平行分支。此行為會造成兩個 PR 同時修改同檔案、merge 衝突不可避免。改為停下來回報 User,由 User 決定接續 commit 到既有分支 / 先處理前次 PR / 其他
- `maintaining-claude-md/SKILL.md` Workflow A Step A5:skill 原本跨邊界讀 template 根的 `CHANGELOG.md` 抓 template version,在 user 只 copy `.claude/` 到專案的常見情境下會 silent fallback 到 CLAUDE.md footer 佔位符,產出垃圾 provenance。版本號收集改併入 Step A3 向 User 一次性確認(若 User 不確定,填 `unknown`),Step A5 使用該確認值寫入 baseline entry

---

## [v1.8.0] - 2026-04-24

### Changed
- `tdd-feature-workflow/SKILL.md` 階段 1 流程重排:`superpowers:brainstorming` 從「SPEC 之後的選配」改為「SPEC 之前的判斷分支」(需求明確則直接進 SPEC,模糊則先 brainstorming 釐清再進 SPEC)。原設計箭頭方向讓 skill 先寫草稿、再回頭討論,邏輯顛倒
- `tdd-feature-workflow/SKILL.md` 階段 3.3 處理 code-simplifier 建議強化為 5 步流程:詳細呈現 → CLAUDE 附判斷(`[強烈建議]` / `[可選]` / `[不同意]`) → 與 User 討論 → 採納的條目走 TDD → 不採納的記錄理由。原本「若採納 → 走 TDD」被動語氣容易被跳過,現強制「先討論再動手」
- `/pre-pr-check` Level 2.2 同步強化:code-simplifier agent 結果不只 WARNING,要求執行「詳細呈現 + CLAUDE 判斷 + User 決定」三步,並明確交棒給 tdd-feature-workflow 階段 3.3 走 TDD
- `/pre-pr-check` Level 3.1 從「SPEC.md Status 檢查」改為「SPEC.md 對應性檢查」(branch 變更是否在 SPEC 有對應 Functional Requirement、是否有新 Acceptance 需回寫)
- `/pre-dev-check` Step 5 SPEC 功能報告從 `(Priority: <P>, Status: <S>)` 改為 `listed with <N> Acceptance Criteria`
- `/project-status` SPEC progress section 改為 SPEC overview:只展示 `Functional Requirements: <N>`,不再計算 Not Started / In Progress / Completed
- `tdd-feature-workflow/SKILL.md` 階段 2.10 從「更新 Status」改為「回寫 SPEC.md 的實作發現」:若實作中產生新 Acceptance / 邊界條件 / 細節變化 → 回寫 SPEC;沒變化可跳過
- `tdd-feature-workflow/SKILL.md` 階段轉場 Gate 2→3 條件從「SPEC Status 已從 In Progress 更新為 Completed」改為「實作中產生的新需求 / 細節變化已回寫 SPEC(若有)」
- `maintaining-spec-md/SKILL.md` description、觸發表、Workflow A/B 全面清理:移除 Status / Priority / Non-Functional / Open Questions 所有引用
- `maintaining-spec-md/SKILL.md` 新增說明「SPEC 描述『專案是什麼』的靜態契約;『做到哪了』由 git branch / PR merge 反映」

### Removed
- `references/spec-template.md` Functional Requirement 的 `Priority` 與 `Status` 欄位:一個 PR 對應一個需求時,Priority 失去意義;Status 與 git branch / PR merge 狀態機重複
- `references/spec-template.md` `Goals & Success Metrics` 子章節:屬於浮動資訊,不適合放靜態契約
- `references/spec-template.md` 整個 `Non-Functional Requirements` 章節(效能 / 安全 / 可靠性 / 擴展性 / 可維護性 / 可用性):Non-Functional 需求實際上屬於 Constraints(Technical Context)或各 Functional Requirement 自己的 Acceptance,獨立章節容易成為空殼
- `references/spec-template.md` 整個 `Open Questions` 章節:未解問題應該在討論中解決或進 Functional Requirements 的 Acceptance,不適合以 TODO 清單形式留在契約文件
- `maintaining-spec-md/SKILL.md` 「Open Questions 解答」觸發條件、Step A2 優先級收集、Step A3 Priority 與 Open Questions 標記、Step A4 優先級確認問題、Step A5 待解問題數回報、Step A6 按 Priority 實作
- `maintaining-spec-md/SKILL.md` Pattern 示例中 `**Priority**: Medium / **Status**: Not Started` 行

---

## [v1.7.0] - 2026-04-24

### Added
- `.claude/CLAUDE.md` 新增「Rules Index」章節(4 列表格):列出 4 個 rules 檔與各自管轄領域(程式碼實作 / 寫測試 / commit-push-PR / 寫 README)。原先 rules 引用散落在 Coding / Testing / Checklist 等章節,`documentation-style.md` 甚至完全沒被 CLAUDE.md 引用(只在 skill 裡)。統一 index 讓 Claude 能建立「哪個領域查哪個 rule」的 mental model
- `.claude/CLAUDE.md` 新增「Safety & Hooks」章節(3 列表格 + guard 被擋時的處理提示):列出 3 個 PreToolUse hooks 的作用與行為(Advisory `exit 0` vs Guard `exit 1`)。原本 Architecture 樹有 `hooks/` 目錄但 hook 做什麼完全沒寫,Claude 只能在被擋下時才知其存在——補進讓 Claude 做 git / gh 操作前就帶著正確 context

### Changed
- `.claude/CLAUDE.md` Development Workflow 章節從 18 行壓縮為 10 行:刪除 4 階段 bullets(已在 `tdd-feature-workflow` skill 完整涵蓋),只留「嚴格 TDD 原則 + 指向 skill + 3 個常用 command」。單一真實來源在 skill
- `.claude/CLAUDE.md` Available Agents & Skills 章節改名為「Available Resources」並從 29 行壓縮為 11 行:原先列出的 4 agents / 10 skills / 4 commands 是 `/agent-cheatsheet` 的過期子集(`agents/` 實際有 8 個;superpowers 還有多個 skill 被漏),結尾又寫「完整清單見 /agent-cheatsheet」—— 徒增維護負擔且誤導 Claude。新版只留 4-5 個核心入口 + 指向 `/agent-cheatsheet`,同時在本地 agents 描述補齊 8 個名稱
- `.claude/CLAUDE.md` Coding Conventions 章節刪除 Naming 區塊(4 條 PascalCase / snake_case 等):該內容是 `code-style.md` 命名表格(7 列更完整)的退化子集。保留 Modular Design + SOLID(原則性內容,code-style.md 未涵蓋)+ 引用 code-style.md
- `.claude/CLAUDE.md` 各章節開頭的「**核心原則**」精選保留:只留真正是原則的三處(Project Overview「SPEC 為真實來源」、Development Workflow「嚴格 TDD」、Testing「必須 TDD」)。Tech Stack / Architecture / Coding Conventions 原本的「核心原則」是該章節標題的復述,去除
- `.claude/CLAUDE.md` Architecture 樹加註 `rules/` 與 `hooks/` 目錄指向對應新章節,幫助 Claude 與 user 從樹狀圖導覽到詳細說明
- 整體 191 行 → 152 行(-20%),同時修掉 CLAUDE.md 的 8 個結構性問題(workflow/checklist 三重複述、agents 過期子集、Naming 重複 rule、核心原則氾濫、hooks 無提及、rules 無 index、meta-instruction 混淆、testing 單薄)

### Removed
- `.claude/CLAUDE.md` 整章「Development Checklist」(28 行)移除:內容 95% 與 Development Workflow 重複,且兩處都指向 `tdd-feature-workflow` skill 完整版——形成 CLAUDE.md 內兩份 + skill 一份共 3 份的三重複述。Single source of truth 歸於 skill(該 skill 已有完整 workflow + 階段轉場 gate + Gotchas)。刪除後連帶消滅原先 checklist 開頭的 meta-instruction(「此清單為靜態 reference...不修改本清單本身」),避免語意混淆

---

## [v1.6.1] - 2026-04-24

### Added
- `.claude/skills/tdd-feature-workflow/SKILL.md` 新增「階段轉場 Gate」章節(4 列表格 + WHY 說明):補回 v1.6.0 精簡時不慎一同移除的階段轉場 gate(原 checklist 中最有價值的部分)。Gate 是比 TDD 更高層的流程紀律——即使測試全綠,SPEC Status 沒更新仍不得開 PR。其他 3 個 skill 不需此章節(maintaining-* 是線性 workflow、maintaining-readme-md 狀態表已是 gate 本身)

---

## [v1.6.0] - 2026-04-24

### Added
- `.claude/skills/maintaining-spec-md/references/spec-template.md`:SPEC.md 完整 template(原內嵌於 SKILL.md 第 335-433 行)獨立為 reference 檔。Skill body 只在 Workflow A Step A3 初次建立 SPEC.md 時才讀取——採 skill-creator 業界建議的 **Progressive Disclosure** 三層載入:metadata(description)→ SKILL.md body → bundled references,避免常態載入時把僅 Step A3 用得到的 template 也扛進 context

### Changed
- 4 個 skill 依 skill-creator 業界最佳實踐精簡(SKILL.md body 目標 < 500 行、削除與 workflow 重複的 checklist、壓縮示範對話、外移大型 template):
  - `maintaining-spec-md`:433 → 206 行(-52%)
  - `tdd-feature-workflow`:329 → 205 行(-38%)
  - `maintaining-claude-md`:492 → 326 行(-34%)
  - `maintaining-readme-md`:334 → 236 行(-29%)
  - **合計 1,588 → 973 行(-39%)**
- 各 skill 的「自我檢查清單」改為「Gotchas」:只列 3-5 個容易違反的關鍵點(如「SPEC 變更必須獨立 commit」、「兩檔必須同一 commit」、「User 未確認前絕不寫檔」),取代原本與 workflow 步驟重複的 checklist——checklist 只是步驟複述,model 跑 workflow 時不會回頭看
- 各 skill 的「好做法 vs 不好做法」雙段對話範例壓縮為單一「觸發 + 正確反應 + 錯誤反應」Pattern 示例,保留學習訊號但砍掉冗長 dialog
- `tdd-feature-workflow` 移除「專案專屬指令速查」章節(pytest / ruff / uv 指令):這些指令是 tech-stack-specific,已由 CLAUDE.md 的 Development Checklist 承擔,寫在 skill 裡會造成兩處更新負擔
- `tdd-feature-workflow` 的「與既有資源的分工」表從 26 項壓縮為 13 項關鍵委派,選配項目改為「完整動態清單見 `/agent-cheatsheet`」
- 所有 skill 的 description 精簡(各減 30-40%),保留 pushy 觸發語句 + 觸發條件清單,移除 workflow 細節——這些細節應在 body 而非 metadata

---

## [v1.5.0] - 2026-04-24

### Added
- `.claude/hooks/external-ref-guard.sh`：PreToolUse **guard** hook（`exit 1` 阻擋，不同於既有兩個 advisory hook）。`git commit` / `gh pr create|edit|comment` / `gh issue create|edit|comment` 前掃 command text，偵測 `owner/repo#N` 與 `https://github.com/owner/repo/(issues|pull)/N` 指向**外部 repo** 的裸 reference 即阻擋（本 repo 由 `git remote get-url origin` 推導）。反引號包起來的引用視為安全、放行。防止 GitHub cross-repo "mentioned in ..." backlink 把本專案 commit / PR 內容外洩到不相關 open-source 專案 issue——leak 不可逆（watcher 已收到通知），故採阻擋而非 advisory
- `.claude/rules/git-rules.md` 新增「Cross-repo 引用安全格式」章節：說明 GitHub 如何自動建立 backlink、提供安全寫法對照表（反引號包、拆斷 `#` 語法）、本 repo 內部引用不受影響、自動防護機制說明
- `.claude/commands/pre-pr-check.md` Level 2 新增 2.6 步驟：掃 PR body 草稿（含 `--body-file` 內容，補位 hook 無法讀取的情境）與本 branch commit messages 的外部 repo 裸 reference；final report 新增對應欄位

### Changed
- `.claude/settings.json` PreToolUse hooks 陣列新增 `external-ref-guard.sh` entry
- `README.md` 「Advisory Hooks」章節改為「2 Advisory Hooks + 1 Guard Hook」，明確區分 advisory（`exit 0`）與 guard（`exit 1`）兩種行為；樹狀圖 `hooks/` 新增對應檔；FAQ「Hooks 會擋住我的 commit 嗎？」與「如何關閉 hook？」重寫，涵蓋新 guard 類別與 bypass 指引；Template Version 升級 v1.5.0

---

## [v1.4.0] - 2026-04-24

### Removed
- `.claude/rules/` 下 4 個 rule 檔（`code-style.md` / `testing-rules.md` / `git-rules.md` / `documentation-style.md`）移除檔尾 footer（`**Last Updated**` / `**Version**`）。Per-rule versioning 是反模式：user 編輯 rule 時多半不會記得更新 footer，導致版本號永遠停留變成「殭屍版本」；各 rule 版本也彼此不相干，比對或升級時無意義

### Changed
- `.claude/CLAUDE.md` footer 改為明確佔位符 `<YYYY-MM-DD>` / `<vX.Y.Z>`（含括弧內註解說明 Workflow A 會填入）。Template shipped 狀態下不再帶無意義的 build 期版本號，採用後由 Workflow A reset 成 user 專案的 v1.0.0
- `.claude/rules/documentation-style.md` 重寫「Footer 格式」章節：明確列出「需 footer 的檔案類型」（CLAUDE.md、user 產品文檔）與「不需 footer 的檔案類型」（rules、SKILL.md、CHANGELOG）；`**Version**` 從「強烈建議」改為該類別「必填」
- 撰寫檢查清單對應更新 Footer 項的適用範圍

---

## [v1.3.0] - 2026-04-24

### Added
- 新增 `claude-code-setup-v1/CHANGELOG.md`（本檔案）作為 template 自身 history 的權威紀錄；對標業界慣例（OSS 專案 repo root `CHANGELOG.md`）
- `maintaining-claude-md` skill Workflow A 新增 Step A6：首次客製化時寫入 user 專案的 baseline v1.0.0 entry 到 `.claude/CLAUDE-CHANGELOG.md`，並 reset CLAUDE.md footer version 為 user 專案起點

### Changed
- `.claude/CLAUDE-CHANGELOG.md` 從「記錄 template 自身演進」改為「空種子，user 專案繼承後由 Workflow A 寫入自己的 baseline」——解決原先單檔肩負 template-history 與 user-project-seed 兩個互相衝突角色的問題
- `maintaining-claude-md` SKILL.md 的 cross-ref 表與 CLAUDE-CHANGELOG 維護章節更新，明確區分「template 自身 CHANGELOG」與「user 專案 CLAUDE-CHANGELOG」
- README「Template 結構」樹狀圖新增 `CHANGELOG.md` 位置；新增 FAQ 條目解釋兩個 CHANGELOG 的職責
- `.claude/CLAUDE.md` Architecture 樹狀圖 `CLAUDE-CHANGELOG.md` 註解改為「本專案 CLAUDE.md 變更歷史」，釐清是 user 專案層級而非 template 層級

### Removed
- `.claude/CLAUDE-CHANGELOG.md` 原有的 v1.0.0 ~ v1.2.0 entries（完整搬到本檔案）——這些 entries 描述的是 template 本身的演進，不應跟隨 `.claude/` 被 user 專案繼承

---

## [v1.2.0] - 2026-04-24

### Removed
- 移除 `rules/` 下 4 個已遷移至 skills 的 pointer stub：`spec-update-rules.md`、`claude-update-rules.md`、`readme-update-rules.md`、`development-workflow-details.md`。原始 rule-driven 內容保留於 repo 根目錄的 v0 snapshot
- README「### 4 Pointer Rules（已遷移至 skills）」區塊整塊移除；`Template 結構` 樹狀圖中對應 `*-rules.md` 指標行同步清除

### Changed
- `maintaining-spec-md` / `maintaining-claude-md` skill 的 cross-ref 表將原指向 `development-workflow-details.md` 的條目改為指向 `tdd-feature-workflow` skill；`maintaining-claude-md` 分支策略章節內文同步更新
- README 新增「Design Rationale」章節，將原先散落於 4 份 stub 的「為何 skill > rule」論據整併為 5 條統一設計理由；措辭由「migration notes」（回顧過去）調整為「design rationale」（向前看的設計哲學）

---

## [v1.1.0] - 2026-04-23

### Added
- `maintaining-claude-md` skill 新增 **Workflow A（初次客製化）**：偵測 `<Placeholder>` / `<!-- TEMPLATE NOTICE -->` / `<YourName>` / `your-email@example.com` 殘留，於對話揭示相應決策時主動引導填入 placeholder、移除 NOTICE 區塊、批次替換 `.claude/` 下的 Git 身份資訊
- `maintaining-claude-md` description 新增 placeholder 觸發條件
- 「觸發情境清單」新增第 6 項「Template 未客製化」
- `.claude/hooks/secrets-scan-advisory.sh`：PreToolUse hook，`git commit` / `git add` 前掃 staged 檔名（`.env`、`*.pem`、`*.key`、`credentials.json` 等）與 staged diff 中的已知 secret pattern（AWS key、GitHub PAT、OpenAI API key、Slack token、私鑰 header 等）。Advisory only，不阻擋
- `.github/workflows/ci.yml`：GitHub Actions，PR 與 push 到 `main` / `qas` / `dev` 時觸發 ruff check + ruff format --check + mypy + pytest + coverage，與 `/pre-pr-check` 檢查項一致

### Changed
- `maintaining-claude-md` SKILL.md 原 Workflow 更名為 **Workflow B（更新既有 CLAUDE.md）**，與新增的 Workflow A 形成對稱結構（對齊 `maintaining-spec-md` 的 A/B 分流哲學）
- README Quick Start 從 5 步驟精簡為 3 步驟：原 Step 2（手動替換 placeholder）、Step 3（提需求建 SPEC）、Step 5（手動 sed 替換 Git 身份）合併為新 Step 2「啟動 Claude Code 並提出第一個需求」，由 `maintaining-claude-md` Workflow A + `maintaining-spec-md` Workflow A 自動處理
- README「What's Included」：hook 清單從 1 個更新為 2 個；新增「1 CI Workflow」區塊
- README「Template 結構」樹狀圖更新反映新檔案
- `.claude/settings.json`：新增 `secrets-scan-advisory.sh` 到 PreToolUse hooks 陣列

---

## [v1.0.3] - 2026-04-23

### Changed
- CLAUDE.md Development Workflow 核心原則改為純正面描述（「嚴格遵守 TDD：所有實作路徑必須經過 `writing-plans → executing-plans` 的測試先行流程」），不再提及不採用的替代方案
- `tdd-feature-workflow` skill description 與 body 移除所有 `/feature-dev` command 負面引用（description 尾段、核心原則、「為何需要這層編排」段落、分工表後置提醒）
- 所有 skill / command / rule 檔案移除裝飾性 emoji（`✅ ❌ ⚠️ 🔍 📊 📝 🎯 🔧 📚 🔌 💡 📋 ⏭ ℹ️`），保留目錄樹字符、流程箭頭、Markdown checkbox、section divider 等功能性符號
- `agent-cheatsheet` 各 section banner 與 output template 改為純文字

### Removed
- `agent-cheatsheet` 中錯誤的 `superpowers:feature-dev` 條目（`feature-dev` 是獨立 plugin，非 superpowers 子 skill）
- README Prerequisites 中 superpowers plugin 用途描述裡的 `feature-dev` 引用（同上錯誤）

---

## [v1.0.2] - 2026-04-23

### Changed
- Development Workflow 核心原則明確寫入「嚴格遵守 TDD」：不採用 `/feature-dev` command 作為實作入口（因其未強制 TDD）。委派清單從錯誤的 `superpowers:feature-dev` 改為實際使用的 `brainstorming` / `writing-plans` / `executing-plans` / `test-driven-development` / `finishing-a-development-branch`
- Available Agents & Skills > 功能開發段新增 `brainstorming` / `writing-plans` / `verification-before-completion` 三項常用 skill

### Removed
- 移除 Development Workflow 清單中錯誤的 `superpowers:feature-dev` 引用（feature-dev 是獨立 plugin 而非 superpowers 子項目）

---

## [v1.0.1] - 2026-04-23

### Changed
- Development Checklist 的測試指令改為 tech-agnostic（加「依 Tech Stack 調整」並保留 Python 範例），讓 template 採用者改用其他語言時不被鎖死在 uv/pytest

---

## [v1.0.0] - 2026-04-23

### Added
- Initial release of claude-code-setup-v1 template: 4 maintaining skills (`maintaining-spec-md` / `maintaining-claude-md` / `maintaining-readme-md` / `tdd-feature-workflow`), 4 slash commands, 1 advisory hook, 4 reference rules, 8 local agents
