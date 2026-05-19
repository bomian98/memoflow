## 为什么

第 1 阶段盘点指出 `lib/app.dart`、`lib/main.dart` 和 `lib/application/desktop/` 是混合运行时区域，它们现在把跨桌面职责和 Windows 专属集成混在一起。下一步需要抽出已确认的桌面通用运行时行为，这样未来 macOS 才能复用核心运行时模型，而不是复制 Windows 优先代码路径。

## 变更内容

- 将已确认的跨桌面运行时职责抽取到明确的桌面通用归属中。
- 减少桌面运行时编排里的 Windows 专属分支。
- 明确可复用的桌面运行时服务和 Windows 专属适配器之间的边界。

## 能力

### 新增能力
- `desktop-common-runtime-extraction`：从 Windows 优先实现中抽取共享桌面运行时编排的规则。

### 修改能力
- 无。

## 影响

- 可能受影响的区域：`memos_flutter_app/lib/app.dart`、`memos_flutter_app/lib/main.dart`、`memos_flutter_app/lib/application/desktop/`、`memos_flutter_app/lib/core/desktop_*`，以及相关状态/运行时接线。
