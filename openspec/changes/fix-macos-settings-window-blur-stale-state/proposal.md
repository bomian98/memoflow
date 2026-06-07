## Why

macOS 桌面端设置窗口关闭后，主窗口仍可能保留模糊遮罩，用户必须点击主页触发兜底校验后才恢复正常。这个行为会让用户误以为主窗口仍被设置窗口占用，且暴露出设置子窗口可见性状态与真实窗口生命周期不同步的问题。

## What Changes

- 修正 macOS 设置子窗口关闭、隐藏或被系统关闭后向主窗口同步 `visible=false` 的行为。
- 收紧主窗口对桌面子窗口可见性的兜底校验，避免 stale sub-window id 长时间保留并持续驱动 `BackdropFilter` 模糊层。
- 保持设置窗口热复用语义：应用内关闭仍优先隐藏设置窗口，而不是无条件销毁子窗口进程。
- 增加或更新聚焦的桌面窗口生命周期测试/guardrail，覆盖关闭设置窗口后主窗口模糊状态应自动解除。
- 不引入 API route/version、商业功能、订阅、StoreKit、entitlement、paywall 或 private overlay 逻辑。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `macos-settings-window`: 补充设置子窗口关闭/隐藏后的主窗口可见性同步与模糊状态恢复要求。

## Impact

- 主要影响 `memos_flutter_app/lib/features/settings/desktop_settings_window_app.dart`、`memos_flutter_app/lib/application/desktop/desktop_window_manager.dart`、`memos_flutter_app/lib/application/desktop/desktop_settings_window.dart`，以及相关桌面窗口生命周期测试。
- 不修改 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`。
- 当前 architecture phase 为 `evolve_modularity`。本 change 触及桌面窗口 lifecycle/composition 边界，需保持或改善 checklist item 2、3、5、8、10：不得新增 `application -> features` 或 `core -> higher-layer` 反向依赖；`app.dart` 继续只作为 composition root；通过 focused tests/guardrail 防止窗口可见性状态回归。
