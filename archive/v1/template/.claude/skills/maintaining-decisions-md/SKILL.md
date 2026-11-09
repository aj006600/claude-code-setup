---
name: maintaining-decisions-md
description: Use when an architecture or design decision is made with 2+ viable alternatives and a real trade-off, when reverting or adjusting a prior decision, when introducing a new dependency / communication mechanism / deployment mode, when an incident is resolved (root cause worth recording), when a tactical lesson surfaces (a pitfall worth not repeating), or at a milestone / version tag. Also use when the project has no decisions yet and a decision is being captured for the first time. Trigger proactively even without explicit mention of "ADR" or "decisions" — any conversation where you chose X over Y for a stated reason, or learned something the hard way, should invoke this skill, because the "why" behind decisions is the first thing lost as a project ages and the most expensive to reconstruct.
---

# Maintaining decisions.md

這個 skill 讓 Claude Code 正確維護 `.claude/docs/decisions/decisions.md`——專案的「Why 層」決策史。它記錄**為什麼這樣決定**(ADR)、**出過什麼事**(Postmortem)、**學到什麼**(Lessons)、**何時發生**(Timeline)。

完整格式規範見 `.claude/docs/decisions/CONVENTIONS.md`(本 skill 的 bundled reference,撰寫前必讀對應段落)。

---

## 為何需要這層保護

`SPEC.md` 說明專案**該做什麼**、`architecture.md` 說明現在**長什麼樣**、git log 說明**何時改**。沒有任何一處記錄**為什麼當初這樣決定**——而這正是最容易隨人員流動蒸發、事後最難重建的資訊。

實務痛點:

- 三個月後沒人記得「當時為什麼不選那個更簡單的方案」→ 有人想「優化」回那個方案,再次踩到當初否決它的坑。
- 同一個設計爭論每隔半年重來一次,因為上次的結論沒留下脈絡。
- 出過的事故沒有根因紀錄 → 換手後復發。

**沒有 Why 層 = 團隊不斷重新發現已經做過的決策。** 本 skill 在決策發生的當下把脈絡固定下來。

---

## 觸發情境

| 類別 | 何時觸發 | 寫成 |
|------|---------|------|
| 架構/設計決策 | 在 2+ 方案中選 1 個且有 trade-off、調整既有架構、引入新依賴/機制/部署模式 | **ADR** |
| 回滾決策 | 推翻先前決策、退回舊行為 | 新 **ADR**(supersede 舊的) |
| 戰術經驗 | 踩坑、工具/環境注意事項、無方案比較的單一作法 | **Lesson** |
| 事故解決(選配) | Severity ≥ Medium 的事件根因值得記錄 | **Postmortem** |
| 里程碑 | PR 合併含架構決策、版本 tag | **Timeline** 條目 |

判別 ADR vs Lesson:有 2+ 合理候選且彼此有明確 trade-off → ADR;否則 → Lesson。詳見 CONVENTIONS §2.1 判別樹。

---

## Entry：偵測 decisions 狀態

```bash
grep -c '^### ADR-' .claude/docs/decisions/decisions.md
```

- 回 0(空種子)→ 本次是第一條決策,寫 ADR-0001,並把空種子的「（尚無）」佔位列換成正式 Decision Index 條目。
- 回 ≥ 1 → 取現有最大 ADR 編號 +1 作為新編號(連續遞增,不重用)。

---

## Workflow A：寫一條 ADR（最常用）

### Step A1：確認夠格開 ADR

自問 CONVENTIONS §2.1 的判別樹。只有單一可行作法、無 trade-off → 改走 Workflow B 寫 Lesson,不開 ADR。

### Step A2：展示 ADR 草稿取得確認

**不直接寫檔。** 在對話中展示完整 ADR 草稿(依 CONVENTIONS §2.2 格式):

    decisions 新增建議

    **編號**：ADR-NNNN（現有最大 +1）

    **草稿**：
    ```markdown
    ### ADR-NNNN: <Title>
    | Status | Accepted |
    | Date | <今日> |
    | Refs | <commit / 相關文件> |
    **Context** — ...
    **Decision** — ...
    **Consequences** — 正面 / 負面
    **Alternatives Considered** — 方案 A（否決原因）/ 方案 B（否決原因）
    ```

    **Decision Index 將新增一列。**

    是否確認?

