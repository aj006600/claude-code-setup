#!/usr/bin/env bash
# Guard hook：擋下任何會寫入遠端 main 的 git push。
#
# 為什麼用 hook:trunk-based 流程(見 CLAUDE.md)需要「不直接 push main」有強制力——
# 尤其在用不了 branch protection 的 repo(如 GitHub Free 私有 repo)。這個 hook 是
# Claude session 端的強制層;人工在 Claude Code 之外的 push 不在管轄範圍。
#
# 注意:這是 Claude Code 的 PreToolUse hook(註冊於 .claude/settings.json),
# 在 Claude 執行 Bash tool 前觸發,不是 git pre-push hook。
#
# 行為:exit 1 = 擋下,exit 0 = 放行。指令解析失敗時 fail open(exit 0),
# 與其他 hooks 的 graceful degradation 一致。
# 臨時停用:從 .claude/settings.json 移除本 hook 的註冊。

command -v python3 >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

input=$(cat)

command=$(echo "$input" | python3 -c 'import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get("tool_input", {}).get("command", ""))
except Exception:
    pass
' 2>/dev/null)

[ -z "$command" ] && exit 0

# 快速路徑:指令文字裡沒有 git push 就直接放行
echo "$command" | grep -qE '(^|[^a-zA-Z])git +push([^a-zA-Z]|$)' || exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

verdict=$(INPUT_TEXT="$command" CURRENT_BRANCH="$current_branch" python3 <<'PYEOF'
import os
import shlex

text = os.environ.get("INPUT_TEXT", "")
current_branch = os.environ.get("CURRENT_BRANCH", "")

try:
    tokens = shlex.split(text)
except ValueError:
    # 解析不了(heredoc、引號不平衡等)—— fail open
    print("allow")
    raise SystemExit

SEPARATORS = {"&&", "||", ";", "|"}
# 會吃掉下一個參數的選項——該參數不是 refspec
OPTS_WITH_VALUE = {"-o", "--push-option", "--receive-pack", "--exec", "--repo"}


def check_push(args):
    """args = `git push` 之後、到下一個 shell 分隔符為止的 tokens。"""
    refspecs = []
    tags_only = False
    skip_next = False
    for tok in args:
        if skip_next:
            skip_next = False
            continue
        if tok in SEPARATORS:
            break
        if tok in ("--tags", "--follow-tags"):
            tags_only = True
            continue
        if tok in OPTS_WITH_VALUE:
            skip_next = True
            continue
        if tok.startswith("-"):
            continue
        refspecs.append(tok)

    # 第一個位置參數是 remote,其餘才是 refspec
    refspecs = refspecs[1:] if refspecs else []

    if not refspecs:
        # 無 refspec 的 push 目標是當前分支;--tags 除外(只推 tag、不推分支)。
        # tag push 必須放行:prod 發版流程靠 push v* tag 觸發,誤擋會弄壞發版。
        if tags_only:
            return False
        return current_branch == "main"

    for spec in refspecs:
        dst = spec.split(":", 1)[1] if ":" in spec else spec
        if dst == "main":
            return True
    return False


blocked = False
i = 0
while i < len(tokens) - 1:
    if tokens[i] == "git" and tokens[i + 1] == "push":
        if check_push(tokens[i + 2:]):
            blocked = True
            break
        i += 2
    else:
        i += 1

print("block" if blocked else "allow")
PYEOF
)

if [ "$verdict" = "block" ]; then
    echo "[block-push-main] BLOCKED — 這個 push 會寫入遠端 main。" >&2
    echo "[block-push-main] 本 repo 是 trunk-based:所有變更走 feature branch -> PR -> squash merge(見 CLAUDE.md)。" >&2
    echo "[block-push-main] 此 hook 是「不直接 push main」的強制層(見 CLAUDE.md Development workflow)。" >&2
    echo "[block-push-main] 請改推 feature branch,例如:git push -u origin feat/xxx" >&2
    exit 1
fi

exit 0
