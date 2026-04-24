# Documentation Style Guide

本專案的文檔編寫規範。適用於所有 markdown 檔案（CLAUDE.md、SPEC.md、README.md、docs/*、CHANGELOGs 等）。

---

## 章節分隔符

- 只在 Footer 前加 `---`
- 章節之間不加分隔線（`##` 標題本身已有視覺層次）

## Footer 格式

### 需 footer 的檔案類型

- `.claude/CLAUDE.md`：主規範，與 `CLAUDE-CHANGELOG.md` pair，由 `maintaining-claude-md` skill 維護
- User 專案的產品文檔：`SPEC.md`、`README.md`、`docs/*.md`

統一格式：

```markdown
---

**Last Updated**: YYYY-MM-DD
**Version**: vX.Y.Z
```

- `**Last Updated**`：必填，ISO 8601 日期格式（YYYY-MM-DD）
- `**Version**`：必填，採 [Semantic Versioning](https://semver.org/)

### 不需 footer 的檔案類型

- `.claude/rules/*.md`：規範類參考文件，版本追蹤由專案 CHANGELOG 代管；per-rule versioning 會造成各 rule 版本號互不相干、user 也不會每次編輯都同步，是反模式
- `.claude/skills/*/SKILL.md`：由 template 自身 `CHANGELOG.md` 追蹤演進
- CHANGELOG 類檔案：本身即為歷史紀錄（Keep a Changelog 格式），不需再加 footer

## 標題層級

- `#` (h1): 文檔標題，每個檔案只有一個
- `##` (h2): 主要章節
- `###` (h3): 子章節
- `####` (h4): 細節項目（盡量避免）

## 介紹段落

文檔開頭使用一句話直接描述功能，不使用「本文件說明...」等冗贅句式。

```markdown
# Receiver Service

資料接收服務，負責接收外部數據、驗證格式、暫存 Redis。
```

## 程式碼區塊

| 內容類型 | 語言標記 |
|----------|----------|
| Bash 命令 | ` ```bash ` |
| JSON | ` ```json ` |
| Python | ` ```python ` |
| TypeScript | ` ```typescript ` |
| YAML | ` ```yaml ` |
| TOML | ` ```toml ` |
| Mermaid 圖表 | ` ```mermaid ` |
| 一般輸出 / Log | ` ``` `（無標記） |

## 圖表

- 盡量使用 Mermaid 圖表（可版本控制、AI 可讀、渲染在 GitHub / Claude Code）
- 適用場景：
  - 系統架構 → `graph TB` / `graph LR`
  - 資料流程 → `sequenceDiagram`
  - 狀態轉換 → `stateDiagram`
  - 類別關係 → `classDiagram`

## 交叉連結

- 不需獨立「Related Documentation」章節
- 在內文中適時加入相關文檔連結
- 連結格式：`[顯示文字](檔案名.md#錨點)`

---

## 章節命名標準（常用）

| 概念 | 統一命名 |
|------|----------|
| 概述 | `Overview` |
| 快速開始 | `Quick Start` |
| 架構 | `Architecture` |
| API 說明 | `API Endpoints` |
| 配置 | `Configuration` |
| 使用方式 | `Usage` |
| 測試 | `Testing` |
| 問題排解 | `Troubleshooting` |
| 範例 | `Examples` |
| 貢獻 | `Contributing` |

---

## 文檔類型模板

本專案定義三類 `docs/` 文檔模板，實際模板檔案由 `maintaining-readme-md` skill 的 bundled references 管理：

| 類型 | 用途 | 模板檔案 |
|------|------|---------|
| Service | 單一服務或模組的說明 | `.claude/skills/maintaining-readme-md/references/service-template.md` |
| Reference | CLI / config / API 參考手冊 | `.claude/skills/maintaining-readme-md/references/reference-template.md` |
| Guide | Troubleshooting、How-to、概念說明 | `.claude/skills/maintaining-readme-md/references/guide-template.md` |

當 `maintaining-readme-md` skill 啟用時，會自動依文檔性質選用對應模板。

---

## 撰寫檢查清單

撰寫或更新 `docs/` 文檔時確認：

- [ ] 標題層級正確（`#` → `##` → `###`）
- [ ] 程式碼區塊有正確的語言標記
- [ ] 架構或流程使用 Mermaid 圖表
- [ ] Footer 包含 `**Last Updated**` + `**Version**`（僅 user 產品文檔；rules、SKILL.md、CHANGELOG 不需）
- [ ] 內文有適當的交叉連結
- [ ] 章節順序符合對應模板（Service / Reference / Guide）
