# claude-code-setup

Claude Code 配置集合:一份現行的專案 setup template、一份 global 配置 snapshot,以及歷代封存版本。

---

## Current

| 資料夾 | 內容 |
|------|------|
| [`template/`](./template/) | 專案層 setup template — 一份 CLAUDE.md 骨架 + 三個 guard hooks + 共享 settings。原則是「能用工具強制的不寫成文件」,搭配 mattpocock skills 與 trunk-based development |
| [`global/`](./global/) | Global 配置(`~/.claude/CLAUDE.md`)snapshot — 所有專案共用的基礎行為設定 |

`template/` 裡只有會複製進專案的檔案,資料夾邊界就是複製範圍。它是唯一持續演進的 template,改動直接在原地進行,歷史由 git log 記錄,無版本號。

紀律性規則(不推 main、防跨 repo 引用外洩)用 PreToolUse hooks 擋在執行前,CLAUDE.md 只留工具做不到的慣例。整套設計搭配 mattpocock skills 與 trunk-based development 運作(`main` 為唯一長期分支,改動走短命 feature branch → PR → squash merge,打 tag 發版)。

```
template/
├── CLAUDE.md                          # 骨架:workflow + 9 條通用 conventions,<...> 佔位符待填
└── .claude/
    ├── settings.json                  # hooks 註冊 + permissions 白名單(對應 CLAUDE.md Commands 表,make 為範例)
    └── hooks/
        ├── block-push-main.sh         # 硬擋任何寫入遠端 main 的 push(放行 feature branch 與 tag)
        ├── external-ref-guard.sh      # 硬擋 commit/PR/issue 中的跨 repo 引用(防不可逆 backlink 通知)
        └── secrets-scan-advisory.sh   # git add/commit 前掃疑似密鑰(僅警告;豁免清單依 repo 調整)
```

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

## Setup

1. 把 `template/` 的內容複製到專案根目錄(在本 repo 根目錄執行,`<project>` 換成目標專案路徑;目標若已有同名檔案會被覆蓋):

   ```bash
   cp -R template/. <project>/
   ```

2. 填 `CLAUDE.md` 的 `<...>` 佔位符(Commands 表、Conventions 第 1 條的 `<檢查指令>`、部署節奏)
3. 依專案調整:Conventions 標註「範例」處、`.claude/settings.json` 的 permissions 清單(`make` 換成你的建置工具)、secrets hook 的豁免清單
4. 重啟 Claude Code session,hooks 生效(settings 在 session 啟動時載入)
5. 在 session 內打 `/setup-matt-pocock-skills`(per-repo 初始化,一個 repo 一次):回答 issue tracker / triage labels / domain docs 三題,產出 `docs/agents/` 與 CLAUDE.md 末尾的 `## Agent skills`,供 `/triage`、`/to-tickets`、`/wayfinder` 等讀取

---

## Archive

歷代 template 保留於 `archive/`,維持當時的資料夾名稱,內容可直接取用,僅移除 template 自身的紀錄檔,演進史由 git log 承載;新專案一律從 `template/` 出發。每一版的 `template/` 同樣只放會複製進專案的檔案,說明與 prompt 模板放在它旁邊。

| 資料夾 | 定位 | 封存時間 |
|------|------|------|
| [`archive/v1/`](./archive/v1/) | Skill-driven 的通用 Python 專案 setup — maintaining skills、slash commands、hooks、rules、CI workflow,以文件體系(SPEC / architecture / decisions)維持規範一致性 | 2026-11-09 |
| [`archive/v0/`](./archive/v0/) | Rule-driven 的最初版 — 透過 CLAUDE.md + rules 被動讀取規範,無 skill / command / hook / CI 自動化層 | 2026-11-09 |

封存的原因:v0 → v1 → v2 每一代都是設計哲學的轉向而非增補,v2(現 `template/`)以 hook 強制取代 v1 的文件體系後,v1 就停止演進;三代平行並列會讓根目錄索引與共用 hook 的修正不斷漂移,因此改為單一現行版 + 封存區。

---

## Repo Structure

```
claude-code-setup/
├── README.md                ← 本檔案(含 template 的 Prerequisites 與 Setup)
├── template/                ← 現行 template,整個資料夾複製到目標專案
│   ├── CLAUDE.md
│   └── .claude/
├── global/                  ← Global 配置 snapshot
│   ├── README.md
│   └── CLAUDE.md
└── archive/                 ← 封存版本
    ├── v0/
    │   ├── README.md
    │   ├── PROMPT.md
    │   └── template/
    └── v1/
        ├── README.md
        ├── PROMPT.md
        ├── NOTE.md
        └── template/
```
