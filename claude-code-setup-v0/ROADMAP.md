# Roadmap

V0 已識別的改進方向。

## 主動觸發取代被動讀取

目前 rule 仰賴 CLAUDE.md 提示讓 Claude 去 Read 規範,觸發精度受限於對話語意。將「有步驟的流程」(文檔維護、TDD 編排)改為 skill,利用 description 語意匹配主動載入。

## Workflow 結構化

目前流程以 prose 敘述「Step 1 → Step N」,Claude 臨場易漏步驟。改為結構化 workflow,內建多步驟 + 分支判斷(如文檔維護依情境走不同 workflow)。

## 跨規範協作鏈

目前 `claude-update-rules.md` / `spec-update-rules.md` / `readme-update-rules.md` 三檔各自獨立,無互相觸發機制。在文檔維護規範的關鍵節點互相 hook,形成自動同步鏈(如 SPEC 更新 → 評估 CLAUDE.md 是否需同步 → 評估 README 是否需更新)。

## 領域知識隨規範載入

目前 Semantic Versioning、Keep a Changelog、TDD 紀律等領域知識散布在各 rule 中,需 Claude 主動 Read 才能取得。將領域知識嵌入對應的規範載體中,觸發時自動進入 context,減少遺漏。

## 文檔更新時機智慧化

目前 `readme-update-rules.md` 只有單一「PR Review 通過後 merge 前」觸發點。改為依實作狀態(實作中 / 完成未 PR / PR 中 / 已 merge)動態決定文檔更新執行時機,避免 TDD 中途干擾也避免文檔遺忘補上。

## 自動化層

目前無 slash command、無 PreToolUse hook、無 CI workflow,規範執行完全靠 Claude 自律。改進:

- 補上開發前 / PR 前檢查的 slash commands
- 補上安全防護 hooks(如 secrets scan、cross-repo reference guard)
- 補上 CI workflow(ruff / mypy / pytest / coverage)

## 工具配置參考

目前無統一的工具配置範例。提供 `pyproject.toml` 的 `[tool.*]` 配置範例(ruff / mypy / pytest / coverage),讓新專案快速對齊工具設定。
