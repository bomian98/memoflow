## 1. 范围盘点与例外确认

- [x] 1.1 使用 `rg` / 文件阅读盘点 `memos_flutter_app/lib/features/settings/settings_screen.dart` 中 profile 入口、quick shortcut tiles、功能分组、single-row section、extension entries 和 footer 的当前结构。
- [x] 1.2 盘点 `memos_flutter_app/lib/features/settings/settings_ui.dart` 中 `SettingsHomeProfileEntry`、`SettingsHomeShortcutTile`、`SettingsSection`、`SettingsNavigationRow`、`settingsPageTokens` 和相关 style/token 的现状。
- [x] 1.3 将设置首页元素分类为 mobile home hierarchy target、普通二级/三级 settings row、头像/图片例外、private extension entries、semantic danger/error、native/system/media exception，并记录哪些视觉必须保留。
- [x] 1.4 确认本 change 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、数据模型、数据库、同步协议、AI provider 业务、private/commercial hooks 或全 app button theme。

## 2. Settings home hierarchy seam 与 tokens

- [x] 2.1 在 `memos_flutter_app/lib/features/settings/settings_ui.dart` 或同层 settings seam 中扩展 home-specific hierarchy tokens，覆盖 home card background、border、divider、shadow/elevation、radius、spacing、shortcut tile height、light/dark mode 层级。
- [x] 2.2 让 home hierarchy tokens 根据 platform/form factor 区分手机端与 desktop experience：手机端使用更明显的卡片层级，桌面端保持克制密集表现。
- [x] 2.3 新增 `SettingsHomeSection`、`SettingsSectionVariant.home` 或等价 settings-owned seam，用于设置首页 grouped function sections 和 single-row sections，避免修改 `SettingsSection` 全局默认导致二级/三级页变重。
- [x] 2.4 调整 `SettingsHomeProfileEntry` 和 `SettingsHomeShortcutTile` 使用 home hierarchy tokens/seam，保留头像渲染、文字截断、tap target、InkWell/pressed/hover 行为和 light/dark 适配。
- [x] 2.5 确保真正按钮组件颜色解析路径不变，不在 `memos_flutter_app/lib/core/app_theme.dart` 中新增 `filledButtonTheme`、`elevatedButtonTheme`、`outlinedButtonTheme` 或 `textButtonTheme` 固定色改动。

## 3. 设置首页接入

- [x] 3.1 将 `SettingsScreen` 中设置首页普通功能分组从标准 section 接入 home hierarchy seam，保持 grouped card + row divider 模型。
- [x] 3.2 保持 quick shortcut tiles 作为独立功能卡片，不把普通功能 row 全部拆成独立卡片。
- [x] 3.3 保持所有导航目标、haptic 调用、`privateExtensionBundleProvider` extension entry 排序和 `DonationDialog.show` 行为不变。
- [x] 3.4 确认二级/三级页面继续使用标准 `SettingsPage` / `SettingsSection` / settings row surface tokens，不自动继承 mobile home-only shadow/radius treatment。
- [x] 3.5 检查手机端窄屏文字、图标、分割线、卡片圆角、底部安全区和滚动内容不重叠、不溢出。

## 4. 测试与 guardrail

- [x] 4.1 更新或新增 focused widget tests，覆盖手机端 `SettingsScreen` 中 profile card、shortcut tiles、grouped function sections、single-row section 的 home hierarchy token/seam 使用。
- [x] 4.2 增加 light/dark mode 测试，验证手机端设置首页卡片背景、边框/分割线、shadow/dark equivalent、radius 和 spacing 来自 settings-owned seam。
- [x] 4.3 增加或更新二级/三级页面回归测试，确认标准 `SettingsSection` 没有被 mobile home hierarchy 全局改重。
- [x] 4.4 更新 `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`，允许 `settings_ui.dart` 拥有 home hierarchy tokens/seams，同时阻止 migrated settings screen 引入 page-local background、border、divider、shadow、radius 或 raw palette styling 漂移。
- [x] 4.5 增加回归检查，确认本 change 没有引入全 app button theme 固定色或移除按钮颜色自定义路径。

## 5. 验证与收尾

- [x] 5.1 从 `memos_flutter_app` 运行 `dart format` 覆盖所有修改过的 Dart 文件。
- [x] 5.2 从 `memos_flutter_app` 运行 focused tests：settings home hierarchy tests、settings UI semantic tests、settings drift guardrail tests 和受影响的 `settings_screen_test.dart`。
- [x] 5.3 从 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 5.4 从 `memos_flutter_app` 运行 `flutter test`；如受既有无关失败或环境限制无法完成，记录具体失败命令、失败用例和剩余风险。
- [x] 5.5 在手机端 light/dark 模式下人工或截图检查设置首页 profile card、三个快捷功能卡片、功能分组、single-row section、底部安全区和滚动状态，确认层次感接近用户提供的效果图且二级/三级页没有被过度卡片化。
