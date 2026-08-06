# claude-code-setup-v2

精簡版的 Claude Code 協作套件:一份 CLAUDE.md 骨架 + 三個 guard hooks + 共享 settings。
在 teams-agent 專案中迭代驗證後回流成模板。

## Philosophy

v1 是一套完整的文件 SSOT 系統(SPEC / architecture / decisions + maintaining-* skills);
v2 走相反的路——**能用工具強制的不寫成文件,能一行講完的不寫成一章**:

- **工具優先漏斗**:教訓的歸位順序是 工具/CI → 該檔註釋 → `docs/` → `docs/adr/` → 最後才進 CLAUDE.md。style 交給 linter(如 ruff 的 `E/F/I/UP/N/B/PT`),CLAUDE.md 只留工具做不到的慣例。
- **註釋 why not what**:只寫 code 讀不出來的約束、陷阱、非顯然理由。
- **確定性強制**:紀律性規則(不推 main、防跨 repo 引用外洩)用 PreToolUse hooks 硬擋,不靠自律。
- **第二次法則**:同類教訓第二次出現才提議入規,防 CLAUDE.md 肥大。

## What's inside

```
CLAUDE.md                          # 骨架:workflow + 11 條通用 conventions,<...> 佔位符待填
.claude/settings.json              # hooks 註冊 + permissions 白名單(make 指令為範例,依專案調整)
.claude/hooks/
├── block-push-main.sh             # 硬擋任何寫入遠端 main 的 push(放行 feature branch 與 tag)
├── external-ref-guard.sh          # 硬擋 commit/PR/issue 中的跨 repo 引用(防不可逆 backlink 通知)
└── secrets-scan-advisory.sh       # git add/commit 前掃疑似密鑰(僅警告;豁免清單依 repo 調整)
```

## Adoption

1. 複製 `CLAUDE.md` 與 `.claude/` 到專案根目錄,`chmod +x .claude/hooks/*.sh`
2. 填 `CLAUDE.md` 的 `<...>` 佔位符,移除 TEMPLATE NOTICE 區塊
3. 依專案調整:`settings.json` 的 permissions 清單、secrets hook 的豁免清單
4. Hooks 於下個 session 生效(settings 在 session 啟動時載入)

改動 hooks 後請以模擬輸入驗證,例如:

```bash
printf '{"tool_input":{"command":"git push origin main"}}' \
  | CLAUDE_PROJECT_DIR=$PWD bash .claude/hooks/block-push-main.sh; echo "exit=$?"   # 期望 1
```

## Pairs well with

- **技術棧模板**:[fullstack-docker-template-multienv](https://github.com/aj006600/fullstack-docker-template-multienv)——先用它初始化專案,再疊上本套件
- **mattpocock skills**(plugin):裝好後跑 `/setup-matt-pocock-skills`,issue tracker / triage 標籤 / domain docs 的設定會生成到 `docs/agents/`(本套件刻意不預埋,因其內容綁定具體 repo)
