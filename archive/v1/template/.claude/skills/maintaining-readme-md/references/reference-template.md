# Reference Documentation Template

> **用途**：參考手冊類文檔（例如 `docs/cli.md`、`docs/config.md`、`docs/api.md`）。
>
> **特點**：查閱為主，非敘事；超過 100 行建議加 Quick Reference 章節。
>
> **使用**：複製下方「---」以下的結構，替換所有 `[...]` 佔位符。同時遵循 `.claude/rules/documentation-style.md` 的通用規範。

---

# [Reference Title]

[一句話描述]

## Overview

[功能概述]

## Quick Reference

> 選擇性：文檔超過 100 行時才加入，方便讀者快速查找

| 項目 | 說明 |
|------|------|
| [常用項目 1] | [簡短說明] |
| [常用項目 2] | [簡短說明] |

## [主要章節 1]

### [子章節]

| 欄位 | 說明 | 預設值 |
|------|------|--------|
| `field_name` | [欄位說明] | [預設值] |

## [主要章節 2]

### [子項目]

[詳細說明]

```bash
[範例命令或配置]
```

**參數說明：**

- `--flag`: [flag 說明]
- `--option <value>`: [option 說明]

---

**Last Updated**: YYYY-MM-DD
**Version**: v1.0.0
