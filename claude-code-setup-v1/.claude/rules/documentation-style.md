# Documentation Style Guide

本專案的文檔編寫規範。適用於 user-facing markdown 檔案（CLAUDE.md、SPEC.md、README.md、docs/*、CHANGELOGs 等）。

> **`.claude/rules/*.md`、`.claude/skills/**/SKILL.md` 與 `.claude/docs/decisions/CONVENTIONS.md` 不在本指南的「章節標題用英文」規則範圍內**——這些是給 Claude 與內部開發者閱讀的內部規範類文件,允許中文章節標題以維持閱讀流暢度。footer 慣例、Markdown 結構、Mermaid 等其他規則仍適用。
>
> **`.claude/docs/architecture.md` 適用標準規則**(章節英文 / 內文繁中 / footer 含 Version)——它是現行架構描述,屬產品 / 工程文檔。`.claude/docs/decisions/decisions.md` 為決策 log,比照 CHANGELOG(無 footer)。

---

## 章節分隔符

- 只在 Footer 前加 `---`
- 章節之間不加分隔線（`##` 標題本身已有視覺層次）

## Footer 格式

### 需 footer 的檔案類型

- `.claude/CLAUDE.md`：主規範，與 `CLAUDE-CHANGELOG.md` pair，由 `maintaining-claude-md` skill 維護
- `.claude/docs/architecture.md`：現行架構描述，由 `maintaining-architecture-md` skill 維護
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
- `.claude/docs/decisions/CONVENTIONS.md`：規範類參考文件，同 `rules/*.md`
- CHANGELOG 類與 `decisions.md`：本身即為歷史 / 決策紀錄，不需再加 footer

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

## 語言規範

本專案文檔採以下語言慣例：

| 元素 | 語言 | 範例 |
|------|------|------|
| 章節標題（`#`、`##`、`###`） | 英文 | `## Quick Start` / `## Architecture` |
| 內文敘述 | 繁體中文 | 「本服務負責接收外部數據...」 |
| 技術術語 | 英文 | `API`、`endpoint`、`fixture`、`hook` |
| 程式碼註解 | 英文 | `# Initialize cache pool` |
| Commit message | 英文 | `feat(user): add registration` |

**為何這樣切分**：章節英文便於跨團隊 / 國際資源 reference；內文繁中降低 user 認知負擔；技術術語保留英文避免翻譯失真（例：「fixture」翻成「測試夾具」反而模糊原意）。

---

## 章節命名標準（常用）

| 概念 | 統一命名 |
|------|----------|
| 概述 | `Overview` |
| 快速開始 | `Quick Start` |
| 架構 | `Architecture` |
| 配置 | `Configuration` |
| 使用方式 | `Usage` |
| 測試 | `Testing` |
| 問題排解 | `Troubleshooting` |

依文檔性質選用，非全部必寫。專案專屬的章節（例：`API Endpoints` / `Migration` / `Contributing` / `Examples`）以英文命名即可，不強制統一格式。

---

## 文檔類型模板

本專案定義三類 `docs/` 文檔模板，實際模板檔案由 `maintaining-readme-md` skill 的 bundled references 管理：

| 類型 | 用途 | 模板檔案 |
|------|------|---------|
| Service | 單一服務或模組的說明 | `.claude/skills/maintaining-readme-md/references/service-template.md` |
| Reference | CLI / config / API 參考手冊 | `.claude/skills/maintaining-readme-md/references/reference-template.md` |
| Guide | Troubleshooting、How-to、概念說明 | `.claude/skills/maintaining-readme-md/references/guide-template.md` |

當 `maintaining-readme-md` skill 啟用時，會自動依文檔性質選用對應模板。
