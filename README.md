# oh-my-claude-setup

Claude Code 專案配置模板集合。每個版本獨立存放於平行資料夾，舊版保留不刪。

---

## Available Versions

| 版本 | 定位 | 狀態 |
|------|------|------|
| [`claude-code-setup-v1`](./claude-code-setup-v1/) | 通用 Python 專案 setup — 3 maintaining skills + 1 workflow orchestrator skill、4 slash commands、1 advisory hook + 1 guard hook、CI workflow | **Active** |
| [`claude-code-setup-v0`](./claude-code-setup-v0/) | 早期 rule-driven 設計 — 純 markdown 規範,無 skill / command / hook,作為設計演進對照保留 | **Frozen**(historical snapshot) |

未來版本會以 `claude-code-setup-v2`、`claude-code-setup-v3`... 平行資料夾存在。

---

## How to Adopt

1. 選擇想用的版本(新專案推薦 [`claude-code-setup-v1`](./claude-code-setup-v1/README.md);V0 僅供設計對照,不建議用於新專案)
2. 進入該資料夾閱讀其 README.md
3. 依 README 的 Quick Start 步驟執行

V0 → V1 的設計演進原因見 [`claude-code-setup-v1/README.md`](./claude-code-setup-v1/README.md) `## Design Rationale` 與 [`claude-code-setup-v0/ROADMAP.md`](./claude-code-setup-v0/ROADMAP.md)。

---

## Repo Structure

```
oh-my-claude-setup/
├── README.md                    ← 本檔案
├── claude-code-setup-v1/        ← 第一版 template(Active)
│   ├── README.md                ← Template 完整說明與 adoption 指南
│   ├── CHANGELOG.md             ← Template 自身演進史
│   ├── ROADMAP.md               ← V2 演進方向
│   ├── .claude/                 ← 實際採用時複製此目錄
│   └── .github/                 ← 實際採用時複製此目錄(CI workflow)
├── claude-code-setup-v0/        ← 第零版 template(Frozen)
│   ├── README.md                ← V0 簡介 + V0 vs V1 對照
│   ├── CHANGELOG.md             ← V0 baseline 紀錄
│   ├── ROADMAP.md               ← V0 → V1 演進回顧
│   └── .claude/                 ← 實際採用時複製此目錄
└── memo/                        ← 開發筆記(.gitignore)
```

---

**Last Updated**: 2026-05-04
