# Service Documentation Template

> **用途**：`docs/<service-name>.md` 類型文檔（例如 `docs/receiver-service.md`、`docs/auth-service.md`）。
>
> **固定章節順序**：Overview → Quick Start → Architecture → API Endpoints → Configuration → Usage → Testing
>
> **使用**：複製下方「---」以下的結構，替換所有 `[...]` 佔位符。同時遵循 `.claude/rules/documentation-style.md` 的通用規範。

---

# [Service Name]

[一句話描述服務功能]

## Overview

[服務的主要功能，使用 bullet points]

- [功能一]
- [功能二]
- [功能三]

## Quick Start

### 啟動服務

```bash
[啟動命令，例如：uv run uvicorn src.main:app --reload]
```

### 基本操作

```bash
[curl / CLI 範例]
```

## Architecture

```mermaid
graph TB
    [架構圖 — 展示本服務與其他元件的關係]
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

**Error Responses:**

```json
{
  "error": "ERROR_CODE",
  "message": "[錯誤說明]"
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

| 變數 | 說明 | 預設值 |
|------|------|--------|
| `VAR_NAME` | [變數說明] | [預設值] |

## Usage

[進階使用場景、與其他服務整合範例]

## Testing

```bash
# 單元測試
uv run pytest tests/unit/<module>/ -v

# 整合測試
uv run pytest tests/integration/ -v -m integration
```

---

**Last Updated**: YYYY-MM-DD
**Version**: v1.0.0
