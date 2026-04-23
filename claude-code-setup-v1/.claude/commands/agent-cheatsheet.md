---
description: 列出本專案當前可用的 agents、skills、commands、MCPs 及其最佳使用時機
---

Assemble and display a comprehensive cheat sheet of all agents, skills, commands, and MCPs currently available in this project.

## How to gather

### 1. Project-local resources
```bash
ls .claude/agents/   2>/dev/null
ls .claude/skills/   2>/dev/null
ls .claude/commands/ 2>/dev/null
```

### 2. Plugin / global resources
Check the system-reminder messages in the current session for:
- Available agents (Agent tool list)
- Available skills (Skill tool list)
- Active MCP servers

### 3. Organize by theme and scope

## Present as

```
Agents & Skills Cheatsheet (<Project Name>)

Note: 若以下清單中的 plugin / skill / MCP 未出現在 current session 的 system-reminder，
      代表該資源尚未安裝。請參考 template README 的 Prerequisites 章節進行安裝。

━━ Agents (via Agent tool) ━━

[Project-local]
- <agent-name> — <purpose>, use when <context>
  (e.g., test-automator, code-reviewer, documentation-engineer)

[Plugin / global]
- code-simplifier:code-simplifier — simplify code before PR
- general-purpose — open-ended research
- Explore — codebase exploration (read-only)
- Plan — architectural planning
- feature-dev:code-architect / code-explorer / code-reviewer — feature dev specialists

━━ Skills (via Skill tool) ━━

[Project maintenance] (trigger proactively per conversation context)
- maintaining-spec-md — SPEC.md changes
- maintaining-claude-md — CLAUDE.md changes
- maintaining-readme-md — README / docs changes

[Feature development] (trigger at start / during / end of feature work)
- tdd-feature-workflow (project) — 4-phase TDD orchestrator
- superpowers:executing-plans — execute written plans
- superpowers:test-driven-development — TDD discipline
- superpowers:writing-plans — plan authoring
- superpowers:verification-before-completion — final verification
- superpowers:finishing-a-development-branch — branch completion

[Code quality]
- simplify — code quality review
- superpowers:requesting-code-review — prepare code review
- code-review:code-review — PR review workflow
- security-review — security review

[Process]
- superpowers:brainstorming — design exploration
- superpowers:systematic-debugging — bug hunting
- superpowers:using-superpowers — meta-skill: skill discovery

[Cross-cutting]
- claude-api — Anthropic SDK / Claude API work
- graphify — any input → knowledge graph

━━ Commands (slash) ━━

- /project-status — quick status snapshot
- /pre-dev-check — pre-development check
- /pre-pr-check — pre-PR full check (tests, coverage, simplify, SPEC, README hints)
- /agent-cheatsheet — this cheat sheet

━━ MCPs ━━

- context7 — up-to-date library documentation
- arxiv-mcp-server — academic paper search
- github / gitlab — repository operations
- claude_ai_Gmail / claude_ai_Google_Calendar / claude_ai_Google_Drive — Google workspace

━━ Usage Tips ━━

- One-off sub-task with isolated context → Agent tool
- Multi-step workflow with procedural knowledge → Skill tool
- User-initiated action → slash command
- Direct query / file operation → Read / Grep / Bash / Edit
```
