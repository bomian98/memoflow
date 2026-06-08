## Why

iOS 本地模式创建本地库时，`LocalModeSetupScreen` 在 `CupertinoPageScaffold` / `CupertinoListTile` 内容中通过 `SettingsInputRow` 渲染 `PlatformTextField`，但 `PlatformTextField` 当前无条件返回 Material `TextField`，触发 `No Material widget found` 并阻断 onboarding。这个问题与此前 onboarding 语言 `DropdownButton` 崩溃同类，说明 Apple mobile 页面 chrome、设置行、输入控件、反馈和 route seam 仍未形成完整的平台化闭环。

当前架构阶段是 `evolve_modularity`，本变更触及 `platform/widgets`、`features/settings` 和 onboarding 调用路径，属于 settings/platform coupled area。变更应通过补齐共享 platform/settings seam、增加 focused guardrails 和 iOS smoke tests，让 touched area equal or better structured，而不是在单个页面局部包 `Material` 压住异常。

## What Changes

- 补齐 `PlatformTextField` 的 Apple mobile 行为，使 iPhone/iPadOS 在 `PlatformPage` / `CupertinoPageScaffold` 内容中可以渲染平台适配输入控件，不依赖隐式 `Material` ancestor。
- 将 `SettingsInputRow` 的输入语义保持在 settings seam 内，避免设置页直接散落 `TextField` / `CupertinoTextField` 分支，并为 Apple grouped settings row 提供稳定输入布局。
- 收敛 `LocalModeSetupScreen` 的 transient feedback，避免空名称校验依赖 `ScaffoldMessenger` / `SnackBar` 这个 Material-only feedback path。
- 让 `LocalModeSetupScreen.show()` 使用已有 platform route seam，使 iPhone/iPadOS 进入该子流程时获得 Apple-appropriate route transition/back behavior。
- 增加 iPhone/iPadOS 本地库 setup focused widget tests，覆盖页面渲染、输入编辑、空名称反馈和确认返回 trimmed name。
- 增加或收紧 platform/settings guardrails，防止 future Apple mobile `PlatformPage` 内容再次直接依赖 Material-only form controls 或 feature-local platform branches。
- 不修改 API route/version compatibility、request/response model、数据 schema、WebDAV sync、local library 持久化语义、商业能力边界或 private extension seam。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `platform-adaptive-ui-system`: 明确 adaptive form controls、settings input rows、feedback surfaces 和 route presentation 必须通过 platform/settings seams 表达，Apple mobile `PlatformPage` 内容不得依赖隐式 `Material` ancestor 才能渲染。
- `apple-platform-ui-adaptation`: 明确 iPhone/iPadOS grouped settings 与 onboarding/local setup 等高感知流程中的 text input、validation feedback 和 route transition 必须使用 Apple-safe platform behavior，并保持 public-shell/commercial boundary。

## Impact

- 预计修改 `memos_flutter_app/lib/platform/widgets/platform_controls.dart`，为 `PlatformTextField` 增加 Apple mobile 分支或等效平台安全实现，并保留 Android/desktop 现有行为。
- 预计修改 `memos_flutter_app/lib/features/settings/settings_ui.dart`，让 `SettingsInputRow` 通过平台中立参数消费输入 seam，减少 Material `InputDecoration` 语义向 Apple mobile 泄漏。
- 预计修改 `memos_flutter_app/lib/features/settings/local_mode_setup_screen.dart`，使用 platform route seam 和平台安全 feedback path。
- 预计补充 `memos_flutter_app/test/features/onboarding/platform_adaptive_onboarding_test.dart`、`memos_flutter_app/test/features/settings/local_mode_setup_screen_test.dart` 或等效 focused tests。
- 可能补充 `memos_flutter_app/test/platform/...` 或 architecture guardrail tests，验证 `platform/` 不引入 `features/*`、`state/*`、`application/*`、`data/*` 依赖，并防止 Apple mobile platform surfaces 回退到 Material-only 控件。
- Public/private split 不变；本变更不得添加 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、price、private overlay 或 `AccessDecision.source` business branching。
