# claude-code-setup-v2

精簡版的 Claude Code 協作套件:一份 CLAUDE.md 骨架 + 三個 guard hooks + 共享 settings。
在 teams-agent 專案中迭代驗證後回流成模板。

## Philosophy

v1 是一套完整的文件 SSOT 系統(SPEC / architecture / decisions + maintaining-* skills);
v2 走相反的路——**能用工具強制的不寫成文件,能一行講完的不寫成一章**:

- **工具優先漏斗**:教訓的歸位順序是 工具/CI → 該檔註釋 → `docs/` → `docs/adr/` → 最後才進 CLAUDE.md。style 交給 linter(如 ruff 的 `E/F/I/UP/N/B/PT`),CLAUDE.md 只留工具做不到的慣例。第一站(linter / CI)是一般專案基礎建設,由專案本身或技術棧模板提供;本套件負責的是最後一站,以及 Claude Code 專屬的 hook 護欄。
- **註釋 why not what**:只寫 code 讀不出來的約束、陷阱、非顯然理由。
- **確定性強制**:紀律性規則(不推 main、防跨 repo 引用外洩)用 PreToolUse hooks 擋在執行前,不靠自律。強制力有邊界:hook 需要 python3,指令解析不了時一律放行(fail open),寧可漏擋也不卡住工作;「不在 `main` 上 commit」則工具表達不了(新 repo 的首個 commit、`git revert`、解衝突都合法站在 main 上),留給自律,由 push 那關兜底。
- **第二次法則**:同類教訓第二次出現才提議入規,防 CLAUDE.md 肥大。

## What's inside

```
CLAUDE.md                          # 骨架:workflow + 9 條通用 conventions,<...> 佔位符待填
.claude/settings.json              # hooks 註冊 + permissions 白名單(對應 CLAUDE.md Commands 表,make 為範例)
.claude/hooks/
├── block-push-main.sh             # 硬擋任何寫入遠端 main 的 push(放行 feature branch 與 tag)
├── external-ref-guard.sh          # 硬擋 commit/PR/issue 中的跨 repo 引用(防不可逆 backlink 通知)
└── secrets-scan-advisory.sh       # git add/commit 前掃疑似密鑰(僅警告;豁免清單依 repo 調整)
```

## Adoption

**前置**:專案要先有 lint 與 CI——那是漏斗第一站,本套件不含。缺了它們,下面那些慣例會退化成純文字叮嚀,而本套件的主張正是別靠叮嚀。技術棧模板通常已備齊,見 Pairs well with。

1. 複製 `CLAUDE.md` 與 `.claude/` 到專案根目錄(hooks 由 `bash <path>` 呼叫,不需要執行位元)
2. 填 `CLAUDE.md` 的 `<...>` 佔位符(Commands 表、Conventions 第 1 條的 `<檢查指令>`、部署節奏)
3. 依專案調整:`CLAUDE.md` 的 Conventions 為通用預設,依技術棧微調(標註「範例」處尤其,如測試品質那條是 pytest 寫法);`settings.json` 的 permissions 清單;secrets hook 的豁免清單
4. Hooks 於下個 session 生效(settings 在 session 啟動時載入)

### permissions 白名單

三條規則對應 CLAUDE.md Commands 表的測試與檢查,把 `make` 換成你的建置工具即可。尾端 ` *` 讓一條規則同時涵蓋 `make test` 與 `make test -k foo`(word boundary 允許 prefix 後接空格或字串結尾);沒有它就只有一字不差的 `make test` 免確認,一開始 debug 單一測試就會跳確認框。

Commands 表的「本機開發」刻意不入白名單:啟動長駐服務不該免確認。

### 改動 hooks 後的驗證

以模擬輸入驗證放行/擋下的結果,例如:

```bash
printf '{"tool_input":{"command":"git push origin main"}}' \
  | CLAUDE_PROJECT_DIR=$PWD bash .claude/hooks/block-push-main.sh; echo "exit=$?"   # 期望 1
```

三個 hook 開頭都有一段前置快速放行(`case "$input" in ...`),用 shell 內建瞄一眼原始 JSON,讓無關指令不必啟動 python3——三個 hook 各省約 120ms,對每一次 Bash 呼叫都有感。動到它時要確認新條件仍是下方精確判斷的**超集合**,否則會靜默漏放。

## Known gaps

- **PostToolUse 自動格式化**:Claude 改完檔案後自動對那一個檔案跑 formatter / linter,把 Conventions 第 1 條「Commit 前先跑 lint」從文字叮嚀換成機制,並讓錯誤在 Claude 還記得該檔脈絡時就浮現。按本套件的界線這屬於 Claude 專屬黏合層(linter 本身仍由專案提供),尚未實作。設計方向:用 `if: "Edit(*.py)"` 這類條件按副檔名分開註冊,採用者只留用得到的;檔案路徑取自 `tool_input.file_path`;格式化 exit 0 靜默收拾,檢查 exit 2 把錯誤餵回給 Claude。

累積到第三項再拆成獨立的 ROADMAP.md——一兩項用一節裝得下。

## Pairs well with

- **技術棧模板**:[fullstack-docker-template-multienv](https://github.com/aj006600/fullstack-docker-template-multienv)——先用它初始化專案,再疊上本套件
- **mattpocock skills**(plugin):裝好後跑 `/setup-matt-pocock-skills`,issue tracker / triage 標籤 / domain docs 的設定會生成到 `docs/agents/`(本套件刻意不預埋,因其內容綁定具體 repo)
