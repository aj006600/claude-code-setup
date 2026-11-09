# oh-my-claude-setup

Claude Code 配置集合:一份現行的專案 setup template、一份 global 配置 snapshot,以及歷代封存版本。

---

## Current

| 資料夾 | 內容 |
|------|------|
| [`template/`](./template/) | 專案層 setup template — 一份 CLAUDE.md 骨架 + 三個 guard hooks + 共享 settings。原則是「能用工具強制的不寫成文件」,搭配 mattpocock skills 與 trunk-based development |
| [`global/`](./global/) | Global 配置(`~/.claude/CLAUDE.md`)snapshot — 所有專案共用的基礎行為設定 |

`template/` 是唯一持續演進的 template,改動直接在原地進行,歷史由 git log 記錄,無版本號。

## How to Adopt

1. 進入 `template/` 閱讀 README.md
2. 依 README 的 Setup 步驟複製檔案到目標專案並填入佔位符

---

## Archive

歷代 template 保留於 `archive/`,維持當時的資料夾名稱與內容,供參考與整理;新專案一律從 `template/` 出發。

| 資料夾 | 定位 | 封存時間 |
|------|------|------|
| [`archive/v1/`](./archive/v1/) | Skill-driven 的通用 Python 專案 setup — maintaining skills、slash commands、hooks、rules、CI workflow,以文件體系(SPEC / architecture / decisions)維持規範一致性 | 2026-11-09,停在 v1.26.0 |
| [`archive/v0/`](./archive/v0/) | Rule-driven 的最初版 — 透過 CLAUDE.md + rules 被動讀取規範,無 skill / command / hook / CI 自動化層 | 2026-11-09,停在 v0.2.0 |

封存的原因:v0 → v1 → v2 每一代都是設計哲學的轉向而非增補,v2(現 `template/`)以 hook 強制取代 v1 的文件體系後,v1 就停止演進;三代平行並列會讓根目錄索引與共用 hook 的修正不斷漂移,因此改為單一現行版 + 封存區。

---

## Repo Structure

```
oh-my-claude-setup/
├── README.md                ← 本檔案
├── template/                ← 現行 template(複製到目標專案)
│   ├── README.md
│   ├── CLAUDE.md
│   └── .claude/
├── global/                  ← Global 配置 snapshot
│   ├── README.md
│   └── CLAUDE.md
└── archive/                 ← 封存版本
    ├── v0/
    └── v1/
```
