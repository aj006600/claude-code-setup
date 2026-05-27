# Journal Conventions (journal 撰寫規範)

> **適用範圍**：`.claude/docs/journal/journal.md` 及其衍生紀錄
> **精神**：`journal.md` 只放資料（決策、事件、時序）；「怎麼寫」的規格集中在本檔。

journal 是專案的「Why 層」——記錄**為什麼這樣決定**(ADR)、**出過什麼事**(Postmortem)、**學到什麼**(Lessons)、**何時發生**(Timeline)。code 說明 What 與 How、git log 說明 When,而 Why 最容易隨人員流動蒸發,本系統就是補這層。

---

## 目錄

- [1. 文件分工與 SoT 邊界](#1-文件分工與-sot-邊界)
- [2. ADR（Architecture Decision Record）](#2-adrarchitecture-decision-record)
- [3. Lessons Learned](#3-lessons-learned)
- [4. Timeline](#4-timeline)
- [5. Postmortem（選配）](#5-postmortem選配)
- [6. 跨文件引用協定](#6-跨文件引用協定)
- [7. Living Document 維護](#7-living-document-維護)
- [8. 範本速查](#8-範本速查)

---

## 1. 文件分工與 SoT 邊界

每個事實只在一處有完整描述,他處用連結引用。各檔職責:

| 檔案 | 回答 | 軸 |
|------|------|----|
| `journal.md` ADR | 為什麼選 X 不選 Y | Why（decision） |
| `journal.md` Postmortem | 出事了,根因是什麼 | Why（incident） |
| `journal.md` Lessons | 下次怎麼避免 | Why（tactical） |
| `.claude/docs/architecture.md` | 現在系統長什麼樣 | What is now |
| `.claude/SPEC.md` | 專案該做什麼(需求/驗收) | What must do |
| `CHANGELOG` 類 | 改了什麼 | What changed |

判別:一個內容該放哪,先問它回答上表哪個問題。回答「為什麼決定」就進 ADR;回答「現在長怎樣」就進 architecture.md。

---

## 2. ADR（Architecture Decision Record）

### 2.1 何時開新 ADR

符合任一即開 ADR:

- 在 ≥ 2 個方案中選 1 個,且方案間有明確 trade-off
- 決策影響後續實作走向(牽動其他模組、改變介面、移動責任邊界)
- 調整既有架構(即使是「同個問題換實作」)
- 引入新依賴、新通訊機制、新部署模式

只有單一可行作法、無方案比較的情況,改寫 [Lesson](#3-lessons-learned) 即可。判別樹:

```
有 2+ 個合理候選方案?
  否 → Lesson Learned
  是 → 方案間有明確 trade-off?
         否 → Lesson Learned(直接寫唯一可行作法)
         是 → ADR
```

### 2.2 格式範本

````markdown
### ADR-NNNN: <Title>

| 欄位 | 內容 |
|------|------|
| Status | Proposed \| Accepted \| Superseded by ADR-XXXX \| Deprecated |
| Date | YYYY-MM-DD |
| Refs | commit hash、相關文件連結 |

**Context** — 為什麼需要這個決策、當時的限制、相關背景

**Decision** — 選了什麼(具體到讓讀者能直接照做)

**Consequences**
- 正面：⋯
- 負面：⋯

**Alternatives Considered**
- 方案 A：⋯（否決原因）
- 方案 B：⋯（否決原因）
````

撰寫要點:

- **Context 含限制條件**:寫「為什麼當時不能做更好的事」(cost、時程、相依),而非只寫動機。
- **Decision 夠具體**:未來實作者讀完知道下一步怎麼動。
- **Consequences 雙面**:列出負面才有參考價值,只寫好處等於行銷。
- **Alternatives 至少 2 個**:純獨家方案歸 Lesson,不開 ADR。

### 2.3 Status 生命週期

```
Proposed ──→ Accepted ──→ Superseded by ADR-XXXX
                  └──────→ Deprecated
```

| Status | 意義 |
|--------|------|
| Proposed | 已提出、未拍板(通常是 PR 討論期的暫時狀態) |
| Accepted | 已採用、現行有效 |
| Superseded by ADR-XXXX | 同議題後來換解法,有新 ADR 接手 |
| Deprecated | 議題撤銷或技術過時,無後繼決策 |

判別 Superseded vs Deprecated:有新 ADR 解同問題 → Superseded;問題消失 → Deprecated。

ADR 一旦寫入即永久保留:被取代時改 Status 並保留編號與內容,使 cross-ref 與歷史追蹤維持完整。

### 2.4 編號規則

- 連續遞增、4 位數:ADR-0001、ADR-0002 …
- 每個編號終身對應同一條 ADR(Superseded/Deprecated 的編號繼續保留)。
- 回滾既有決策時,新開 ADR-NNNN 描述「revert to ADR-XXXX 的行為」,並把被回滾的 ADR 標 Superseded by 新編號。

### 2.5 Decision Index 維護

每次新增或變更 ADR,同步更新 `journal.md` 的 Decision Index 表(標題、Status、Date、領域標籤)。Status 須與 ADR 本體一致。

---

## 3. Lessons Learned

戰術經驗、工具/環境注意事項、無方案比較的單一作法、小到不必開 ADR 但會重複犯的坑,寫成 Lesson。

格式(建議,不嚴格):

```markdown
### L<N> — <Title>

<一段描述：症狀、根因、判別、對策>

**判別：** <如何快速判斷遇到這個情境>

**對策：** <怎麼做>
```

編號用 `L<N>`(短,因條目多),按主題分組。若某 Lesson 後來需要架構決策才能根治 → 開 ADR 並 cross-ref;若其對應事件夠嚴重 → 補 Postmortem,Lesson 簡化為連結。

---

## 4. Timeline

時序快查:「什麼時候發生了什麼」,與 git history 對應。

- 按日期分小節(`### YYYY-MM-DD: <Title>`),同日多事件在一節內條列。
- 每個重要里程碑帶 7 字元短 commit hash(`` `9fd5af1` ``)。
- 引用 ADR / PM / Lesson 用同檔錨點連結。
- Timeline 只放「指針」與「敘事」;完整推理在 ADR、根因在 Postmortem。

---

## 5. Postmortem（選配）

> 這是**選配**層。小型 / 單人專案可只用 ADR + Lessons + Timeline;當事件規模需要正式根因分析時再啟用。

Medium 以上嚴重度建議寫 Postmortem,Low 用 Lesson 代替即可。

| Severity | 觸發(任一) |
|----------|------------|
| High | 阻塞 ≥ 1 天 / 需 rollback / 影響核心功能 / 資料遺失風險 / 安全事件 |
| Medium | 阻塞數小時~1 天 / 需 workaround 而非根治 / 影響部分功能 |
| Low | 短時困擾、有立即繞道 → 用 Lesson |

格式:

````markdown
### PM-NNNN: <Title>

| 欄位 | 內容 |
|------|------|
| Severity | High \| Medium \| Low |
| Detected | YYYY-MM-DD |
| Resolved | YYYY-MM-DD \| Workaround \| Open |
| Refs | commit、ADR、相關文件 |

**Summary** — 一句話描述事件

**Timeline** — 1. … 2. … N. …

**Root Cause** — 真正根因(5 Whys,至少問到第三層)

**Impact** — 受影響範圍、時間、成本

**Resolution** — 怎麼解決(technical + process)

**Action Items** — - [ ] 可驗證的待辦(指派 owner / due 為佳)

**Lessons** — 學到什麼
````

寫作要點:blameless(對事不對人,即使人為操作也問「為什麼系統允許」);Action Items 要可驗證(「在 CI 加 lint rule 擋住 X」算,「以後注意」不算);Resolved 欄寫 Workaround 也 OK,明確標示未根治勝過假性 close。PM 編號規則同 ADR。

---

## 6. 跨文件引用協定

journal 在 `.claude/docs/journal/`,architecture 在 `.claude/docs/`,SPEC 在 `.claude/`。引用語法:

| 從 | 到 | 寫法 |
|----|----|------|
| journal ADR | architecture.md | `[architecture.md](../architecture.md)` |
| journal ADR | SPEC.md | `[SPEC.md](../../SPEC.md)` |
| architecture.md | journal ADR | `見 [ADR-XXXX](journal/journal.md#adr-xxxx-...)` |
| 同檔錨點 | 同檔錨點 | `[ADR-0001](#adr-0001-...)` |
| ADR | Postmortem | `見 [PM-XXXX](#pm-xxxx-...)` |

交叉責任:

- architecture.md 新增/修改設計決策 → journal 要有對應 ADR 解釋為什麼。
- ADR Status 改 Superseded → architecture.md 對應段落改連到新 ADR。
- 重大 Postmortem 改變了架構 → 連結相關 ADR(新開或 supersede 舊的)。

---

## 7. Living Document 維護

| 事件 | 立即更新 |
|------|---------|
| PR 合併且含架構決策 | 新增 ADR + 更新 Decision Index + 更新 Timeline |
| Severity ≥ Medium 事件解決 | 寫 Postmortem + 更新 Timeline |
| 小型 knowhow(無 ADR/PM 條件) | 加 Lesson |
| 里程碑 / 版本 tag | 更新 Timeline |
| 既有 ADR 被取代 | 舊 ADR 改 Status: Superseded + 開新 ADR |

文件健康度由一致性檢查 command(見 `/pre-pr-check`)自動驗證:ADR Status 是否準確、Decision Index 是否與 ADR 本體同步、cross-ref 連結是否可解析。以工具取代手動定期巡檢。

---

## 8. 範本速查

### 8.1 ADR

````markdown
### ADR-NNNN: <Title>

| 欄位 | 內容 |
|------|------|
| Status | Accepted |
| Date | YYYY-MM-DD |
| Refs | — |

**Context** —

**Decision** —

**Consequences**
- 正面：
- 負面：

**Alternatives Considered**
- 方案 A：⋯（否決原因）
- 方案 B：⋯（否決原因）
````

### 8.2 Lesson

```markdown
### L<N> — <Title>

<描述>

**判別：**

**對策：**
```

### 8.3 Timeline 條目

```markdown
### YYYY-MM-DD：<Title>

- <事件 1>,commit `XXXXXXX`
- 相關決策 [ADR-XXXX](#adr-xxxx-...)
```

### 8.4 Postmortem（選配）

見 [§5](#5-postmortem選配) 完整格式。
