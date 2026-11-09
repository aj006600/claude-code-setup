#!/usr/bin/env bash
# Advisory hook: warn when `git commit` or `git add` stages suspicious files
# or content matching known secret patterns.
#
# NOTE: This is a Claude Code PreToolUse hook (registered in .claude/settings.json).
# It runs before Claude invokes the Bash tool. This is NOT a git pre-commit hook.
#
# Behavior: exit 0 always (advisory only, does NOT block). To enforce, change
# the final `exit 0` in the warning branch to `exit 1`.
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

# Trigger only on `git commit` or `git add` (word-boundary to avoid false positives).
if ! echo "$command" | grep -qE '(^|[^a-zA-Z])git (commit|add)([^a-zA-Z]|$)'; then
    exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

# Collect staged files. If nothing staged yet (e.g., pure `git add` before execution),
# the hook simply finds nothing to warn about — which is fine (advisory, non-blocking).
staged=$(git diff --cached --name-only 2>/dev/null)
[ -z "$staged" ] && exit 0

warnings=()

# Check 1: suspicious filenames (env files, private keys, credential dumps).
# Allow `.example` / `.template` / `.sample` suffixes (common for dotfiles meant to commit).
while IFS= read -r file; do
    [ -z "$file" ] && continue
    base=$(basename "$file")
    case "$base" in
        *.example|*.template|*.sample)
            continue
            ;;
    esac
    case "$base" in
        .env|.env.*)
            warnings+=("staged env file: $file")
            ;;
        *.pem|*.key|*.p12|*.pfx|id_rsa|id_ed25519|id_ecdsa|id_dsa)
            warnings+=("staged credential/key file: $file")
            ;;
        credentials.json|service-account*.json|*secrets.json|*secrets.yaml|*secrets.yml)
            warnings+=("staged secrets file: $file")
            ;;
    esac
done <<< "$staged"

# Check 2: known secret patterns in staged diff.
# Patterns chosen for LOW false-positive rate (opaque token formats, not generic words).
diff=$(git diff --cached 2>/dev/null)
if [ -n "$diff" ]; then
    patterns=(
        'AKIA[0-9A-Z]{16}'                                  # AWS Access Key ID
        'ASIA[0-9A-Z]{16}'                                  # AWS temp session key
        'ghp_[A-Za-z0-9]{36,}'                              # GitHub personal access token
        'gho_[A-Za-z0-9]{36,}'                              # GitHub OAuth token
        'github_pat_[A-Za-z0-9_]{82,}'                      # GitHub fine-grained PAT
        'sk-[A-Za-z0-9]{48,}'                               # OpenAI API key
        'xox[baprs]-[A-Za-z0-9-]{10,}'                      # Slack token
        '-----BEGIN (RSA|DSA|EC|OPENSSH|PRIVATE) KEY-----'  # Private key headers
    )
    for p in "${patterns[@]}"; do
        if echo "$diff" | grep -qE "$p"; then
            warnings+=("potential secret pattern matched: /$p/")
        fi
    done
fi

if [ ${#warnings[@]} -gt 0 ]; then
    echo "[secrets-scan-advisory] review staged content before committing:" >&2
    for w in "${warnings[@]}"; do
        echo "  - $w" >&2
    done
    echo "[secrets-scan-advisory] advisory only — not blocking. If these are real secrets, unstage them and add to .gitignore." >&2
fi

exit 0
