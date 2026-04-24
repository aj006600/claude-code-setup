# Code Style (Python)

本專案 Python 代碼風格規範。採「Required Standards（必遵）」+「Recommended Tools（推薦配置）」分層設計：團隊可客製 Tools，但 Standards 保持一致。

---

## Required Standards（必遵守）

### 1. Docstring 規範

使用 **Google Style**，包含 Args、Returns、Raises、Example。
- 內容以繁體中文為主
- 技術術語（API、endpoint、parameter 等）使用英文
- Public function / method / class 必須有 docstring
- Private（`_` prefix）可選

**Function**：

```python
def fetch_user(user_id: int, include_profile: bool = False) -> User | None:
    """
    取得指定 ID 的 user 資料。

    Args:
        user_id: user 唯一識別碼
        include_profile: 是否一併查詢 profile，預設 False

    Returns:
        User 物件；若 user 不存在則回傳 None

    Raises:
        DatabaseError: DB 連線失敗時

    Example:
        >>> user = fetch_user(123, include_profile=True)
        >>> print(user.name)
    """
```

**Class**：

```python
class OrderService:
    """
    訂單相關的業務邏輯。

    負責訂單建立、狀態管理、結帳等流程。

    Attributes:
        db: 資料庫 session
        cache: Redis cache client
    """
```

**Module**（複雜模組頂端）：

```python
"""
User 模組：處理 user 資料的 CRUD 與 business logic。

主要 exports：
    - get_user: 取得單筆 user
    - create_user: 建立新 user
    - UserRole: user 角色 enum
"""
```

### 2. Naming Conventions

| 類型 | 命名 | 範例 |
|------|------|------|
| Classes | `PascalCase` | `UserService`, `OrderStatus` |
| Functions / methods | `snake_case` | `get_user()`, `calculate_total()` |
| Variables | `snake_case` | `user_id`, `total_amount` |
| Module constants | `UPPER_SNAKE_CASE` | `MAX_RETRIES`, `DEFAULT_TIMEOUT` |
| Private | `_` prefix | `_internal_helper()`, `_cache` |
| Module-private | `__` prefix | `__private_state`（name mangling） |
| Type variables | `PascalCase` with `T` | `T`, `TUser` |

### 3. Type Hints

- **所有 public function / method 必須有 type hints**（參數 + 回傳值）
- 使用 **PEP 585**（built-in generics）：`list[str]`，非 `List[str]`
- 使用 **PEP 604**（union）：`str | None`，非 `Optional[str]`
- Private function（`_` prefix）建議加但可選
- Legacy 代碼漸進補 hint，新代碼必須完整

**正確**：

```python
def parse_items(data: dict[str, list[int]]) -> list[Item] | None:
    ...
```

**避免**（過時寫法）：

```python
from typing import Dict, List, Optional  # PEP 585 後不再需要

def parse_items(data: Dict[str, List[int]]) -> Optional[List[Item]]:
    ...
```

### 4. Import 組織

遵循 **PEP 8 分組**，每組內 alphabetical：

1. Standard library
2. Third-party packages
3. Local / first-party（本專案）

```python
# 1. stdlib
import json
import os
from pathlib import Path

# 2. 3rd party
import httpx
import pytest
from pydantic import BaseModel

# 3. local
from src.models import User
from src.services.cache import get_cached
```

### 5. 其他慣例

| 慣例 | 說明 |
|------|------|
| String quotes | 雙引號 `"..."`（單引號僅用於字串中含雙引號時） |
| F-string | 優先於 `.format()` 與 `%` 格式化 |
| Path 操作 | `pathlib.Path`，不用 `os.path` |
| Trailing commas | 多行 list / dict / function args 必須 |
| Line length | 最多 88 字元（ruff / black 預設） |
| Async-first | 新 I/O 代碼優先 async；避免 sync-in-async 混用 |

---

## Recommended Tools（推薦配置）

下方工具為業界主流（2026），強力推薦採納；團隊若已有偏好工具可替換，但 Required Standards 仍需一致。

### Formatter：`ruff format`

Rust 實作，比 black 快 100x。已成 2026 年 Python formatter 事實標準。

```bash
# 格式化整個專案
uv run ruff format .

# 檢查但不修改（CI 用）
uv run ruff format . --check
```

替代：`black`（原本的標準，現已被 ruff 取代但仍廣泛使用）。

### Linter：`ruff check`

吃掉 flake8 / pylint / isort / pyflakes / pyupgrade 大部分功能。

```bash
# 檢查
uv run ruff check .

# 自動修復可修復的問題
uv run ruff check . --fix
```

**推薦啟用的規則集**：

| 規則集 | 作用 |
|--------|------|
| `E`, `W` | pycodestyle — PEP 8 錯誤與警告 |
| `F` | pyflakes — 邏輯錯誤偵測 |
| `I` | isort — import 排序 |
| `N` | pep8-naming — 命名規範 |
| `UP` | pyupgrade — 自動升級到新語法（例如 `List[T]` → `list[T]`） |
| `B` | flake8-bugbear — 常見 bug pattern |
| `SIM` | flake8-simplify — 代碼簡化建議 |
| `RUF` | ruff 專屬規則 |

### Type Checker：`mypy` 或 `pyright`

| 工具 | 特色 |
|------|------|
| `mypy` | Python 官方支持，規則成熟，生態最廣 |
| `pyright` | Microsoft 出品，快，VS Code / Pylance 內建 |

兩者都推薦 **strict mode**。新代碼應通過 strict；legacy 代碼可漸進補 hint（逐檔啟用 strict）。

```bash
# mypy
uv run mypy src/

# pyright
uv run pyright src/
```

---

## `pyproject.toml` 推薦配置

```toml
[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = [
    "E", "W",   # pycodestyle
    "F",        # pyflakes
    "I",        # isort
    "N",        # pep8-naming
    "UP",       # pyupgrade
    "B",        # bugbear
    "SIM",      # simplify
    "RUF",      # ruff-specific
]
ignore = [
    "E501",  # line too long（formatter 已處理）
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_ignores = true
warn_redundant_casts = true

[[tool.mypy.overrides]]
# Legacy 模組漸進補 hint
module = "src.legacy.*"
strict = false
```

---

## CI 建議

pre-merge 檢查至少包含：

```bash
uv run ruff format . --check                 # 格式
uv run ruff check .                          # lint
uv run mypy src/                             # type check
uv run pytest --cov=src --cov-fail-under=70  # 測試 + coverage
```

執行 `/pre-pr-check` command 可在本地自動跑這些檢查。
