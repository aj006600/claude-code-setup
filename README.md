# oh-my-claude-setup

Claude Code 專案配置模板集合。每個版本獨立存放於平行資料夾，舊版保留不刪。

---

## Available Versions

| 版本 | 定位 | 狀態 |
|------|------|------|
| [`claude-code-setup-v1`](./claude-code-setup-v1/) | 通用 Python 專案 setup — 4 maintaining skills、TDD workflow、4 commands、1 advisory hook | ✅ Current |

未來版本會以 `claude-code-setup-v2`、`claude-code-setup-v3`... 平行資料夾存在。

---

## How to Adopt

1. 選擇想用的版本（目前推薦 [`claude-code-setup-v1`](./claude-code-setup-v1/README.md)）
2. 進入該資料夾閱讀其 README.md
3. 依 README 的 Quick Start 步驟執行

---

## Repo Structure

```
oh-my-claude-setup/
├── README.md                    ← 本檔案
├── claude-code-setup-v1/        ← 第一版 template
│   ├── README.md                ← Template 完整說明與 adoption 指南
│   └── .claude/                 ← 實際採用時複製此目錄
└── memo/                        ← 開發筆記（建議 .gitignore）
```

---

**Last Updated**: 2026-04-23
