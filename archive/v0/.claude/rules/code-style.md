# code-style.md

## Docstring 規範
**核心原則**：使用 Google Style，包含 Args、Returns、Raises、Example。內容以繁體中文為主、技術術語則以英文呈現。

```python
def function_name(param1: Type1, param2: Type2 = default) -> ReturnType:
    """
    [一句話描述函數功能]

    [更詳細的描述此函數功能(可選)]

    Args:
        param1: [參數說明]
        param2: [參數說明]，預設 [default]

    Returns:
        [回傳值說明]

    Raises:
        SomeError: [何時會拋出此例外]

    Example:
        >>> result = function_name(value1, value2)
        >>> print(result)
    """
```

---

**Last Updated**: 2026-01-13
