# Code Style (Python)

本專案 Python 代碼風格規範。採「Required Standards(必遵)」+「Tools(本專案約定)」分層設計:Standards 跨工具不變;具體工具配置由 `.claude/references/pyproject-tooling.example.toml` 統一管理。

---

## Required Standards(必遵守)

### 1. Docstring 規範

使用 **Google Style**,包含 Args、Returns、Raises、Example。
- 內容以繁體中文為主
- 技術術語(API、endpoint、parameter 等)使用英文
- Public function / method / class 必須有 docstring
- Private(`_` prefix)可選

**Function**:

```python
def fetch_user(user_id: int, include_profile: bool = False) -> User | None:
    """
    取得指定 ID 的 user 資料。

    Args:
        user_id: user 唯一識別碼
        include_profile: 是否一併查詢 profile,預設 False

    Returns:
        User 物件;若 user 不存在則回傳 None

    Raises:
        DatabaseError: DB 連線失敗時

    Example:
        >>> user = fetch_user(123, include_profile=True)
        >>> print(user.name)
    """
```

**Class**:

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

**Module**(複雜模組頂端):

```python
"""
User 模組:處理 user 資料的 CRUD 與 business logic。

主要 exports:
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
| Module-private | `__` prefix | `__private_state`(name mangling) |
| Type variables | 短英文或加 `T` 後綴 | `T`, `K`, `V`, `UserT` |

### 3. Type Hints

- **所有 public function / method 必須有 type hints**(參數 + 回傳值)
- 使用 **PEP 585**(built-in generics):`list[str]`,非 `List[str]`
- 使用 **PEP 604**(union):`str | None`,非 `Optional[str]`
- Private function(`_` prefix)建議加但可選
- Legacy 代碼漸進補 hint,新代碼必須完整

**正確**:

```python
def parse_items(data: dict[str, list[int]]) -> list[Item] | None:
    ...
```

**避免**(過時寫法):

```python
from typing import Dict, List, Optional  # PEP 585 後不再需要

def parse_items(data: Dict[str, List[int]]) -> Optional[List[Item]]:
    ...
```

### 4. Import 組織

遵循 **PEP 8 分組**,每組內 alphabetical:

1. Standard library
2. Third-party packages
3. Local / first-party(本專案)

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
| String quotes | 雙引號 `"..."`(單引號僅用於字串中含雙引號時) |
| F-string | 優先於 `.format()` 與 `%` 格式化 |
| Path 操作 | `pathlib.Path`,不用 `os.path` |
| Trailing commas | 多行 list / dict / function args 必須 |
| Line length | 最多 88 字元(ruff 預設) |
| Sync / Async 一致性 | 若專案採 async,新 I/O 代碼一律 async;避免 sync-in-async 混用 |

---

## Tools(本專案約定)

| 用途 | 工具 |
|------|------|
| Formatter / Linter | `ruff` |
| Type Checker | `mypy`(strict mode) |

新代碼必須通過 strict 檢查;legacy 代碼可漸進補 hint(逐檔在 `pyproject.toml` 用 `[[tool.mypy.overrides]]` 局部關閉 strict)。

具體配置(規則集、line-length、target-version、mypy strict 細項)集中於 `.claude/references/pyproject-tooling.example.toml`,於 `uv init` 後 merge 進你的 `pyproject.toml`(見 `README.md ## Quick Start`)。

ruff / mypy 的 pre-merge 檢查由 CI(`.github/workflows/ci.yml`)權威執行;`/pre-pr-check` 不重跑這些工具,只處理 CI 做不到的 workflow-aware 項目(code-simplifier agent、PR body external-ref scan、SPEC / README hints)。
