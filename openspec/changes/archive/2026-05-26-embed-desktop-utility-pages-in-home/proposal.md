## Why

`SyncQueueScreen` 和 `NotificationsScreen` 在桌面端更像主页工作区里的工具视图，而不是需要离开主页的独立二级页。继续把它们作为独立 route 打开，会让每个页面都需要单独处理顶层标题栏、返回和 desktop window chrome safe-area，容易回到页面级修补。

当前架构阶段为 `evolve_modularity`。本 change 会触及 home navigation、memos list shell、sync queue / notifications feature roots；目标是在不改移动端、不改设置页、不触碰 API 的前提下，让桌面端从主页侧边栏或标题栏入口打开同步队列/消息通知时，直接替换主页笔记列内容，并让侧边栏选中状态清空。

## What Changes

- 桌面端主页打开 `SyncQueueScreen` / `NotificationsScreen` 时，使用主页主内容列承载它们的 embedded body，替换原来的 inline compose + memo list。
- 桌面端在探索、统计、标签、回收站、设置等其他抽屉页面点击同步队列/消息通知时，也回到主页 shell 并显示同一套 embedded utility view。
- 嵌入态不渲染独立页面顶层 `AppBar`；窗口 chrome 与标题栏仍由主页 shell 拥有。
- 嵌入态在局部内容标题左侧提供返回按钮，点击后清除 utility view 并回到主页笔记列。
- 侧边栏在显示这些 utility view 时不高亮任何 destination，tag selection 也清空。
- 移动端和 tablet bottom navigation 保持现有独立 route / embeddedBottomNav 行为。
- 保留独立 route 能力，供非主页桌面入口或移动端继续使用。

## Capabilities

### New Capabilities

- `desktop-home-utility-embedding`: 桌面主页可以以内嵌方式承载同步队列和消息通知等工具视图。

### Modified Capabilities

无。

## Impact

- 预计影响 `memos_flutter_app/lib/features/memos/memos_list_screen.dart`、`memos_list_route_delegate.dart`、`memos_list_screen_body.dart` 或等价 home shell 组合层。
- 预计影响 `lib/features/sync/sync_queue_screen.dart` 和 `lib/features/notifications/notifications_screen.dart`，以暴露不拥有顶层 page chrome 的 embedded body。
- 可能新增/调整 focused widget tests 与 architecture guardrail，防止桌面 utility view 重新作为独立 titlebar owner。
- 不触碰 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`。
- 不引入 StoreKit、subscription、entitlement、receipt、paywall、billing 或其他商业化逻辑。
