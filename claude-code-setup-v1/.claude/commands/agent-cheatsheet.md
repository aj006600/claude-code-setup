---
description: 列出本專案當前可用的 agents、skills、commands、MCPs 及其最佳使用時機
---

從當前 session 動態彙整可用資源並以分類速查表呈現。**只列出實際存在的資源**——以 `ls` 輸出與 session system-reminder 為準,不照抄模板,不揣測 user 環境是否安裝某 plugin / MCP。

## How to gather

### 1. Project-local resources

```bash
ls .claude/agents/   2>/dev/null
ls .claude/skills/   2>/dev/null
ls .claude/commands/ 2>/dev/null
```

每個本地 agent / skill 的描述從對應檔案的 frontmatter `description` 欄位摘取一行。

### 2. Plugin / global resources

從當前 session 的 system-reminder 訊息提取:
- Available agents(Agent tool 列表)
- Available skills(Skill tool 列表)
- Active MCP servers

### 3. 標註原則

- **Scope tag**:每個 entry 加 `[project-local]` / `[plugin:<name>]` / `[global]`,避免同名衝突(例:`feature-dev:code-reviewer` plugin agent vs 任何同名 entry;global skills vs project skills)
- **描述對齊 cross-ref**:不要對單一 entry 編造定位,以 `tdd-feature-workflow/SKILL.md`「關鍵分工」表與 `CLAUDE.md`「Available Resources」既有描述為準。例如 `superpowers:code-reviewer` 應寫「dispatch by `superpowers:requesting-code-review`、結果返回對話」,不寫「preferred for X」這類沒有 cross-ref 支持的定位

## Output 骨架

按以下骨架填入步驟 1-2 找到的實際資源;類別無條目則 omit 整段。

```
Agents & Skills Cheatsheet (<Project Name>)

━━ Agents (via Agent tool) ━━

[Project-local] — 透過 skill 委派或 Agent tool 使用
- <agent-name> [project-local] — <一行用途;從 agents/<file>.md frontmatter 摘取>

[Plugin / global] — 視已安裝 plugin 而定
- <plugin>:<agent> [plugin:<plugin>] — <一行用途>

━━ Skills (via Skill tool) ━━

[Project maintenance] — 編輯 SPEC / CLAUDE / README 時觸發
- <skill> [scope-tag] — <用途>

[Feature development] — feature / bug / refactor 起點 ~ PR ~ merge
- <skill> [scope-tag] — <用途>
- 選配:`feature-dev:code-architect` / `feature-dev:code-explorer` [plugin:feature-dev] — 需深度探索 codebase 或對比多個架構方案時(若 plugin 已安裝)

[Code review & verification] — pre-PR 審查、reviewer 反饋處理
- <skill> [scope-tag] — <用途>

[Investigation & process] — brainstorming / debugging / 探索
- <skill> [scope-tag] — <用途>

━━ Commands (slash) ━━
- /<command> [project-local | plugin:<name>] — <一行用途>

━━ MCPs ━━ — 僅列當前 session 出現的 active MCP
- <mcp-name> — <用途>

━━ Usage Tips ━━

- One-off sub-task with isolated context → Agent tool
- Multi-step workflow with procedural knowledge → Skill tool
- User-initiated action → slash command
- Direct query / file operation → Read / Grep / Bash / Edit
```