三條 load-bearing 原則:Context 要寫當時的限制(不只動機)、Consequences 要列負面、Alternatives 至少 2 個。

### Step A3：User 確認後寫入

1. 在 `decisions.md` §3 ADRs 新增該 ADR(編號順序)。
2. 同步在 §1 Decision Index 新增一列(標題、Status、Date、領域標籤),Status 與本體一致。
3. 視情況在 §5 Timeline 加一行(里程碑型決策)。

### Step A4：依分支策略 commit

decisions 變更**獨立成一個 commit**,不混入功能 code。commit message:`docs(decisions): add ADR-NNNN <topic>`。分支策略比照 `maintaining-claude-md`(功能分支內就地 commit;主分支則開 `docs/decisions-<topic>` 分支)。

---

## Workflow B：寫 Lesson / Timeline / Postmortem

- **Lesson**:在 §4 新增 `L<N>`(CONVENTIONS §3 格式:描述 + 判別 + 對策)。無需 ADR 等級的確認儀式,但仍展示草稿。
- **Timeline**:在 §5 按日期新增條目,帶 7 字元 commit hash。
- **Postmortem(選配)**:Severity ≥ Medium 才寫,依 CONVENTIONS §5 格式;blameless、5 Whys、Action Items 可驗證。

---

## Status 變更與回滾

- 既有 ADR 被新決策取代:把舊 ADR 的 Status 改為 `Superseded by ADR-XXXX`,保留編號與內容,並開新 ADR。
- 回滾到舊行為:新開 ADR 描述「revert to ADR-XXXX 的行為」,被回滾的 ADR 標 Superseded by 新編號。
- 每次 Status 變更都同步更新 Decision Index。

---

## 與其他 skill / rule 的互動

| 對象 | 關係 |
|------|------|
| `tdd-feature-workflow` | 階段 1(需求/設計)出現架構選擇時觸發本 skill 寫 ADR;階段 4(merge)里程碑更新 Timeline |
| `maintaining-spec-md` | SPEC 的需求「怎麼實現」由某 ADR 決定時,SPEC 可 cross-ref 該 ADR;反向,ADR 的 Decision 影響需求時提示更新 SPEC |
| `architecture.md` | architecture.md 的 Design Decisions 索引每條 cross-ref 對應 ADR;架構段落變動 → 對應 ADR 要存在 |
| `.claude/docs/decisions/CONVENTIONS.md` | 撰寫前必讀:ADR/Lesson/Postmortem/Timeline 格式、編號、Status 生命週期、引用協定 |
| `.claude/rules/git-rules.md` | Commit 格式(`docs(decisions):`);decisions 獨立 commit |

---

## Pattern 示例

**觸發**：`User: "session 持久化我們用 Postgres,不要用本地 SQLite"`(對話揭示了在 2 個方案中選 1 + 有 trade-off)

**正確反應**(先記決策脈絡):

    這是架構決策(Postgres vs 本地 SQLite,有 trade-off),啟用 maintaining-decisions-md。

    ADR-NNNN 草稿：
    **Context** — 多人並發服務,需跨 instance 共享 thread state...
    **Decision** — 用 LangGraph Postgres checkpointer...
    **Consequences** — 正面：並發安全、可水平擴展；負面：需自管 Postgres
    **Alternatives** — 本地 SQLite（單機設計,並發踩鎖）；自刻 Redis state（重造輪子）

    是否確認?

**錯誤反應**:直接改 code 不記 ADR → 三個月後有人問「為什麼不用更簡單的 SQLite」,沒人答得出來,決策被白白重來。

---

## Gotchas（容易忘記的關鍵點）

- **decisions 獨立 commit**:不跟 feature code 混在同一 commit,確保決策歷史可追。
- **Decision Index 與 ADR 本體必須同步**:Status 兩處不一致即等於對讀者撒謊。
- **ADR 永久保留**:被取代改 Status,不刪內容——刪除會破壞 cross-ref 與歷史。
- **User 未確認前不寫檔**:展示草稿 → 確認 → 才動手(同其他 maintaining-* skill 的信任原則)。
- **ADR 與 Lesson 別搞混**:沒有 2+ 方案 trade-off 的就是 Lesson,不要硬湊成 ADR 稀釋訊噪比。
