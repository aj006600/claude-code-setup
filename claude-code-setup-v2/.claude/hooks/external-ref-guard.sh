#!/usr/bin/env bash
# Guard hook:當 `git commit`、`gh pr create/edit/comment`、`gh issue create/edit/comment`
# 的指令文字含有指向「其他 GitHub repo」的引用時擋下。這類引用會在對方 issue 觸發
# 不可逆的跨 repo "mentioned in ..." backlink——對方 watcher 先收到通知,事後編輯
# 也收不回來,所以這是硬性關卡,不是建議。
#
# 注意:這是 Claude Code 的 PreToolUse hook(註冊於 .claude/settings.json),
# 在 Claude 執行 Bash tool 前觸發,不是 git pre-commit hook。
#
# 偵測:
# - `owner/repo#N` 縮寫(inline code span 內的除外)
# - `https://github.com/owner/repo/(issues|pull)/N` 完整 URL
# backtick 內的引用跳過:GitHub 對 code span 不做 reference parsing。
#
# 限制:看不到 `--body-file <path>` 的檔案內容(只掃指令文字)。
#
# 行為:發現外部引用 exit 1(擋下),否則 exit 0。
# 臨時停用:從 .claude/settings.json 移除本 hook 的註冊。
#
# Graceful degradation:python3 或 git 不存在時靜默放行。

command -v python3 >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

input=$(cat)

# 前置快速放行:先用 shell 內建瞄一眼原始 JSON,與本 hook 無關的指令不必啟動 python3
# (python3 啟動約 120ms,而絕大多數 Bash 呼叫都不是 commit / PR / issue 寫入)。
# 條件是下方精確判斷的超集合,不改變放行/擋下的結果。
# 限制:比對的是尚未解碼的 JSON,指令若寫成 JSON unicode 轉義形式會在此漏放
# (Claude Code 不會產生這種轉義;本 hook 防的是 agent 誤操作,非對抗攻擊者)。
case "$input" in
    *commit*|*"gh pr "*|*"gh issue "*) ;;
    *) exit 0 ;;
esac

command=$(echo "$input" | python3 -c 'import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get("tool_input", {}).get("command", ""))
except Exception:
    pass
' 2>/dev/null)

[ -z "$command" ] && exit 0

# 只在 commit / PR / issue 的寫入操作時觸發(word-boundary)
if ! echo "$command" | grep -qE '(^|[^a-zA-Z])(git commit|gh (pr|issue) (create|edit|comment))([^a-zA-Z]|$)'; then
    exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

origin_url=$(git remote get-url origin 2>/dev/null)
current_owner_repo=$(echo "$origin_url" | python3 -c 'import re, sys
u = sys.stdin.read().strip()
m = re.match(r"(?:https?://github\.com/|git@github\.com:)([^/]+)/([^/]+?)(?:\.git)?/?$", u)
print(f"{m.group(1)}/{m.group(2)}" if m else "")
' 2>/dev/null)

# 沒有 GitHub origin 就無從比對
[ -z "$current_owner_repo" ] && exit 0

findings=$(CURRENT_REPO="$current_owner_repo" INPUT_TEXT="$command" python3 <<'PYEOF'
import os, re

text = os.environ.get("INPUT_TEXT", "")
current = os.environ.get("CURRENT_REPO", "").lower()
BACKTICK = chr(96)  # $(...) 內不能出現字面 backtick,用 chr(96) 迂迴


def in_code_span(s, pos):
    """pos 是否位於該行的 backtick code span 內。"""
    line_start = s.rfind("\n", 0, pos) + 1
    return s[line_start:pos].count(BACKTICK) % 2 == 1


findings = set()

# owner/repo#N 縮寫。用 lookbehind/lookahead 排除路徑類誤判
# (前面不可為英數/./_/-/斜線,後面不可為英數)。
short_re = re.compile(
    r"(?<![A-Za-z0-9_./-])([A-Za-z0-9][A-Za-z0-9_.-]*)/([A-Za-z0-9][A-Za-z0-9_.-]*)#(\d+)(?![A-Za-z0-9])"
)
for m in short_re.finditer(text):
    owner, repo, num = m.group(1), m.group(2), m.group(3)
    if f"{owner}/{repo}".lower() == current:
        continue
    if in_code_span(text, m.start()):
        continue
    findings.add(f"{owner}/{repo}#{num}")

# GitHub issue/PR 完整 URL
url_re = re.compile(
    r"https?://github\.com/([A-Za-z0-9][A-Za-z0-9_.-]*)/([A-Za-z0-9][A-Za-z0-9_.-]*)/(issues|pull)/(\d+)"
)
for m in url_re.finditer(text):
    owner, repo, kind, num = m.group(1), m.group(2), m.group(3), m.group(4)
    if f"{owner}/{repo}".lower() == current:
        continue
    if in_code_span(text, m.start()):
        continue
    findings.add(f"github.com/{owner}/{repo}/{kind}/{num}")

print("\n".join(sorted(findings)))
PYEOF
)

if [ -n "$findings" ]; then
    echo "[external-ref-guard] BLOCKED — 偵測到指向外部 GitHub repo 的引用。這會建立不可逆的跨 repo 'mentioned in' backlink,並把內容推播給對方 issue 的 watchers:" >&2
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        echo "  - $f" >&2
    done <<< "$findings"
    echo "[external-ref-guard] 本 repo:$current_owner_repo" >&2
    echo "[external-ref-guard] 安全寫法:用 backtick 包住(\`owner/repo#N\`)或改寫(例:「上游 issue 在 owner/repo,編號 N」)。" >&2
    echo "[external-ref-guard] 臨時停用:從 .claude/settings.json 的 PreToolUse 移除本 hook。" >&2
    exit 1
fi

exit 0
