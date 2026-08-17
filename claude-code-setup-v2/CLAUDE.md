## Commands

下列是本專案的 canonical 入口,測試與檢查一律走這裡(與 CI 同一套):

| 指令 | 用途 |
|---|---|
| `<本機開發,例:make dev / docker compose up / npm run dev>` | 起本機環境 |
| `<測試,例:make test / uv run pytest / npm test>` | 跑測試 |
| `<檢查,例:make lint / ruff check / npm run lint>` / `<格式化>` | lint / format |

<其餘指令:`make help`(或 `npm run`、`just --list`,依專案填)。>

## Development workflow

Trunk-based:`main` 是唯一長期分支,所有改動走短命 feature branch → PR → squash merge,分支命名 `feat/xxx`、`fix/xxx`。**開工前先切分支**——commit 落在 `main` 上不會被攔,但 push 會(`.claude/hooks/block-push-main.sh` 在 python3 可用時硬擋),屆時得把 commit 搬到分支才走得下去。

一段工作完成後可自行 push feature branch,但**開 PR 前要先問過我**——PR 是 CI 的觸發點。<merge 之後的部署節奏:依專案補一句,例如「merge 進 main 部署 dev/qas,打 v* tag 才上 prod」。>

## Conventions

- **Commit 前先跑 lint**(本專案:`<檢查指令>`)。CI 也會把關,本機先跑省一輪紅燈。
- **Commit message**:輕量 Conventional Commits,英文——`<type>: <description>`,type 取 `feat/fix/docs/test/refactor/chore`,scope 選用(`feat(api): ...` 也可)。
- **PR 標題與內文**:英文,**不用 emoji**(commit message 同樣不用)。標題即 Conventional Commit(squash 後成為 main 的 commit)。body 只有兩節:`## Summary`(為什麼+做了什麼,1-3 個 bullet)、`## Testing`(怎麼驗證的)——**十行內**,不重述 diff,審計報告與過程敘事留在對話與 commit message。
- **文件語言**:章節標題英文(`## Quick Start`)、內文繁體中文、技術術語保留英文(fixture、endpoint 不翻譯)。
- **文檔同步**:user-facing 變更(指令、架構、安裝步驟)在**同一個 PR** 內同步 README/docs——文檔更新是變更的一部分,不是事後待辦。
- **程式碼註釋**:繁體中文(術語英文),**不用 emoji**。只寫 code 讀不出來的**約束、陷阱、非顯然理由**(why not what),**一行為預設——多行只留給壓一行就不清楚的約束**;不敘述下一行做什麼;概念解說住 `docs/`,註釋需要時用一行連結指向,不重述。
- **規則提議**:同類糾正或卡關**第二次**發生(或一次但代價高:不可逆操作、部署事故級),主動提議把教訓寫進來——先展示擬新增的那一行與觸發原因,我同意才寫。歸位優先序:能用工具強制的進工具/CI → 綁定單檔的進該檔註釋 → 概念進 `docs/` → 決策進 `docs/adr/` → 都不是且每個 session 都適用,才進 CLAUDE.md。
- **測試品質**(pytest 範例,依測試框架調整):單元測試目錄鏡射原始碼模組結構;fixture 先用 conftest 既有的,重複自建即違規;測試名稱與 docstring 必須與實際行為一致;每個測試驗證一個真實行為——斷言偶然字串(使用者可見的契約訊息除外)、恆真斷言、與既有測試重複覆蓋的,一律刪除。
- **技術調研**:用到不熟悉或版本敏感的 API/框架時,**先查證再寫**——context7 查 library 文檔、WebSearch/WebFetch 查一手來源、`gh search` 找官方範例與成熟專案;大題目啟用 `/research`(背景 agent、只認一手來源、產出帶引用的 Markdown 進 repo)。外部資訊一律**驗證(實測或對照官方文檔)後才採用**。
