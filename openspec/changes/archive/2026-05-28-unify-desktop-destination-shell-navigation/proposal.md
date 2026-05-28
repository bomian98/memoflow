## Why

桌面端已经有 `DesktopShellHost`、`WindowsDesktopPageShell`、`AppleMacosPageShell` 和 titlebar navigation policy，但多个顶层 drawer destination 仍在页面内写 `isWindowsDesktop ? DesktopShellHost(...) : Scaffold(...)`。这会让 Windows/macOS 顶栏、返回按钮、标题显示和侧栏行为继续按页面漂移，例如随机漫步在 Windows 显示返回按钮而 macOS 不显示。

当前架构阶段是 `evolve_modularity`，本 change 触及 desktop shell、home/navigation、review、settings、memos 等耦合热点。涉及模块化清单项：`6.` feature-to-feature collaboration prefers boundary/registry/provider seams，`8.` architecture guardrail tests，`10.` touched coupled area equal or better structured。本 change 的架构改善是把桌面顶层 destination 的平台分支收敛到 shell seam，并增加 guardrail 防止页面级分支回流。

## What Changes

- 新增或增强一个桌面顶层 destination shell seam，使 feature page 只表达语义输入：
  - selected drawer destination
  - title / leading title intent
  - actions / command content
  - body
  - secondary pane / modal surface
  - navigation context
- 迁移已识别的顶层桌面 destination 页面，不再由页面自行分叉 Windows/macOS 顶层壳：
  - `DailyReviewScreen`
  - `ExploreScreen`
  - `AiSummaryScreen`
  - `TagsScreen`
  - `ResourcesScreen`
  - `NotificationsScreen`
  - `AboutScreen`
  - `CollectionsScreen`
  - `RecycleBinScreen`
  - `SettingsScreen`（保留 close 语义，但通过统一 seam 表达）
- 将顶层 title visibility、back/close 控件、sidebar/rail/overlay navigation mode、macOS traffic-light safe-area 和 Windows command bar/window controls 继续留在 desktop shell layer。
- 增加 guardrail，防止顶层 drawer destination 页面继续出现：
  - `isWindowsDesktop ? DesktopShellHost(...) : Scaffold(...)`
  - 在 `DesktopShellHost.leadingTitle` 中手写 back/close `IconButton` + title `Row`
  - 顶层页面绕过统一 shell seam 自己处理 macOS expanded-sidebar title suppression
- 不处理 broader architecture debt：
  - 不清理现有 `state -> features`、`application -> features`、`core -> higher layer` 历史 allowlist
  - 不重构 `app.dart` / `main.dart`
  - 不迁移所有 settings UI
  - 不改变业务状态、数据模型、API、同步或 memo mutation 行为

## Capabilities

### New Capabilities

- `desktop-destination-shell-navigation`: 定义桌面顶层 drawer destination 通过统一 shell seam 表达语义标题、导航、actions、body 和平台外壳行为。

### Modified Capabilities

- `desktop-shell-host-boundary`: 收紧要求，明确顶层 desktop destination 页面不得再按 Windows/macOS 分叉 shell 树，必须通过 host 或等价 seam 组合。
- `desktop-titlebar-navigation-context`: 补充顶层 destination back/close/title 语义必须由 shell policy 统一决定，页面不得把 dismissal control 隐藏在 title widget 中。
- `platform-adaptive-ui-system`: 补充 migrated desktop feature 对 scaffold/navigation shell 的使用标准，避免页面级 platform branch 继续扩散。

## Impact

- Affected shell / platform files:
  - `memos_flutter_app/lib/features/home/desktop/desktop_shell_host.dart`
  - `memos_flutter_app/lib/features/home/desktop/windows_desktop_page_shell.dart`
  - `memos_flutter_app/lib/features/home/desktop/apple_macos_page_shell.dart`
  - possibly `memos_flutter_app/lib/platform/widgets/platform_page.dart` if the existing seam is reused
- Affected feature pages:
  - `features/review/daily_review_screen.dart`
  - `features/explore/explore_screen.dart`
  - `features/review/ai_summary_screen.dart`
  - `features/tags/tags_screen.dart`
  - `features/resources/resources_screen.dart`
  - `features/notifications/notifications_screen.dart`
  - `features/about/about_screen.dart`
  - `features/collections/collections_screen.dart`
  - `features/memos/recycle_bin_screen.dart`
  - `features/settings/settings_screen.dart`
- Affected tests / guardrails:
  - `test/architecture/desktop_shell_boundary_guardrail_test.dart`
  - focused widget tests for Windows/macOS desktop destination shell behavior
  - existing platform UI guardrails as relevant
- No API files, DB schema, persistence models, sync protocol, subscription/commercial logic, or private overlay behavior are in scope.
