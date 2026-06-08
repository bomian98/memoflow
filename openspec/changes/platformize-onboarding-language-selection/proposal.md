## Why

iOS 首次启动语言选择页当前在 `CupertinoPageScaffold` 内直接渲染 `DropdownButton<AppLanguage>`，会触发 `No Material widget found`，阻断首次 onboarding。这个问题暴露出 onboarding 的 enum 选择仍停留在 Material dropdown 模式，没有复用项目已有的平台 picker seam。

当前架构阶段是 `evolve_modularity`。本变更触及 `features/onboarding` 和 `platform/` UI seam 的使用方式，不改变 API、数据模型、商业边界或私有扩展 seam，并通过把平台差异收敛到已有 picker seam 来保持 touched area 结构不退化。

## What Changes

- 将 onboarding 语言选择从内嵌 `DropdownButton<AppLanguage>` 改为可点击的语言选择行，并通过现有 `showPlatformPicker` 呈现选项。
- 保持语言选项、当前语言显示、`devicePreferencesProvider` 写入行为和 onboarding 模式选择行为不变。
- iPhone/iPadOS 使用平台 picker popup；Android 保持底部 sheet；macOS/Windows/Linux 使用 bounded dialog。
- 增加 iOS widget smoke/interaction 覆盖，确保首次 setup 页面可渲染并能打开语言 picker，不再依赖隐式 `Material` ancestor。
- 不引入新的 API compatibility 行为，不触碰 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `platform-adaptive-ui-system`: 明确 onboarding 等迁移后的 enum/single-option 选择应通过平台 picker seam 表达，而不是在 Apple `PlatformPage` 内容中直接嵌入 Material-only dropdown。
- `apple-platform-ui-adaptation`: 明确 Apple onboarding 语言选择属于高感知 enum selection，必须通过平台 picker abstraction 呈现，并避免 `CupertinoPageScaffold` 下的隐式 Material ancestor 依赖。

## Impact

- 预计修改 `memos_flutter_app/lib/features/onboarding/language_selection_screen.dart`。
- 预计补充 `memos_flutter_app/test/features/onboarding/platform_adaptive_onboarding_test.dart`。
- 可能复用 `memos_flutter_app/lib/platform/widgets/platform_picker.dart` 和 `memos_flutter_app/lib/platform/widgets/platform_popover_or_sheet.dart`，不新增第三方依赖。
- 不改变启动路由、session、local library、WebDAV、同步、API adapter、public/private split 或商业能力边界。
