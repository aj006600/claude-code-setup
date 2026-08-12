# claude-code-setup-v2

Claude Code 協作套件:一份 CLAUDE.md 骨架 + 三個 guard hooks + 共享 settings。原則是「能用工具強制的不寫成文件」——紀律性規則(不推 main、防跨 repo 引用外洩)用 PreToolUse hooks 擋在執行前,CLAUDE.md 只留工具做不到的慣例。整套設計搭配 mattpocock skills 與 trunk-based development 運作(`main` 為唯一長期分支,改動走短命 feature branch → PR → squash merge,打 tag 發版)。

## Prerequisites

CLAUDE.md 的慣例會用到 mattpocock skills(`/research` 等)與 context7(查 library 文檔),文件工作則用 doc-coauthoring。三者都裝在 user 層級,一台機器裝一次即可:

```bash
# mattpocock skills(官方 marketplace,免加來源)
claude plugins install mattpocock-skills

# context7 MCP(先到 https://context7.com/dashboard 免費申請 API key,替換下行的 YOUR_API_KEY 再執行)
claude mcp add --scope user --header "Authorization: Bearer YOUR_API_KEY" --transport http context7 https://mcp.context7.com/mcp

# doc-coauthoring skill(取自 anthropics/skills,結構化文件共筆流程)
mkdir -p ~/.claude/skills/doc-coauthoring
curl -fsSL https://raw.githubusercontent.com/anthropics/skills/main/skills/doc-coauthoring/SKILL.md -o ~/.claude/skills/doc-coauthoring/SKILL.md
```

另外一項 user 層級設定:關閉 Claude Code 在 commit / PR 自動附加的署名(`attribution` 設空字串即隱藏,安全合併進 `~/.claude/settings.json`,既有設定不受影響;重啟 session 生效):

```bash
python3 - <<'EOF'
import json, pathlib
p = pathlib.Path.home() / ".claude" / "settings.json"
d = json.loads(p.read_text()) if p.exists() else {}
d["attribution"] = {"commit": "", "pr": ""}
p.write_text(json.dumps(d, indent=2, ensure_ascii=False) + "\n")
EOF
```

## What's inside

```
CLAUDE.md                          # 骨架:workflow + 9 條通用 conventions,<...> 佔位符待填
.claude/settings.json              # hooks 註冊 + permissions 白名單(對應 CLAUDE.md Commands 表,make 為範例)
.claude/hooks/
├── block-push-main.sh             # 硬擋任何寫入遠端 main 的 push(放行 feature branch 與 tag)
├── external-ref-guard.sh          # 硬擋 commit/PR/issue 中的跨 repo 引用(防不可逆 backlink 通知)
└── secrets-scan-advisory.sh       # git add/commit 前掃疑似密鑰(僅警告;豁免清單依 repo 調整)
```

## Setup

1. 複製檔案到專案根目錄(在本目錄 `claude-code-setup-v2/` 下執行,`<project>` 換成目標專案路徑;目標若已有同名檔案會被覆蓋):

   ```bash
   cp -R CLAUDE.md .claude <project>/
   ```

2. 填 `CLAUDE.md` 的 `<...>` 佔位符(Commands 表、Conventions 第 1 條的 `<檢查指令>`、部署節奏)
3. 依專案調整:Conventions 標註「範例」處、`.claude/settings.json` 的 permissions 清單(`make` 換成你的建置工具)、secrets hook 的豁免清單
4. 重啟 Claude Code session,hooks 生效(settings 在 session 啟動時載入)
5. 在 session 內打 `/setup-matt-pocock-skills`(per-repo 初始化,一個 repo 一次):回答 issue tracker / triage labels / domain docs 三題,產出 `docs/agents/` 與 CLAUDE.md 末尾的 `## Agent skills`,供 `/triage`、`/to-tickets`、`/wayfinder` 等讀取
