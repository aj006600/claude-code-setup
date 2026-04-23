#!/usr/bin/env bash
# Advisory hook: warn when `git commit` command lacks `Authored-By` trailer.
#
# Behavior: exit 0 always (advisory only, does NOT block). If stabilized and
# user wants enforcement, change `exit 0` at the bottom to `exit 1` in the
# warning branch.
#
# Triggered by: PreToolUse hook on Bash tool (see .claude/settings.json)

input=$(cat)

# Extract the command from tool_input JSON using Python (project dependency).
command=$(echo "$input" | python3 -c 'import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get("tool_input", {}).get("command", ""))
except Exception:
    pass
' 2>/dev/null)

# Nothing to check.
[ -z "$command" ] && exit 0

# Match `git commit` (word-boundary to avoid false positives like `git commits`).
if echo "$command" | grep -qE '(^|[^a-zA-Z])git commit([^a-zA-Z]|$)'; then
    if ! echo "$command" | grep -q 'Authored-By'; then
        echo "[advisory] git commit without Authored-By trailer detected. See .claude/rules/git-rules.md Commit Convention." >&2
    fi
fi

exit 0
