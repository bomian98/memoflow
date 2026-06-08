## 1. Onboarding 语言选择平台化

- [x] 1.1 在 `LanguageSelectionScreen` 中移除内嵌 `DropdownButton<AppLanguage>`，改为可点击的语言 selector row/card。
- [x] 1.2 新增页面私有的语言 picker 触发逻辑，调用现有 `showPlatformPicker` 展示 `_languageOptions`。
- [x] 1.3 选择语言后复用 `_handleLanguageChanged`，保持 `devicePreferencesProvider` 写入行为和当前语言显示逻辑不变。
- [x] 1.4 保持 onboarding mode cards、`PlatformPrimaryAction`、local/server flow、startup route decision 不变。
- [x] 1.5 为 `showPlatformPicker` 增加可选 centered dialog presentation，并让 onboarding 语言 picker 使用居中、宽高受限、内部可滚动的呈现。

## 2. 平台边界与结构保护

- [x] 2.1 确认 `features/onboarding` 只依赖现有 `platform/widgets/platform_picker.dart` seam，不向 `platform/` 引入 `features/*`、`state/*`、`application/*` 或 `data/*` 反向依赖。
- [x] 2.2 避免在 `PlatformPage` iOS 分支做全局 `Material` 包裹，保持修复范围限定在 onboarding 语言选择交互。
- [x] 2.3 确认本变更不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、price、private overlay 或 `AccessDecision.source` business branching。

## 3. 测试覆盖

- [x] 3.1 在 `platform_adaptive_onboarding_test.dart` 增加 iPhone viewport + `TargetPlatform.iOS` 的首次 setup 渲染测试，断言没有 Flutter framework exception。
- [x] 3.2 增加 iOS 语言 selector 点击测试，断言居中 picker、可滚动列表和选项出现，并可选择一个非当前语言。
- [x] 3.3 保留或调整现有 macOS 桌面 primary action 宽度测试，确保桌面 onboarding 视觉约束不回退。

## 4. 验证

- [x] 4.1 在 `memos_flutter_app` 运行 focused onboarding/platform widget tests。
- [x] 4.2 在 `memos_flutter_app` 运行 `flutter analyze`。
- [ ] 4.3 在 `memos_flutter_app` 运行 `flutter test`。
- [x] 4.4 提交前检查 staged 和 unstaged changes，确认没有商业、订阅、计费、entitlement、paywall、StoreKit 或其他 paid-feature code 泄漏到 public repository。
