# teams-agent

React(Vite)前端 + FastAPI 後端,用 docker compose 兜起來。dev / qas / prod 三個環境跑**同一顆 image**,差別只在載入哪份 `env/.env.<env>`。

瀏覽器只打 frontend;`/api/*` 由 frontend 的 nginx 反向代理到 backend(同源、免 CORS),backend 不對外開埠。

## Commands

| 指令 | 用途 |
|---|---|
| `make dev` | 本機開發,前端 3000 / 後端 8000,後端熱重載 |
| `make test` | 跑後端測試(在 dev stage 容器裡) |
| `make lint` / `make format` | ruff 檢查 / 格式化 |
| `make dev-down` | 停止並清理開發容器 |

`make up-*`(本機預覽各環境設定與 topology)和 `make deploy`(在目標主機拉 CI 測過的 image)見 `README.md`。

Dockerfile 是多階段的:`dev` stage 含測試工具、只在本機用;最後的 `runtime` stage 才是出貨用、三個環境共用的那一顆。

## Development workflow

Trunk-based:`main` 是唯一長期分支,**不直接 commit 到 `main`**(跑 `/implement` 時也一樣)。所有改動走短命 feature branch → PR → squash merge,分支命名 `feat/xxx`、`fix/xxx`。

一段工作完成後可自行 push feature branch(不觸發任何 CI),但**開 PR 前要先問過我**——PR 是 CI 測試的觸發點。merge 進 `main` 才部署 dev/qas,打 `v*` tag 才上 prod。完整流程見 `docs/cicd.md`。

## Agent skills

### Issue tracker

Issues are tracked in this repo's GitHub Issues (`ytc-wistron/teams-agent`), operated via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage labels are used as-is: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout — one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
