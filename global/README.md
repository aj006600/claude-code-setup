# global

Global Claude Code 配置 -- 對應 `~/.claude/CLAUDE.md`，所有專案共用的基礎行為設定。

## Overview

此資料夾存放 Claude Code 的 global 層級配置。`~/.claude/CLAUDE.md` 是 Claude Code 在任何專案都會載入的指令，優先級低於專案層級的 `.claude/CLAUDE.md`。

適合放在 global 的內容：
- User 身份與語言偏好
- Context window 管理策略
- 通用行為指令（default to action、parallel tool calls、investigate before answering）
- 跨專案適用的 coding 原則（avoid overengineering、clean up temp files）
- Global skills 註冊（如 `/graphify`）

## What's Included

| 檔案 | 說明 |
|------|------|
| `CLAUDE.md` | Global 配置 snapshot（對應 `~/.claude/CLAUDE.md`） |

## Usage

將 `CLAUDE.md` 複製到 `~/.claude/`：

```bash
cp global/CLAUDE.md ~/.claude/CLAUDE.md
```

修改後記得同步回本 repo 以保持 snapshot 一致。
