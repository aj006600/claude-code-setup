# Journal — claude-code-setup-v1 (template 自身演進)

> 本檔記錄 **template 自身**的決策脈絡(Why),與 `CHANGELOG.md`(What changed)同級、**不隨 `.claude/` ship 給 adopter**。
> 格式規範沿用 template 自己 ship 出去的 [`.claude/docs/journal/CONVENTIONS.md`](../../.claude/docs/journal/CONVENTIONS.md)(dogfood:用自己交付的規範維護自己)。
> Adopter 採用後在自己的 `.claude/docs/journal/journal.md`(空種子)累積專案決策,與本檔互不干擾。

---

## 1. Decision Index

| ADR | 標題 | Status | Date | 領域 |
|-----|------|--------|------|------|
| [ADR-0001](#adr-0001-引入-journal-決策層補-why-層缺口) | 引入 journal 決策層,補 Why 層缺口 | Accepted | 2026-05-27 | Documentation |
| [ADR-0002](#adr-0002-軸分離不照搬-prd) | 軸分離,不照搬 prd/ | Accepted | 2026-05-27 | Documentation |
| [ADR-0003](#adr-0003-從-claudemd-抽出-architecture--tech-stack-到-architecturemd) | 從 CLAUDE.md 抽出 Architecture + Tech Stack 到 architecture.md | Accepted | 2026-05-27 | Architecture |
| [ADR-0004](#adr-0004-specmd-走精簡升級needs-clarification--success-criteria) | SPEC.md 走精簡升級(NEEDS CLARIFICATION + Success Criteria) | Accepted | 2026-05-27 | Documentation |
| [ADR-0005](#adr-0005-一致性治理用-pre-pr-check-command非手動-health-check) | 一致性治理用 /pre-pr-check command | Accepted | 2026-05-27 | Workflow |
| [ADR-0006](#adr-0006-採精煉版而非照搬-jmd6e0-全套-conventions) | 採精煉版而非照搬 jmd6e0 全套 CONVENTIONS | Accepted | 2026-05-27 | Process |
| [ADR-0007](#adr-0007-architecturemd-用獨立的-maintaining-architecture-md-skill) | architecture.md 用獨立的 maintaining-architecture-md skill | Accepted | 2026-05-27 | Architecture |

---

## 2. Postmortem Index（選配）

| PM | 標題 | Severity | Date | Status |
|----|------|----------|------|--------|
| — | （尚無） | — | — | — |

---

## 3. ADRs

### ADR-0001: 引入 journal 決策層,補 Why 層缺口

| 欄位 | 內容 |
|------|------|
| Status | Accepted |
| Date | 2026-05-27 |
| Refs | jmd6e0-agent `.claude/docs/journal`、`.claude/docs/journal/CONVENTIONS.md` |

**Context** — v1 原本涵蓋 What(SPEC)、規範(CLAUDE)、user-facing(README/docs)、實作計畫(plans),但完全沒有記錄「為什麼這樣決定」的一層。code 說 What/How、git log 說 When,Why 最容易隨人員流動蒸發、事後最難重建。研究 GitHub spec-kit 與 oh-my-claudecode 後確認:連 spec-kit 都只有 constitution(原則,向前看)與 per-feature ephemeral research,沒有持久跨專案的決策史;oh-my-claudecode 的「PRD」是自動迴圈用的執行狀態 JSON,非人讀決策文件。Why 層是業界工具普遍缺席、最具差異化的一塊。

**Decision** — 引入 journal/ 系統(ADR + Lessons + Timeline,Postmortem 選配),做成 `maintaining-journal-md` skill,在決策點自動觸發。ADR 採 Nygard 格式,屬業界成熟最佳實踐。

**Consequences**
- 正面:補上決策史;與既有 maintaining-* skill 家族一致;adopter 拿到「為什麼」的持久紀錄。
- 負面:多一份要維護的文件與 skill;需紀律在決策當下就寫(否則仍會蒸發)。

**Alternatives Considered**
- 不加、靠 git commit message 記理由:被否決——commit message 分散、不結構化、難回溯「同議題的決策演進」。
- 用 brainstorming 的一次性 design doc:被否決——一次性、非 living,無法累積跨決策的索引與 supersede 關係。

### ADR-0002: 軸分離,不照搬 prd/

| 欄位 | 內容 |
|------|------|
| Status | Accepted |
| Date | 2026-05-27 |
| Refs | [ADR-0003](#adr-0003-從-claudemd-抽出-architecture--tech-stack-到-architecturemd) |

**Context** — 最初構想是把 jmd6e0 的 prd/(prd.md + prd_roadmap + prd_change_log)整套搬進來。但 prd.md 七成內容是「現行架構 + 設計決策摘要 + tech stack + risk」,與 v1 既有的 SPEC.md(需求)是**不同軸**;若並排會與 SPEC 重疊(雙頭維護),而這正是 jmd6e0 自己的 CONVENTIONS 列為頭號禁忌。changelog/roadmap 部分 v1 已有更工整的等價物(CLAUDE-CHANGELOG + SPEC Change Log + SemVer)。

**Decision** — 不新增 prd.md。改採「按軸分離 + 單一真相 + 交叉連結」:需求留 SPEC.md、現行架構獨立成 architecture.md、Why 進 journal、changelog 沿用既有兩軌。prd.md 想要的「可讀現況總覽」由 architecture.md 承接。

**Consequences**
- 正面:零雙頭維護;每軸單一 SoT;比照搬整套 prd/ 精煉。
- 負面:需要把「現行架構」從 CLAUDE.md 搬出(見 ADR-0003),是真實 refactor 成本。

**Alternatives Considered**
- 整套搬 prd/:被否決——與 SPEC 重疊、且帶入過重的 conventions。
- 把 SPEC.md 升級成 prd.md 形態:被否決——等於把架構塞回需求檔,與 ADR-0003 抽離方向矛盾。

### ADR-0003: 從 CLAUDE.md 抽出 Architecture + Tech Stack 到 architecture.md

| 欄位 | 內容 |
|------|------|
| Status | Accepted |
| Date | 2026-05-27 |
| Refs | [ADR-0002](#adr-0002-軸分離不照搬-prd)、[ADR-0007](#adr-0007-architecturemd-用獨立的-maintaining-architecture-md-skill)、spec-kit constitution/plan 切法 |

**Context** — v1 原本把 Architecture 樹與 Tech Stack 放在 CLAUDE.md(開發規範檔)裡,而「設計決策摘要」無家可歸。spec-kit 的切法給了乾淨範式:constitution(原則)/ spec(what+why)/ plan(how+tech)分離。CLAUDE.md 對應 constitution,不該混入 how/tech。

**Decision** — 把 Architecture + Tech Stack + 目錄結構移到新檔 `.claude/docs/architecture.md`,CLAUDE.md 回歸純 constitution(原則/規範/workflow),只保留指向 architecture.md / SPEC / journal 的指標表。

**Consequences**
- 正面:CLAUDE.md 軸純淨;architecture.md 成為現行架構單一 SoT;對齊 spec-kit 範式。
- 負面:動到既有 `maintaining-claude-md` skill 與 SPEC→CLAUDE→README 鏈,需同步多個 skill 的路由(已連動修正 tdd-feature-workflow / maintaining-spec/readme/claude、documentation-style、pre-pr-check / project-status)。

**Alternatives Considered**
- 只抽 Architecture、Tech Stack 留 CLAUDE.md:被否決——Tech Stack 與 architecture.md 的現行架構仍會輕微重疊,不如一次切乾淨(user 選此)。
- 全留 CLAUDE.md 不動:被否決——constitution 與 how/tech 混居是現有破綻來源。

### ADR-0004: SPEC.md 走精簡升級(NEEDS CLARIFICATION + Success Criteria)

| 欄位 | 內容 |
|------|------|
| Status | Accepted |
| Date | 2026-05-27 |
| Refs | spec-kit `templates/spec-template.md` |

**Context** — spec-kit 的 spec.md 比 v1 原 spec-template 豐富:prioritized user stories(P1/P2/P3)、Given/When/Then 驗收、`[NEEDS CLARIFICATION]` 標記、可量化且 tech-agnostic 的 Success Criteria。全套會讓 SPEC 變重,違反 v1 lean 哲學。

**Decision** — 只取兩個最高 CP 值、純需求軸的項目:`[NEEDS CLARIFICATION: <問題>]` 標記慣例(可被 /pre-pr-check 掃描)+ 獨立的可量化 Success Criteria section。不引入 P1/P2/P3 user stories 全套。

**Consequences**
- 正面:需求更可驗證、未決點不再靜默假設;保持 SPEC lean。
- 負面:Success Criteria 與 Acceptance Criteria 的層級差異需 user 理解(已在 template 註明)。

**Alternatives Considered**
- 全套 spec-kit 形態:被否決——SPEC 變重,違反 lean(user 選精簡版)。
- 完全不動 SPEC:被否決——錯失 NEEDS CLARIFICATION 這個低成本高價值慣例。

### ADR-0005: 一致性治理用 /pre-pr-check command(非手動 health check)

| 欄位 | 內容 |
|------|------|
| Status | Accepted |
| Date | 2026-05-27 |
| Refs | spec-kit `/speckit.analyze`、`.claude/commands/pre-pr-check.md` |

**Context** — jmd6e0 的 CONVENTIONS 用「每月手動 health check 清單」維護文件健康度。手動巡檢易被遺忘。spec-kit 用 `/analyze` 做跨 artifact 一致性檢查,把治理自動化。

**Decision** — 擴充既有 `/pre-pr-check` 新增 L2.3 跨文件一致性掃描:`[NEEDS CLARIFICATION]` 殘留、ADR Status 與 Decision Index 一致、cross-ref 連結可解析、footer 版本一致。以工具取代手動 health check。

**Consequences**
- 正面:一致性在 PR 前自動驗、不靠記性;與既有 command 整合不增新入口。
- 負面:掃描邏輯需隨文件結構演進維護。

**Alternatives Considered**
- 新增獨立 command:被否決——PR 前檢查已有 /pre-pr-check,併入避免入口分散。
- 沿用手動 health check 清單:被否決——易遺忘,違反「能自動化就自動化」。

### ADR-0006: 採精煉版而非照搬 jmd6e0 全套 CONVENTIONS

| 欄位 | 內容 |
|------|------|
| Status | Accepted |
| Date | 2026-05-27 |
| Refs | jmd6e0 `.claude/docs/journal/CONVENTIONS.md`(約 480 行)、`.claude/docs/prd/CONVENTIONS.md` |

**Context** — jmd6e0 的 conventions 為一個 14-ADR、多階段、合規驅動的複雜產品量身打造,帶 Risk Register、Glossary、SMART Acceptance、Postmortem severity matrix、月度 health check 等。v1 是通用 lean template,全套搬入會違反其「避免過度設計」哲學(jmd6e0 自己的 ADR-0014 也以同理由選 Hexagonal 而非完整 DDD)。

**Decision** — right-sizing:journal 取 ADR + Lessons + Timeline 為核心,Postmortem 列為選配;Risk/Glossary/SMART 等不強制納入。journal CONVENTIONS 精煉到約 240 行。

**Consequences**
- 正面:符合 lean 哲學;adopter 認知負擔低;核心 80/20 價值保留。
- 負面:大型團隊若需要 Risk/Glossary 等需自行擴充(已在 CONVENTIONS 標明選配方向)。

**Alternatives Considered**
- 照搬全套:被否決——過重、違反 lean、多數通用專案用不到。
- 只做 ADR、連 Lessons/Timeline 都砍:被否決——Lessons/Timeline 成本低且補足 ADR 不涵蓋的戰術經驗與時序。

### ADR-0007: architecture.md 用獨立的 maintaining-architecture-md skill

| 欄位 | 內容 |
|------|------|
| Status | Accepted |
| Date | 2026-05-27 |
| Refs | [ADR-0003](#adr-0003-從-claudemd-抽出-architecture--tech-stack-到-architecturemd) |

**Context** — Architecture + Tech Stack 從 CLAUDE.md 抽出後需要維護歸屬。可選 (a) 擴充 maintaining-claude-md 兼管,或 (b) 新增專責 skill。

**Decision** — 新增專責的 `maintaining-architecture-md` skill,維持 v1 既有「一份 doc SoT 對一個 maintainer」的對稱(maintaining-spec/architecture/claude/readme/journal,共 5 個)。architecture.md 的觸發情境(新模組、換框架、目錄重組、data flow)與 CLAUDE.md 的規範觸發明顯不同,分開觸發更準。

**Consequences**
- 正面:SoT-per-skill 一致;觸發語意清晰、不互相誤觸;maintaining-claude-md 名實相符。
- 負面:maintaining-* skill 由 3 增至 5,template 體積略增(屬可接受,換得清晰)。

**Alternatives Considered**
- 併入 maintaining-claude-md:被否決——讓 claude skill 名實不符,且架構/規範觸發語意混雜易誤觸。

---

## 4. Lessons Learned

### L1 — 「業界最佳實踐」不等於照抄最重的那套

研究外部專案時,容易把「最完整 / 最重」誤當「最佳」。實際上 right-sizing(把文件量級對齊專案複雜度)本身才是最佳實踐——jmd6e0 自己選 Hexagonal 而非完整 DDD、spec-kit 提供 lean preset,都是同一道理。

**判別:** 引入外部做法時,問「這個重量級機制解的痛點,我的專案真的有嗎?」

**對策:** 取 80/20 核心(ADR + Lessons + Timeline),其餘列選配;在 CONVENTIONS 標明擴充方向而非預先全做。

### L2 — 「整合兩份文件」常是把重疊換地方,不是消除

把 prd.md 併進 SPEC.md 看似整合,實則會把重疊從「SPEC vs prd」搬成「SPEC vs CLAUDE(因兩邊都有架構)」。真正解法是按軸分離 + 單一真相 + 連結。

**判別:** 提議「合併 A 和 B」時,先確認 A、B 是否同一個軸;不同軸的合併只是搬移重疊。

**對策:** 先畫「軸 × 檔案」對照表,確認每個事實只有一個 SoT,再決定合併或分離。

---

## 5. Timeline

### 2026-05-27:決策文件系統優化

- 與 user 多輪 brainstorming:對照 jmd6e0 `.claude/docs` 概念、研究 GitHub spec-kit 與 oh-my-claudecode 的機制。
- 確立方向:加 journal(Why 層)、軸分離不照搬 prd、CLAUDE.md 抽出 Architecture+Tech Stack、SPEC 精簡升級、一致性用 command。產出 ADR-0001 ~ ADR-0007。
- 在 `feat/decision-docs-system` 分支實作:ship 端(journal 骨架 + architecture.md + 2 個新 maintaining skill + SPEC/pre-pr-check 升級)、連動修正既有 skill 路由、dogfood 本 journal。
- 對應 PR:`feat/decision-docs-system` → `main`(暫不 merge)。
