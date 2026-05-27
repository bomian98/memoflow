## Why

桌面端首页的 inline compose 输入框在整改后出现无法拖拽调整大小的问题，且用户确认 Windows 也会复现。现有代码里 resize 入口依赖多个分散条件，部分桌面导航路径会创建未启用 resize 的 `MemosListScreen`，导致同一个“全部 memo”页面在不同入口下行为不一致。

本变更处于 `evolve_modularity` 阶段，触及 `home`、`memos`、`application/desktop` 以及桌面布局判断热点。Touched checklist items: `6.` feature-to-feature collaboration prefers boundary/registry/provider seams, `8.` architecture guardrail tests, `10.` touched coupled area equal or better structured.

## What Changes

- 恢复 supported desktop home inline compose 的可拖拽 resize 行为，优先覆盖 Windows 已确认回归路径。
- 统一桌面首页 memo 入口的 resize capability 决策，避免 `HomeRootDestination.memos`、drawer replacement、utility return 等路径传递不同 flag。
- 将 resize 启用条件表达为 supported desktop compose capability，而不是页面入口散落地硬编码 Windows-only flag。
- 保留现有 inline compose 草稿、附件、预览窗格、键盘快捷键、滚动锚点和布局持久化行为。
- Linux desktop 当前未适配，本变更不承诺启用 Linux resize；如代码路径需要判断，应显式保持 disabled 或 fallback。
- 增加真实用户拖拽级别的 widget/focused tests，覆盖 resize handle 存在、拖拽后尺寸变化、布局持久化和不同入口行为一致。
- 收紧或补充 guardrail，防止未来新增 desktop memos 入口时漏传 resize capability。

## Capabilities

### New Capabilities

- `desktop-home-inline-compose-resize`: 定义桌面首页 inline compose 面板 resize、入口一致性、平台支持范围、持久化和测试要求。

### Modified Capabilities

- `desktop-shell-host-boundary`: 明确桌面 memo list 的共享 desktop 行为不应被入口级 Windows-only 或 standalone-only flag 隐藏，除非有显式平台例外。

## Impact

- 可能涉及：
  - `memos_flutter_app/lib/features/home/home_root_destination_registry.dart`
  - `memos_flutter_app/lib/features/home/app_drawer_destination_builder.dart`
  - `memos_flutter_app/lib/features/memos/memos_list_screen.dart`
  - `memos_flutter_app/lib/features/memos/memos_list_screen_view_state.dart`
  - `memos_flutter_app/lib/application/desktop/desktop_resizable_panel_shell.dart` only if hit testing needs a focused fix
  - `memos_flutter_app/test/features/home/...`
  - `memos_flutter_app/test/features/memos/...`
  - `memos_flutter_app/test/application/desktop/...`
- 不涉及 API routes、request/response models、`lib/data/api` 或 `test/data/api`。
- 不新增 subscription、billing、entitlement、paywall、StoreKit 或其他商业逻辑。
