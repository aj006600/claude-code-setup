# Testing Rules (測試規範)

本專案的測試慣例與範例。所有新代碼都應遵循 TDD 並達成 coverage 目標（見 CLAUDE.md Testing Protocols）。

---

## 測試命名規範

| 模式 | 說明 |
|------|------|
| `test_<function>_<scenario>` | 標準命名 |
| `test_<function>_success` | 成功路徑 |
| `test_<function>_<error_type>` | 錯誤處理（例：`test_login_invalid_credentials`） |
| `test_<function>_edge_case` | 邊界條件 |

## 測試結構慣例

所有測試遵循 **Arrange-Act-Assert** 三段式：

```python
def test_something():
    # Arrange — 準備輸入與 mocks
    ...

    # Act — 執行受測函數
    ...

    # Assert — 驗證結果
    ...
```

---

## 單元測試範例

測試單一函數或類別，使用 mock 隔離外部依賴：

```python
# tests/unit/services/test_user_service.py
import pytest
from unittest.mock import AsyncMock, patch

from src.services.user import get_user
from src.exceptions import NotFoundError


@pytest.mark.asyncio
async def test_get_user_success():
    """測試成功取得 user"""
    mock_db = AsyncMock(return_value={"id": 1, "name": "test"})

    with patch("src.services.user.db.find_one", mock_db):
        result = await get_user(user_id=1)

        assert result["name"] == "test"
        mock_db.assert_called_once_with({"id": 1})


@pytest.mark.asyncio
async def test_get_user_not_found():
    """測試 user 不存在時拋出 NotFoundError"""
    mock_db = AsyncMock(return_value=None)

    with patch("src.services.user.db.find_one", mock_db):
        with pytest.raises(NotFoundError):
            await get_user(user_id=999)
```

---

## Parametrized Tests

多個類似情境用 `@pytest.mark.parametrize` 合併，避免重複測試代碼：

```python
# tests/unit/services/test_validator.py
import pytest

from src.services.validator import validate_email


@pytest.mark.parametrize("email,expected", [
    ("user@example.com", True),
    ("user.name+tag@example.co.uk", True),
    ("invalid", False),
    ("no@domain", False),
    ("", False),
    (None, False),
])
def test_validate_email(email, expected):
    """多輸入情境合併測試"""
    assert validate_email(email) is expected
```

---

## 整合測試範例

測試多個模組協作，可使用真實服務或 test container：

```python
# tests/integration/test_order_flow.py
import pytest

from src.services.order import order_service


@pytest.mark.asyncio
@pytest.mark.integration
async def test_create_order_flow(db_session, sample_user, sample_product):
    """測試完整訂單建立流程"""
    # Arrange — fixture 提供 db_session、sample_user、sample_product

    # Act
    order = await order_service.create(
        user_id=sample_user.id,
        product_id=sample_product.id,
    )

    # Assert
    assert order is not None
    assert order.status == "pending"
    assert order.user_id == sample_user.id
```

---

## Fixtures

### 同步 fixture

```python
# tests/conftest.py
import pytest


@pytest.fixture
def sample_user():
    return {"id": 1, "name": "test", "email": "test@example.com"}
```

### Async fixture with cleanup

使用 `yield` + teardown 防止 resource leak：

```python
# tests/conftest.py
import httpx
import pytest_asyncio


@pytest_asyncio.fixture
async def db_session():
    """Async DB session fixture — 測試後 rollback 並關閉連線"""
    session = await create_test_session()
    try:
        yield session
    finally:
        await session.rollback()
        await session.close()


@pytest_asyncio.fixture
async def http_client():
    """Async HTTP client — 測試後關閉連線池"""
    async with httpx.AsyncClient() as client:
        yield client
```

### Fixture scope

| Scope | 使用時機 |
|-------|---------|
| `function`（預設） | 每個測試獨立狀態 |
| `class` | 同 class 測試共享（少用） |
| `module` | 同檔案測試共享（用於昂貴的 setup） |
| `session` | 整個 test run 共享（極端情況） |

---

## External Service Mocking

### HTTP Client (httpx)

使用 `pytest-httpx` 或 `httpx.MockTransport`：

