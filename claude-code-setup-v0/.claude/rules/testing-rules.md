# Testing Rules (測試規範)

## 測試命名規範

| 模式 | 說明 |
|------|------|
| `test_<function>_<scenario>` | 標準命名 |
| `test_<function>_success` | 成功路徑 |
| `test_<function>_<error_type>` | 錯誤處理 |
| `test_<function>_edge_case` | 邊界條件 |

---

## 單元測試範例

測試單一函數或類別，使用 mock 隔離外部依賴：

```python
# tests/unit/test_user_service.py
import pytest
from unittest.mock import AsyncMock, patch

@pytest.mark.asyncio
async def test_get_user_success():
    """測試成功取得使用者"""
    mock_db = AsyncMock(return_value={"id": 1, "name": "test"})

    with patch("services.user.db.find_one", mock_db):
        result = await get_user(user_id=1)

        assert result["name"] == "test"
        mock_db.assert_called_once_with({"id": 1})

@pytest.mark.asyncio
async def test_get_user_not_found():
    """測試使用者不存在的錯誤處理"""
    mock_db = AsyncMock(return_value=None)

    with patch("services.user.db.find_one", mock_db):
        with pytest.raises(NotFoundError):
            await get_user(user_id=999)
```

---

## 整合測試範例

測試多個模組協作，可使用真實服務或 test container：

```python
# tests/integration/test_order_flow.py
import pytest

@pytest.mark.asyncio
async def test_create_order_flow():
    """測試完整訂單建立流程"""
    # Arrange
    user = await create_test_user()
    product = await create_test_product()

    # Act
    order = await order_service.create(user_id=user.id, product_id=product.id)

    # Assert
    assert order is not None
    assert order.status == "pending"
    assert order.user_id == user.id
```

---

## Fixture 範例

使用 pytest fixture 管理測試資料：

```python
# tests/conftest.py
import pytest

@pytest.fixture
def sample_user():
    return {"id": 1, "name": "test", "email": "test@example.com"}

@pytest.fixture
async def db_session():
    session = await create_test_session()
    yield session
    await session.rollback()
    await session.close()
```

---

**Last Updated**: 2026-01-13
