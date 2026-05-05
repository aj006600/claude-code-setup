# Documentation Style Guide

專案文檔編寫規範。

---

## 通用規範

### 章節分隔符

- 只在 Footer 前加 `---`
- 章節之間不加分隔線（`##` 標題本身已有視覺層次）

### Footer 格式

所有文檔結尾統一使用：

```markdown
---

**Last Updated**: YYYY-MM-DD
```

### 標題層級

- `#` (h1): 文檔標題，每個檔案只有一個
- `##` (h2): 主要章節
- `###` (h3): 子章節
- `####` (h4): 細節項目（盡量避免）

### 介紹段落

文檔開頭使用一句話直接描述功能，不使用「本文件說明...」等冗贅句式。

```markdown
# Receiver Service

資料接收服務，負責接收外部數據、驗證格式、暫存至快取。
```

### 程式碼區塊

| 內容類型 | 語言標記 |
|----------|----------|
| Bash 命令 | ` ```bash ` |
| JSON | ` ```json ` |
| Python | ` ```python ` |
| Mermaid 圖表 | ` ```mermaid ` |
| 一般輸出/Log | ` ``` `（無標記） |

### 圖表

- 盡量使用 Mermaid 圖表
- 適用場景：系統架構（`graph`）、資料流程（`sequenceDiagram`）、狀態轉換（`stateDiagram`）

### 交叉連結

- 不需獨立「Related Documentation」章節
- 在內文中適時加入相關文檔連結
- 連結格式：`[顯示文字](檔案名.md#錨點)`

---

## 文檔類型與模板

### 類型一：Service 文檔

適用：各服務說明文檔（如 `xxx-service.md`）

**章節順序**：

```
Overview → Quick Start → Architecture → API Endpoints → Configuration → Usage → Testing
```

**模板**：

```markdown
# [Service Name]

[一句話描述服務功能]

## Overview

[服務的主要功能，使用 bullet points]

- 功能一
- 功能二
- 功能三

## Quick Start

### 啟動服務

```bash
[啟動命令]
```

### 基本操作

```bash
[curl 範例]
```

## Architecture

```mermaid
graph TB
    [架構圖]
```

## API Endpoints

### POST /api/xxx

[端點說明]

**Request:**
```json
{
  "field": "value"
}
```

**Response (200 OK):**
```json
{
  "success": true
}
```

### GET /api/xxx

[端點說明]

**Response:**
```json
{
  "status": "ok"
}
```

## Configuration

透過環境變數配置，詳細說明請參考 [Configuration Reference](config.md#xxx)。

| 變數 | 說明 |
|------|------|
| `VAR_NAME` | 變數說明 |

## Usage

[進階使用場景、與其他服務整合]

## Testing

```bash
# 執行相關測試
uv run pytest tests/unit/... -v

# 執行整合測試
uv run pytest tests/integration/... -v
```

---

**Last Updated**: YYYY-MM-DD
```

---

### 類型二：Reference 文檔

適用：`cli.md`, `config.md`, `agent.md`

**特點**：
- 參考手冊風格，表格為主
- 超過 100 行可加入 Quick Reference 章節

**模板**：

```markdown
# [Reference Title]

[一句話描述]

## Overview

[功能概述]

## Quick Reference

> 選擇性：文檔超過 100 行時才加入

| 項目 | 說明 |
|------|------|
| 常用項目 1 | 簡短說明 |
| 常用項目 2 | 簡短說明 |

## [主要章節 1]

### [子章節]

| 欄位 | 說明 |
|------|------|
| `field_name` | 欄位說明 |

## [主要章節 2]

[內容]

---

**Last Updated**: YYYY-MM-DD
```

---

### 類型三：Guide 文檔

適用：`troubleshooting.md`

**特點**：
- 說明性文字和圖表為主
- 引導讀者理解概念或解決問題

**模板**：

```markdown
# [Guide Title]

[一句話描述]

## Overview

[指南目的和適用場景]

## [主題 1]

```mermaid
[圖表]
```

[說明文字]

## [主題 2]

### [情境 A]

**症狀**：[問題描述]

**解決方案**：

1. 步驟一
2. 步驟二

---

**Last Updated**: YYYY-MM-DD
```

---

## 章節命名標準

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

---

## 檢查清單

撰寫或更新文檔時，確認以下項目：

- [ ] 標題層級正確（`#` → `##` → `###`）
- [ ] 程式碼區塊有正確的語言標記
- [ ] 架構或流程有使用 Mermaid 圖表
- [ ] Footer 格式正確（`---` + `**Last Updated**`）
- [ ] 內文有適當的交叉連結
- [ ] 章節順序符合對應模板

---

**Last Updated**: 2026-01-24
