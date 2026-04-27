---
name: maintaining-readme-md
description: Use when the user introduces new features, changes API or CLI interfaces, modifies installation / setup steps, adds dependencies, changes user-visible architecture, updates configuration options, renames public modules, or when SPEC.md / CLAUDE.md upstream changes affect user-facing content. Trigger proactively even without explicit mention of "README" or "documentation" — any conversation about user-facing changes, new features, install / setup, or how-to-use aspects should invoke this skill, because user-facing docs drifting from implementation is how developers judge whether a project is alive or abandoned.
---

# Maintaining README.md and docs/

這個 skill 讓 Claude Code 正確維護 `README.md` 與 `docs/`——專案對外的 User-facing 文檔。

---

## 為何需要同步維護

README 是接觸專案的**第一印象**:
- README 過期 → 新用戶照舊指南操作失敗 → 對專案失去信任
- docs/ 過期 → 開發者找不到正確資訊 → 讀 source code 或放棄
- 安裝步驟錯 → 專案看似「abandoned」,即使仍在活躍開發

**Open source 世界裡,文檔即信任。** 大量專案死於文檔落後於程式碼。本 skill 設計宗旨:**把文檔更新視為功能的一部分,而非功能完成後的「待辦事項」**——後者幾乎總是被遺忘。

---

## 觸發情境

| 類別 | 何時觸發 |
|------|---------|
| User-facing 實作 | 新功能、API / CLI 變更、安裝步驟、架構(User 可感知)、設定選項、公開模組重命名 |
| 上游連動 | SPEC.md Overview 改動 → README Overview;CLAUDE.md Tech Stack 新依賴 → Installation;Architecture 改動 → docs/ |
| docs/ 專屬 | 新功能需詳細 Service 文檔、API 文檔、新範例 / tutorials / troubleshooting |

---

## 智慧延後邏輯(核心設計)

Description 觸發後,**不要立刻動手**——先判斷實作狀態,避免在 TDD 中途或 code review 前產出錯的文檔:

| 狀態 | 判斷依據 | 對應策略 |
|------|---------|---------|
| **A:實作中** | 測試尚未全通過、程式碼未定稿、User 迭代中 | **記錄 + 延後**:TodoWrite 記錄「待更新 README」,口頭告知 User,不進 Step 1 |
| **B:實作完成、未開 PR** | 測試通過、功能定稿、未建立 PR | **立即執行**:最佳時機,進 Step 1 |
| **C:已開 PR、Review 中 / 通過** | PR 存在、branch 未 merge | **立即執行**:加入同一 PR(不另開分支),進 Step 1 |
| **D:已 merge 到 dev / qas / main** | 回追發現遺漏文檔 | **補救**:建 `docs/update-readme-<feature>` 分支,進 Step 1 |

**狀態 A 的延後話術**:

    已偵測到本次變更會影響 README.md

    影響文檔:[README 章節] + [可能的 docs/ 檔案]

    目前判斷:功能仍在實作中(尚未到穩定狀態),暫不更新文檔以免產出過期內容。
    已記錄此項待辦,實作完成後會主動提醒您。

---

## Workflow:更新 README.md 與 docs/

### Step 1:分析本次變更對 User 的影響

自問:
- 影響 User 如何安裝? → Installation
- 影響 User 如何使用? → Usage / Quick Start
- 影響 User 理解架構? → Architecture
- 影響現有 API / CLI 用法? → API Reference / CLI docs
- 需新教學或範例? → docs/tutorials/
- 破壞性變更? → docs/migration.md

### Step 2:決定更新範圍

| 變更性質 | 更新範圍 |
|---------|---------|
| 小幅功能變更、範例更新 | 僅 README |
| 需詳細說明的新功能 | README(簡述 + 連結) + docs/(詳細) |
| 架構重構、破壞性變更 | README + docs/architecture + docs/migration |
| 僅內部重構(User 無感) | **不觸發本 skill**(疑慮時問 User 確認) |

### Step 3:委派 `documentation-engineer` agent 產出內容

使用 Agent tool,傳遞明確 context:

