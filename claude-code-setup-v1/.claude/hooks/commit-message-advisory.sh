#!/usr/bin/env bash
# Advisory hook: warn when `git commit` command lacks `Authored-By` trailer.
#
# NOTE: This is a Claude Code PreToolUse hook (registered in .claude/settings.json).
# It runs before Claude invokes the Bash tool. This is NOT a git pre-commit hook
# (.git/hooks/pre-commit).
#
# Behavior: exit 0 always (advisory only, does NOT block). If you want to
# enforce, change the final `exit 0` to `exit 1` inside the warning branch.
#
# Graceful degradation: if python3 is unavailable (e.g., template adopters who
# switched to a non-Python stack), the hook silently no-ops.

# Skip silently if python3 is not installed.
command -v python3 >/dev/null 2>&1 || exit 0

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
