#!/usr/bin/env bash
# Guard hook: block `git commit`, `gh pr create/edit/comment`, or
# `gh issue create/edit/comment` when the command text contains references to
# GitHub repos OTHER than the current repo's origin. Such references trigger
# GitHub's cross-repo "mentioned in ..." backlink, which is irreversible —
# watchers of the target issue receive notifications before you can edit the
# content away. This guard is therefore a hard gate, not advisory.
#
# NOTE: This is a Claude Code PreToolUse hook (registered in .claude/settings.json).
# It runs before Claude invokes the Bash tool. This is NOT a git pre-commit hook.
#
# Detection:
# - `owner/repo#N` shortcut (outside inline code spans)
# - `https://github.com/owner/repo/(issues|pull)/N` full URLs
# References inside backticks (inline code) are skipped because GitHub
# suppresses reference parsing inside code spans.
#
# Limitations:
# - Cannot inspect `--body-file` contents (only the command text). The
#   /pre-pr-check command performs a deeper scan covering body files and
#   accumulated branch commits.
#
# Behavior: exit 1 when external references are found (blocks the tool call);
# exit 0 otherwise. To temporarily bypass, remove this entry from
# .claude/settings.json PreToolUse array.
#
# Graceful degradation: if python3 or git is unavailable, the hook silently no-ops.

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

# Trigger on commit / PR / issue write operations (word-boundary).
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

# No github origin → nothing to compare against.
[ -z "$current_owner_repo" ] && exit 0

findings=$(CURRENT_REPO="$current_owner_repo" INPUT_TEXT="$command" python3 <<'PYEOF'
import os, re

text = os.environ.get("INPUT_TEXT", "")
current = os.environ.get("CURRENT_REPO", "").lower()
BACKTICK = chr(96)  # avoid literal backtick inside $(...) command substitution


def in_code_span(s, pos):
    """True if pos is inside a backtick-delimited span on its line."""
    line_start = s.rfind("\n", 0, pos) + 1
    return s[line_start:pos].count(BACKTICK) % 2 == 1


findings = set()

# owner/repo#N shortcut. Guard against path-like false positives via negative
# lookbehind (no preceding alnum/./_/-/slash) and lookahead (no trailing alnum).
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

# Full GitHub issue/PR URL.
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
    echo "[external-ref-guard] BLOCKED — references to external GitHub repos detected. These would create irreversible cross-repo 'mentioned in' backlinks and leak your content to the target issue's watchers:" >&2
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        echo "  - $f" >&2
    done <<< "$findings"
    echo "[external-ref-guard] current repo: $current_owner_repo" >&2
    echo "[external-ref-guard] to proceed safely: wrap the ref in backticks (\`owner/repo#N\`) or rephrase (e.g., 'upstream issue in owner/repo, number N'). See .claude/rules/git-rules.md Cross-repo 引用安全格式." >&2
    echo "[external-ref-guard] to temporarily bypass: remove this hook from .claude/settings.json PreToolUse array." >&2
    exit 1
fi

exit 0