```python
# tests/unit/test_api_client.py
import pytest

from src.clients.api import fetch_data


@pytest.mark.asyncio
async def test_fetch_data_success(httpx_mock):  # fixture 來自 pytest-httpx
    """測試成功呼叫外部 API"""
    httpx_mock.add_response(
        url="https://api.example.com/data",
        json={"status": "ok", "items": [1, 2, 3]},
    )

    result = await fetch_data()

    assert result["status"] == "ok"
    assert len(result["items"]) == 3
```

### Redis / Cache

使用 `fakeredis` 或 mock：

```python
# tests/unit/test_cache.py
import pytest
from unittest.mock import AsyncMock

from src.services.cache import get_cached


@pytest.mark.asyncio
async def test_get_cached_hit():
    """測試 cache hit"""
    mock_redis = AsyncMock()
    mock_redis.get.return_value = b'{"value": 42}'

    result = await get_cached(mock_redis, "key")

    assert result == {"value": 42}
    mock_redis.get.assert_awaited_once_with("key")
```

### 通用原則

測試不應依賴外部服務可用性或真實 API quota。若必要跑真實呼叫，標記 `@pytest.mark.integration` 或 `@pytest.mark.e2e` 並另用 CI job 執行。

---

## Pytest Markers

用 marker 分類測試，讓開發者能選擇性執行：

```python
@pytest.mark.slow          # 耗時測試
@pytest.mark.integration   # 需外部依賴
@pytest.mark.e2e           # 完整 end-to-end
@pytest.mark.smoke         # 冒煙測試（基礎健全檢查）
```

### 使用範例

```bash
# 跑所有測試
uv run pytest

# 只跑 unit（排除 integration 與 e2e）
uv run pytest -m "not integration and not e2e"

# 只跑 smoke 測試（快速健全檢查）
uv run pytest -m smoke

# 跑所有非 slow 測試
uv run pytest -m "not slow"
```

`[tool.pytest.ini_options]`(testpaths、asyncio_mode、markers 等）配置見 `.claude/references/pyproject-tooling.example.toml`，於 `uv init` 後 merge 進你的 `pyproject.toml`。

---

## Coverage 配置

### 執行指令

```bash
# Term 報告
uv run pytest --cov=src --cov-report=term-missing

# HTML 報告（瀏覽器檢視）
uv run pytest --cov=src --cov-report=html
open htmlcov/index.html

# 強制 fail_under 檢查（CI 用）
uv run pytest --cov=src --cov-fail-under=70
```

`[tool.coverage.*]`（source、branch、fail_under、exclude_lines 等）配置見 `.claude/references/pyproject-tooling.example.toml`。本專案預設 fail_under = 70。

---

## Conftest 層級策略

```
tests/
├── conftest.py             # 全專案共享 fixtures（sample_user、db_session）
├── unit/
│   ├── conftest.py         # 僅 unit 測試共享（mock factories）
│   └── test_*.py
├── integration/
│   ├── conftest.py         # 僅 integration 測試共享（real DB, test containers）
│   └── test_*.py
└── e2e/
    ├── conftest.py         # e2e 專用（full app stack）
    └── test_*.py
```

**原則**：
- Fixture 寫在最小共用範圍的 conftest.py
- Root `tests/conftest.py` 只放全專案通用項（通常少量）
- 避免單一巨型 conftest，難維護

---

## Test Data 管理

### 小規模：inline fixtures

直接在 conftest.py 定義簡單 dict / 物件：

```python
@pytest.fixture
def sample_user():
    return {"id": 1, "name": "Alice", "role": "admin"}
```

### 中大規模：Factory Pattern

使用 `factory-boy` 或 `pytest-factoryboy`：

```python
# tests/factories.py
import factory

from src.models import User


class UserFactory(factory.Factory):
    class Meta:
        model = User

    id = factory.Sequence(lambda n: n)
    name = factory.Faker("name")
    email = factory.Faker("email")


# tests/unit/test_user.py
def test_user_creation():
    user = UserFactory()
    assert user.id > 0
    assert "@" in user.email
```

### 外部測試資料（JSON / YAML fixtures）

大型 payload 放 `tests/fixtures/` 目錄：

```python
import json
from pathlib import Path

import pytest

FIXTURES_DIR = Path(__file__).parent / "fixtures"


@pytest.fixture
def sample_api_response():
    with open(FIXTURES_DIR / "api_response.json") as f:
        return json.load(f)
```