```
Agent({
  subagent_type: "documentation-engineer",
  description: "Update README for <feature>",
  prompt: `
    更新 README.md 與 docs/ 以反映新功能:[名稱]

    **變更摘要**:[內容]
    **受影響章節**:
    - README.md: [清單]
    - docs/: [檔案清單]

    **務必先讀**:
    1. \`.claude/rules/documentation-style.md\`(通用規範)
    2. 依類型讀對應模板:
       - Service → \`.claude/skills/maintaining-readme-md/references/service-template.md\`
       - Reference(CLI / config / API)→ \`.claude/skills/maintaining-readme-md/references/reference-template.md\`
       - Guide(troubleshooting / how-to)→ \`.claude/skills/maintaining-readme-md/references/guide-template.md\`

    **語言規範**:依 `.claude/rules/documentation-style.md` 的「語言規範」章節(章節英文 / 內文繁中 / 技術術語英文)。
    **不要直接改檔**,先輸出完整 diff / 新增內容草稿。
  `
})
```

**為何委派而非自行產出**:`documentation-engineer` agent 專精 API doc、教學設計、info architecture。Skill 是 orchestrator(決定何時、更新什麼),agent 是 specialist(決定怎麼寫得好)。

### Step 4:展示 diff 取得 User 確認

組織 agent 產出:

    README / docs 更新建議

    **變更原因**:[為什麼]
    **受影響檔案**:[清單 + 章節]

    **建議更新內容**:
    ```diff
    [README.md diff]
    ```

    **新增檔案 docs/xxx.md**:
    ```markdown
    [完整內容]
    ```

    是否確認?

### Step 5:依狀態執行 commit

**狀態 B / C**(功能分支或 PR 中)→ 在當前分支直接 commit 到同一 PR:

```bash
git add README.md docs/
git commit -m "docs(readme): update README and docs for <feature-name>"
```

**狀態 D**(已 merge 補救):

```bash
git checkout dev && git pull
git checkout -b docs/update-readme-<feature>
git add README.md docs/
git commit -m "docs(readme): retroactively update README for <feature>"
git push origin docs/update-readme-<feature>
# 建立 PR 到 dev
```

### Step 6:連動回查上游

執行中若發現變更源頭其實來自 SPEC.md 或 CLAUDE.md 但那些檔案尚未同步更新,提醒 User:

> 本次 README 變更對應的功能 / 架構,在 SPEC.md 或 CLAUDE.md 尚未反映。建議先啟用 `maintaining-spec-md` / `maintaining-claude-md` 更新上游,避免規範鏈斷裂。

---

## README 與 docs/ 分工原則

| 維度 | README.md | docs/ |
|------|-----------|-------|
| 目標讀者 | 首次訪問者、評估是否使用 | 決定使用後、查找細節 |
| 長度 | 精簡(避免滾動疲勞) | 可長可分散 |
| 內容 | Overview / Quick Start / Features / Installation / 核心 Usage / 連到 docs/ | 詳細 Service / Reference / Guide / Troubleshooting |
| 更新頻率 | 重大功能、使用方式、版本 | 任何細節變更 |

**關鍵**:README 提供「為什麼用 + 怎麼立刻開始」,docs/ 提供「完整使用與維運知識」。

---

## README 版本對齊規則

`documentation-style.md` 規定 README footer 必含 `**Version**`。版本如何升,依下表:

| 變更性質 | 版本策略 | 範例 |
|---------|---------|------|
| README 反映 SPEC.md 的需求變更(新功能、API、架構) | **與 SPEC.md 同步**,共用同一版號 | SPEC v1.5.0 → README v1.5.0 |
| 純 README / docs 文字修正(錯字、格式、範例補強)不對應 SPEC 變更 | **獨立 patch bump** | README v1.5.0 → v1.5.1 |
| 破壞性變更(API 重命名 / 移除) | 跟 SPEC 同步 major bump | SPEC v1.5.0 → v2.0.0 → README v2.0.0 |

**原則**:README 是 SPEC 對 user 的投影。SPEC 升版時 README 跟著升;但純文字修正不需要拉動 SPEC 版號(否則 SPEC 版號失去語意)。footer 的 `Last Updated` 一律更新為當日。

---

## 特殊情況

- **小型修正(錯字、格式)**:累積多個後一次委派 agent;commit:`docs(readme): fix typos and formatting`
- **功能延後或取消**:已寫入 README 的 → 移除 + deprecation notice;草稿 → 標 `[Coming Soon]` 或暫移除
- **破壞性變更**:強制新增 `MIGRATION.md` 或 CHANGELOG 條目;README 顯著位置標註;保留舊版 + deprecated 標記 + 指向新版

---

## 與其他 skill / rule 的互動

| 對象 | 關係 |
|------|------|
| `maintaining-claude-md` | User-facing 變更時連動觸發本 skill |
| `maintaining-spec-md` | SPEC Overview 變更通常同時需更新 README 專案描述 |
| `documentation-engineer` agent | 本 skill 委派內容產出(skill orchestrate / agent write) |
| `.claude/rules/documentation-style.md` | 委派時須傳達:Service / Reference / Guide 模板、章節命名、Footer 格式 |
| `.claude/rules/git-rules.md` | Commit 格式;文檔更新屬功能 PR 的一部分 |

---

## Pattern 示例

**觸發**:`User: "CSV 匯出功能實作完成,測試都過了"`

**正確反應**(判斷狀態 B → 立即執行 + 委派):

    偵測到新功能實作完成(狀態 B),啟用 maintaining-readme-md skill。

    **受影響檔案**:
    1. README.md — Features + Usage 章節
    2. docs/export-guide.md(新增)— CSV 格式、選項、錯誤處理

    委派 documentation-engineer agent 產出草稿中...

    [展示 diff] 是否確認?

**錯誤反應**(功能完成就錯過最佳時機):

    Claude: 收到!功能完成了。要不要我幫忙開 PR?

→ README 沒更新、docs/ 沒新增,User 不會主動想到文檔,形成「功能有、文件無」。

---

## Gotchas(容易忘記的關鍵點)

- **狀態判斷優先於動手**:description 觸發不等於立刻執行;狀態 A 要延後,否則產出過期文檔
- **文檔屬於功能 PR 的一部分**:狀態 B / C 不另開分支,加入當前 branch;只有狀態 D(已 merge)才補救式開 docs 分支
- **委派 agent 時要傳風格規範**:傳遞 `.claude/rules/documentation-style.md` 引用(含章節英文 / 內文繁中 / 技術術語英文等慣例)——不傳會導致 agent 產出不一致的文體
- **先出草稿再改檔**:指示 agent 用 diff / 草稿形式呈現,Skill 取得 User 確認後才落檔
