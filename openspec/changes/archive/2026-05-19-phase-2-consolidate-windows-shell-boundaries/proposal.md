## 为什么

第 1 阶段盘点确认 Windows 外壳确实是一个合法的平台归属层，但它的归属需要更明确，这样可复用原语才能被抽出来，而不会让剩余的 Windows 外壳继续变成一个含糊的“杂物区”。这一阶段要明确哪些内容在抽取后仍然归 Windows 拥有。

## 变更内容

- 收敛 Windows 外壳对仅外壳 widget 和行为的明确归属。
- 将可复用的桌面原语与 Windows 专属呈现和集成分离。
- 明确哪些设置、字符串和原生集成仍归 Windows 拥有。

## 能力

### 新增能力
- `windows-shell-boundary-consolidation`：在桌面通用抽取之后，明确并保留 Windows 外壳归属的规则。

### 修改能力
- 无。

## 影响

- 可能受影响的区域：`memos_flutter_app/lib/features/home/desktop/`、Windows 专属设置和 UX 字符串、`memos_flutter_app/windows/`，以及 `lib/core/` 和 `lib/application/desktop/` 中的 Windows 专属 helper。
