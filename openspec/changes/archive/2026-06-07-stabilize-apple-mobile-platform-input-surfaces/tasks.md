## 1. Focused 测试准备

- [x] 1.1 在 `memos_flutter_app/test/platform` 或等效位置增加 `PlatformTextField` widget tests，覆盖 iPhone/iPadOS 渲染 Apple-safe input，Android/desktop 保持 Material `TextField` path。
- [x] 1.2 在 `memos_flutter_app/test/features/settings/local_mode_setup_screen_test.dart` 增加 iPhone viewport + `debugPlatformTargetOverride = TargetPlatform.iOS` 的 render smoke test，断言无 Flutter framework exception。
- [x] 1.3 增加 iPhone 本地库名称输入编辑测试，验证可输入新名称并通过确认返回 trimmed `LocalModeSetupResult`。
- [x] 1.4 增加 iPhone 空名称提交测试，验证显示平台安全 validation feedback，route 保持打开且无 framework exception。
- [x] 1.5 增加或扩展 iPadOS 宽度 smoke test，验证 local setup 复用同一 shared behavior，不创建 iPad-only page tree。
- [x] 1.6 保留并运行 Android/desktop 现有 `LocalModeSetupScreen` 和 onboarding tests，记录需要保持的非 Apple 行为。

## 2. Platform input seam 实现

- [x] 2.1 修改 `memos_flutter_app/lib/platform/widgets/platform_controls.dart`，让 `PlatformTextField` 在 `PlatformTarget.iPhone` / `PlatformTarget.iPad` 使用 `CupertinoTextField` 或等效 Apple-safe platform input。
- [x] 2.2 在 `PlatformTextField` 内完成当前 call sites 需要的 `InputDecoration` 兼容映射，包括 `hintText`、`hintStyle`、`suffixIcon`、`contentPadding`、`InputBorder.none`、`style`、`enabled`、`minLines/maxLines`、`keyboardType`、`inputFormatters`、`obscureText`、`readOnly`、`textInputAction` 和 callbacks。
- [x] 2.3 确认非 Apple 分支继续返回现有 Material `TextField`，不改变 Android、Windows、macOS、Linux 的默认输入行为。
- [x] 2.4 如 Apple mobile 输入布局需要 padding、decoration 或 suffix placement 调整，仅在 `PlatformTextField` / settings seam 内处理，不在 feature pages 添加局部分支。

## 3. Settings input row 与本地库 setup

- [x] 3.1 检查 `memos_flutter_app/lib/features/settings/settings_ui.dart` 的 `SettingsInputRow`，确保它通过平台中立参数表达 input intent，并继续委托 `PlatformTextField` 处理平台控件。
- [x] 3.2 修改 `memos_flutter_app/lib/features/settings/local_mode_setup_screen.dart`，让 `LocalModeSetupScreen.show()` 使用 `buildPlatformPageRoute` 或等效 platform route seam。
- [x] 3.3 将 `LocalModeSetupScreen` 空名称校验反馈从 `ScaffoldMessenger` / `SnackBar` 调整为 `showTopToast` 或等效平台安全 feedback path。
- [x] 3.4 确认 onboarding 本地模式、account/security 添加本地库、account/security 重命名本地库三个入口都复用同一个 setup behavior。
- [x] 3.5 确认 local library 创建、rename、cancel、trimmed name result、workspace path 和 provider mutation semantics 不变。

## 4. Modularity 与 guardrail

- [x] 4.1 检查 `memos_flutter_app/lib/platform` touched files，确认没有新增 `features/*`、`state/*`、`application/*` 或 `data/*` imports。
- [x] 4.2 增加或扩展 architecture guardrail/repo scan，防止本变更引入新的 `platform -> features/state/application/data` dependency。
- [x] 4.3 增加或扩展 focused guardrail，防止 migrated Apple mobile settings/onboarding input path 通过 feature-page-local `Material` wrapper 规避 platform seam。
- [x] 4.4 检查 touched public files，确认没有新增 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、price、private overlay 或 `AccessDecision.source` business branching。

## 5. 验证

- [x] 5.1 在 `memos_flutter_app` 运行新增 `PlatformTextField` focused tests。
- [x] 5.2 在 `memos_flutter_app` 运行 `flutter test test/features/settings/local_mode_setup_screen_test.dart --reporter expanded`。
- [x] 5.3 在 `memos_flutter_app` 运行相关 onboarding focused tests，例如 `flutter test test/features/onboarding/platform_adaptive_onboarding_test.dart --reporter expanded`。
- [x] 5.4 在 `memos_flutter_app` 运行相关 architecture guardrail tests 或 repo scans。
- [x] 5.5 在 `memos_flutter_app` 运行 `flutter analyze`。
- [ ] 5.6 在 `memos_flutter_app` 运行 `flutter test`。
- [x] 5.7 提交前检查 staged 和 unstaged changes，确认没有商业、订阅、计费、entitlement、paywall、StoreKit 或其他 paid-feature code 泄漏到 public repository。
