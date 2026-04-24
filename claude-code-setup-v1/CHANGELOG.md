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
