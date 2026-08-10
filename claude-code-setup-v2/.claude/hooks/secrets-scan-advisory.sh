#!/usr/bin/env bash
# Advisory hook:`git commit` / `git add` 時,掃描 staged 檔案與內容是否有
# 疑似密鑰(可疑檔名、已知 token pattern),有就警告。
#
# 豁免清單依 repo 慣例調整:下方預設豁免 env/.env.{dev,qas,prod}——
# 這是 fullstack-docker-template-multienv 的慣例(非機密環境設定刻意進版控,
# 真密鑰放 env/*.local 或 secrets manager)。你的 repo 慣例不同就改掉。
#
# 注意:這是 Claude Code 的 PreToolUse hook(註冊於 .claude/settings.json),
# 在 Claude 執行 Bash tool 前觸發,不是 git pre-commit hook。
#
# 行為:永遠 exit 0(僅警告、不擋)。要改為強制,把警告分支最後的 exit 0 改成 exit 1。
#
# Graceful degradation:python3 或 git 不存在時靜默放行。

command -v python3 >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

input=$(cat)

# 前置快速放行:先用 shell 內建瞄一眼原始 JSON,與本 hook 無關的指令不必啟動 python3
# (python3 啟動約 120ms,而絕大多數 Bash 呼叫都不是 git commit / git add)。
# 條件是下方精確判斷的超集合,不改變警告與否的結果。
# 限制:比對的是尚未解碼的 JSON,指令若寫成 JSON unicode 轉義形式會在此漏掃
# (Claude Code 不會產生這種轉義;本 hook 防的是 agent 誤操作,非對抗攻擊者)。
case "$input" in
    *commit*|*add*) ;;
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

# 只在 git commit / git add 時觸發(word-boundary 避免誤判)
if ! echo "$command" | grep -qE '(^|[^a-zA-Z])git (commit|add)([^a-zA-Z]|$)'; then
    exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

# 收集 staged 檔案。純 `git add` 執行前還沒東西 staged → 掃不到就掃不到(advisory,不擋)
staged=$(git diff --cached --name-only 2>/dev/null)
[ -z "$staged" ] && exit 0

warnings=()

# 檢查 1:可疑檔名(env 檔、私鑰、憑證)。
# .example / .template / .sample 後綴放行(慣例上就是要進版控的範本)。
while IFS= read -r file; do
    [ -z "$file" ] && continue
    # 本 repo 慣例:非機密環境設定,刻意進版控
    case "$file" in
        env/.env.dev|env/.env.qas|env/.env.prod)
            continue
            ;;
    esac
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

# 檢查 2:staged diff 內的已知 token pattern。
# 選低誤判率的 pattern(不透明 token 格式,不是泛用字眼)。
diff=$(git diff --cached 2>/dev/null)
if [ -n "$diff" ]; then
    patterns=(
        'AKIA[0-9A-Z]{16}'                                  # AWS Access Key ID
        'ASIA[0-9A-Z]{16}'                                  # AWS 臨時 session key
        'ghp_[A-Za-z0-9]{36,}'                              # GitHub personal access token
        'gho_[A-Za-z0-9]{36,}'                              # GitHub OAuth token
        'github_pat_[A-Za-z0-9_]{82,}'                      # GitHub fine-grained PAT
        'sk-[A-Za-z0-9]{48,}'                               # OpenAI API key
        'xox[baprs]-[A-Za-z0-9-]{10,}'                      # Slack token
        '-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----'             # PEM 私鑰標頭(RSA/EC/DSA/OPENSSH/ENCRYPTED/PKCS#8 全型式)
    )
    for p in "${patterns[@]}"; do
        # -e 防止以 - 開頭的 pattern(如私鑰標頭)被 grep 當成選項
        if echo "$diff" | grep -qE -e "$p"; then
            warnings+=("potential secret pattern matched: /$p/")
        fi
    done
fi

if [ ${#warnings[@]} -gt 0 ]; then
    echo "[secrets-scan-advisory] commit 前請檢查 staged 內容:" >&2
    for w in "${warnings[@]}"; do
        echo "  - $w" >&2
    done
    echo "[secrets-scan-advisory] 僅警告、不擋。若為真密鑰:unstage 並加入 .gitignore。" >&2
fi

exit 0
