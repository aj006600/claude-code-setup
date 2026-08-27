#!/usr/bin/env bash
# Guard hook:擋下任何會寫入遠端 main 的 git push。
# Claude Code PreToolUse hook(註冊於 .claude/settings.json),不是 git pre-push hook。
#
# 為什麼是硬擋:trunk-based 的「不直接 push main」需要強制力,尤其在用不了 branch
# protection 的 repo(如 GitHub Free 私有 repo)。管轄範圍只到 Claude session 內,
# 人工在 Claude Code 之外的 push 擋不到。

# 缺依賴時 fail open:本 hook 防的是誤操作,不該讓環境問題卡死 session
command -v python3 >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

input=$(cat)

# 快速放行:條件是下方精確判斷的超集合,不改變結果,只為省下 python3 啟動成本
case "$input" in
    *push*) ;;
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

# 只在 git push 時觸發(word-boundary 避免誤判)
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
        # 這兩個選項會推所有分支,必然含 main
        if tok in ("--mirror", "--all"):
            return True
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
        dst = dst.lstrip("+").removeprefix("refs/heads/")
        # glob 目的端(refs/heads/*)可能涵蓋 main,一律視為命中
        if dst == "main" or "*" in dst:
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
    echo "[block-push-main] 本 repo 是 trunk-based,所有變更走 feature branch -> PR -> squash merge(見 CLAUDE.md Development workflow)。" >&2
    echo "[block-push-main] 尚未 commit:git switch -c feat/xxx,再 git push -u origin feat/xxx" >&2
    echo "[block-push-main] commit 已落在本地 main:git branch feat/xxx && git reset --keep origin/main(保留未提交的改動,會衝突時中止),再 git switch feat/xxx 推送。" >&2
    exit 1
fi

exit 0
