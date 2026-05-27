---
name: maintaining-architecture-md
description: Use when the current system architecture changes — new module / component / service added or removed, directory structure reorganized, tech stack changes (new dependency, framework swap, database / queue / SDK added), data flow changes, or when a decisions ADR is accepted that alters how the system is built. Also use when the project has no architecture.md yet and the architecture is taking shape. Trigger proactively even without explicit mention of "architecture" — any conversation about how the system is structured *now*, what it's built with, or how modules fit together should invoke this skill. architecture.md is the single source of truth for "what the system looks like now"; keeping it synced with the code prevents the onboarding blueprint from becoming fiction.
---

# Maintaining architecture.md

這個 skill 讓 Claude Code 正確維護 `.claude/docs/architecture.md`——專案「現行架構描述」的 single source of truth(系統現在長什麼樣、用什麼技術、模組如何協作)。

architecture.md 回答 **What is now**;需求(What must do)在 [SPEC.md](../../SPEC.md)、決策理由(Why)在 [decisions](../../docs/decisions/decisions.md)、開發規範(constitution)在 [CLAUDE.md](../../CLAUDE.md)。本 skill 守的邊界:architecture.md 描述現況、連結到 ADR 說明理由,不重述需求、不展開決策推理。

---

## 為何需要這層保護

架構描述與實際 code 脫節,是 onboarding 文件「看起來還活著、其實已是化石」的主因:

- 加了新模組但架構圖沒更新 → 新人照圖找不到東西。
- 換了框架 / 加了依賴但 Tech Stack 沒同步 → 安裝與理解都從錯的前提出發。
- 重構了目錄但 Code Structure 沒改 → AI 把檔案建到舊位置。

**架構文件的價值等於它的新鮮度。** Tech Stack 與 Architecture 從 CLAUDE.md 抽到本檔後,本 skill 負責讓它與現況同步。

---

## 觸發情境

| 類別 | 何時觸發 |
|------|---------|
| 結構變更 | 新增 / 移除模組、服務、元件;目錄重組 |
| Tech Stack | 新依賴、換框架、加 DB / queue / SDK、語言版本變更 |
| 資料流 | 核心請求 / 處理流程改變 |
| 決策連動 | decisions 新 ADR 改變了現行架構 → 同步 architecture.md 對應段落 + Design Decisions 索引 |
| 專案無 architecture.md | 走 Workflow A 首次建立 |

純內部實作細節(函式重構、變數命名)不觸發。

---

## Workflow A：初次建立(template placeholder 替換)

### Step A1：確認 entry condition

`<!-- TEMPLATE NOTICE` 區塊仍在頂端 → 未客製化,走 Workflow A:

```bash
grep -n '<!-- TEMPLATE NOTICE\|<[a-zA-Z][^>]*>' .claude/docs/architecture.md
```

未命中 NOTICE → 已客製化,改走 Workflow B。

### Step A2：從對話與 code 推導內容

架構資訊基本成形(模組切分、tech stack 已選)才填。尚未成形 → 暫停,告知 user 先用 `superpowers:brainstorming` 釐清架構,placeholder 留待後補。

填寫對象:System Overview 圖、Components 表、Tech Stack 表、Code Structure 樹、(選配)Data Flow、Design Decisions 索引(連到已有的 ADR)。

### Step A3：展示草稿取得確認

展示 dry-run(placeholder 清單)+ 替換後內容 + NOTICE 清理計畫 + 版本基線(`v1.0.0` / 今日)。**不直接寫檔。**

### Step A4：User 確認後寫入

1. 移除 NOTICE 區塊(含前後空行)。
2. 替換各 `<...>` placeholder。
3. footer 填 `Last Updated` 今日、`Version: v1.0.0`。

### Step A5：Commit

```bash
git add .claude/docs/architecture.md
git commit -m "docs(architecture): initial architecture description"
```

---

## Workflow B：更新現有 architecture.md

### Step B1：分析影響範圍

自問:影響哪一節?(System Overview / Components / Tech Stack / Code Structure / Data Flow / Design Decisions)是現況變更還是純實作細節?純細節 → 不更新。

### Step B2：展示 diff 取得確認

    architecture.md 更新建議

    **變更原因**：[新模組 / 換框架 / ADR 連動 ...]
    **受影響章節**：[節名 + 具體影響]
    **建議更新**：
    ```diff
    [diff]
    ```
    **版本影響**：vX.Y.Z → vX.Y'.Z'

    是否確認?

三條原則同其他 maintaining-* skill:未確認不改檔、先展示 diff、user 有意見先討論。

### Step B3：寫入並同步版本

1. Edit 對應章節。
2. footer:`Last Updated` 今日、`Version` 依 SemVer 遞增。
3. 若變更源於某 ADR → Design Decisions 表加 / 改對應 cross-ref。
4. architecture.md 變更**獨立成一個 commit**:`docs(architecture): <描述>`。分支策略比照 `maintaining-claude-md`(功能分支就地 commit;主分支開 `docs/architecture-<topic>`)。

### Step B4：連動評估

| 變更含 | 連動 |
|--------|------|
| 改變了「為什麼這樣設計」 | 啟用 `maintaining-decisions-md` 開 / 更新 ADR |
| 影響 User 安裝 / 使用(新依賴、新入口) | 啟用 `maintaining-readme-md` |
| 對應需求也變了 | 啟用 `maintaining-spec-md` |

---

## Semantic Versioning 規則

| 變更類型 | 遞增 |
|---------|------|
| 重大架構重構、移除核心元件 | Major |
| 新增模組 / 元件 / 依賴 | Minor |
| 描述釐清、圖表修正、錯字 | Patch |

footer 三處(`Last Updated`、`Version`)與內容一致。

---

## 與其他 skill / rule 的互動

| 對象 | 關係 |
|------|------|
| `maintaining-claude-md` | Tech Stack / Architecture 已從 CLAUDE.md 移入本檔;CLAUDE.md 只留指標連結。涉及二者時各改各的 SoT |
| `maintaining-decisions-md` | architecture.md 的 Design Decisions 每條 cross-ref 一條 ADR;架構決策先開 ADR(Why),再更新 architecture.md(What is now) |
| `maintaining-spec-md` | SPEC 需求變更帶來架構調整時連動本 skill |
| `maintaining-readme-md` | 架構變更影響 User 安裝 / 使用時連動 |
| `.claude/rules/documentation-style.md` | 章節英文 / 內文繁中 / Mermaid 圖表慣例;footer 格式 |
| `.claude/rules/git-rules.md` | Commit 格式(`docs(architecture):`);獨立 commit |

---

## Gotchas（容易忘記的關鍵點）

- **architecture.md 是 Tech Stack 的唯一 SoT**:抽出後別又寫回 CLAUDE.md,否則雙頭維護。
- **Design Decisions 只放摘要 + ADR 連結**:完整 Context / Alternatives 在 decisions,不在此複製。
- **圖優先 Mermaid**:可版控、AI 可讀、GitHub / Claude Code 可渲染。
- **User 未確認前不寫檔**:展示 diff → 確認 → 才動手。
