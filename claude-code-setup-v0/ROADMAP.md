# Roadmap

本檔記錄 V0 → V1 的設計演進方向作為決策史。V1 之後的演進方向見 [`claude-code-setup-v1/ROADMAP.md`](../claude-code-setup-v1/ROADMAP.md)。

## V0 → V1 已完成演進

從 rule-driven 過渡到 skill-driven 的 5 個核心動因(完整論述見 `claude-code-setup-v1/README.md` `## Design Rationale`):

- **主動觸發 vs 被動讀取**:rule 仰賴 CLAUDE.md 提示與當下對話語意去 Read,觸發精度低;V1 將「有步驟的流程」改為 skill,description 語意匹配時自動載入
- **Workflow 結構**:V0 用 prose 敘述「Step 1 → Step 5」流程,Claude 臨場易漏步驟;V1 skill 內建多步驟 workflow + 分支判斷(如 `maintaining-claude-md` Workflow A/B)
- **跨 skill 協作鏈**:`maintaining-spec-md` → `maintaining-claude-md` → `maintaining-readme-md` 在關鍵節點互相 hook,形成規範同步鏈;V0 的 rules 之間無此機制
- **領域知識隨 skill 載入**:Semantic Versioning、Keep a Changelog、TDD 紀律寫進 skill body,觸發時自動進入 context;V0 需 Claude 主動 Read 才知細節
- **智慧延後執行時機**:`maintaining-readme-md` 依實作狀態(實作中 / 完成未 PR / PR 中 / 已 merge)決定執行時機,避免 TDD 中途干擾也避免文檔遺忘補上;V0 只有單一「pre-merge」觸發點

## V0 設計遺產對照(V1 處置)

| V0 設計 | V1 處置 |
|---------|---------|
| `*-rules.md` 各檔獨立 footer 與版本號 | 移除——統一由 template CHANGELOG 追蹤;rule 為 reference 文件不需 per-rule versioning |
| `claude-update-rules.md` / `spec-update-rules.md` / `readme-update-rules.md` 三檔(How to update XXX) | 改為 `maintaining-claude-md` / `maintaining-spec-md` / `maintaining-readme-md` 三 skill,description 自動觸發 |
| `development-workflow-details.md`(TDD 4 階段 prose) | 改為 `tdd-feature-workflow` skill 編排,各階段委派 superpowers skills |
| `code-style.md` / `testing-rules.md` / `git-rules.md` / `documentation-style.md` | 保留為 rule 檔案(reference 性質)+ 內容大幅擴充 |
| 無自動化層 | 補上 `/pre-dev-check` / `/pre-pr-check` / `/project-status` / `/agent-cheatsheet` commands、`secrets-scan-advisory.sh` / `external-ref-guard.sh` hooks、`.github/workflows/ci.yml` |
| 無工具配置 | 補上 `.claude/references/pyproject-tooling.example.toml`(ruff / mypy / pytest / coverage `[tool.*]`) |
