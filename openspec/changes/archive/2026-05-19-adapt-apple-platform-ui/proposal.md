## Why

当前 Flutter 应用已经完成 Android 和 Windows 端 UI，但 iOS、iPadOS 和 macOS 如果直接复用现有 Material / Windows 风格页面，会产生明显平台违和感。现在需要建立低侵入式 Apple 平台 UI 适配层，在复用业务页面、状态管理和数据层的前提下，让 Apple 平台拥有独立、自然、可持续维护的体验。

## What Changes

- 新增公共仓 Apple 平台 UI 适配能力，覆盖 iOS、iPadOS 和 macOS 的 shell、页面外壳、导航、弹窗、菜单、选择器、分组列表、关键图标和基础 adaptive 控件。
- 新增 `memos_flutter_app/lib/platform/` 或等价 UI seam 目录，用于集中平台判断和平台 UI 组件；不在 `features/` 下复制 `features_ios/`、`features_ipad/` 或 `features_macos/` 页面树。
- 保留现有业务页面主体、Riverpod state、application services、data repositories 和 public/private extension seam；只逐步替换高感知平台 UI 边界。
- 为 iOS、iPadOS 和 macOS 定义不同程度的 Apple 原生化策略：
  - iOS 使用 Apple 风格 tab、navigation bar、route transition、alert、action sheet、picker 和返回手势。
  - iPadOS 使用 sidebar / split-view 优先的布局，不简单放大 iPhone UI。
  - macOS 使用独立 desktop shell、sidebar、toolbar、menu / shortcut / window semantics，不复用 Windows window controls 作为最终体验。
- 以 `SettingsScreen` / `PreferencesSettingsScreen` 作为首批 grouped list、picker、dialog 试点，再迁移首页 shell、memo list、memo editor、note input 和其他设置/集合/提醒页面。
- 建立迁移进度跟踪任务，要求每批迁移明确标注已完成、进行中和未完成范围，直到高感知 Apple UI 区域全部处理完成。
- 明确商业化边界：本 change 不引入 StoreKit、订阅、买断、权益、价格、商品 ID、receipt、paywall、App Store 发布自动化或私有商业运行时逻辑。
- 当前架构阶段为 `evolve_modularity`。本 change 触及 modularity checklist item 5、6、8、9、10，并通过集中 `platform/` UI seam、减少页面内平台分支、避免新增 `state -> features` / `application -> features` / `core -> higher-layer` 依赖，使被触及区域结构不变差。

## Capabilities

### New Capabilities

- `apple-platform-ui-adaptation`: 定义公共仓 Apple 平台 UI 适配规则，包括 iOS / iPadOS / macOS shell 分化、平台 UI adapter、组件职责、迁移进度治理、App Store 体验约束和商业边界排除。

### Modified Capabilities

- 无。

## Impact

- 主要影响 Dart UI 层：
  - `memos_flutter_app/lib/platform/` 或等价新增 UI seam。
  - `memos_flutter_app/lib/core/platform_layout.dart`
  - `memos_flutter_app/lib/core/app_theme.dart`
  - `memos_flutter_app/lib/core/app_route_transitions.dart`
  - `memos_flutter_app/lib/features/home/`
  - `memos_flutter_app/lib/features/home/desktop/`
  - `memos_flutter_app/lib/features/settings/`
  - `memos_flutter_app/lib/features/memos/`
  - 后续分批覆盖 `collections`、`reminders`、`review`、`stats`、`debug` 等页面中的高感知平台组件。
- 可能需要新增或调整架构 guardrail，防止平台 UI seam 导入 feature / state / application 等更高层，防止 Apple 商业逻辑进入公共 shell。
- 不影响 API route、request / response models、API compatibility logic 或 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`。
- 不新增商业 runtime 依赖，不触碰 `private_hooks` 的商业实现边界，不向共享 preferences、session、account 或 public models 写入付费状态。
