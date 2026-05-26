## Why

分享预览不适合作为主窗口里的普通 secondary route。它在代码上是从主窗口 navigator push 出来的页面，但在用户心智里更像一次性的分享任务。如果继续放在主窗口里，就会出现几个混淆：

- macOS traffic lights、App 返回箭头、分享取消动作挤在同一个顶层区域。
- 用户不希望额外自绘“关闭”或“取消”UI。
- 系统关闭按钮如果被改成 route pop，会让 `Cmd+W`、Window menu Close、红色关闭按钮在不同页面承担不同语义。

因此分享预览 SHOULD 收敛为 desktop one-shot task window：

```text
主窗口保持主任务
  └─ 收到分享 payload
       └─ 打开独立分享任务窗口
            ├─ native close = 取消这次分享任务
            └─ 成功动作 = 回传 ShareComposeRequest 给主窗口
```

当前架构阶段为 `evolve_modularity`，本 change 触及现有 `application/startup -> features/share` 耦合热点。后续实现 MUST 通过共享 desktop share window seam、明确的 IPC/payload serialization owner 和 guardrail，避免把分享窗口、设置窗口、主窗口继续用 ad hoc 调用缠在一起。

## What Changes

- 新增桌面通用 `desktop-share-task-window` 规则，而不是 macOS-only 或 Windows-only 临时方案。
- 分享预览在支持的平台 SHALL 使用独立 share task window，不再作为主窗口普通 secondary route 展示。
- 分享窗口 SHALL 是一次性任务窗口：不 warm hide，不复用旧 payload，关闭即取消本次分享。
- 分享窗口 SHALL 不自绘 generic close/cancel UI；关闭语义交给平台 native window close。
- 分享窗口顶层内容 SHALL consume the shared `desktop-window-chrome-safe-area` rule tracked by `standardize-desktop-window-chrome-safe-area`；本 change 不拥有所有桌面窗口 chrome 规则。
- 分享成功后 SHALL 将 `ShareComposeRequest` 或等价结构化结果回传主窗口，由主窗口前置并复用现有 composer 流程。
- macOS 作为第一优先启用目标；Windows/Linux 通过 capability gate 逐步启用。
- 如果某个平台子窗口 WebView、插件注册、IPC 或窗口创建能力不可用，SHALL fallback 到现有主窗口分享流程。

## Capabilities

### Added Capabilities

- `desktop-share-task-window`: 记录桌面分享任务窗口的生命周期、native close 语义、结果回传、平台 capability/fallback、以及架构边界规则。

## Impact

预计后续实现会影响 `memos_flutter_app` 下的桌面窗口和分享启动路径：

- `lib/main.dart`
- `lib/core/desktop_quick_input_channel.dart` 或后续重命名后的 desktop window channel constants
- `lib/application/startup/startup_coordinator_share.dart`
- `lib/application/desktop/...` 新增或扩展 desktop share window launcher/capability
- 既有桌面 chrome/navigation seam 的消费点；通用规则与跨窗口整改由 `standardize-desktop-window-chrome-safe-area` 跟踪
- `lib/features/share/share_clip_screen.dart` 或分享窗口 app wrapper
- `macos/Runner/MainFlutterWindow.swift` 的 sub-window plugin registration
- `windows/runner/flutter_window.cpp` 的 sub-window plugin registration，启用前需验证
- 相关 widget/unit/architecture tests

不触碰 API 请求/响应、route adapters、version compatibility logic 或 `memos_flutter_app/lib/data/api`。

## Non-Goals

- 不改设置页和设置窗口。
- 不在分享页自绘 generic close/cancel 控件。
- 不改变分享捕获、格式化、保存的业务规则。
- 不要求第一阶段必须启用 Windows/Linux 分享任务窗口。
- 不引入 StoreKit、subscription、entitlement、receipt、paywall、billing 或其他商业化逻辑。
