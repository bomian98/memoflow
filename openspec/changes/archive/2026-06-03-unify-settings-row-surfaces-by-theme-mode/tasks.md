## 1. Audit 与范围确认

- [x] 1.1 使用 `rg` 全量盘点 `memos_flutter_app/lib/features/settings` 中 `SettingsSection`、settings row 组件、`Container`、`Card`、`DecoratedBox`、`BoxDecoration`、`BorderSide`、`Divider`、`MemoFlowPalette`、`colorScheme.surface`、`colorScheme.surfaceContainer` 和局部透明度背景的设置行/分组用法。
- [x] 1.2 将盘点结果分类为 ordinary settings row/section/cell、semantic danger/error、theme color swatch、custom color preview、status/editing preview、media/native/system exception，并记录需要保留的例外原因。
- [x] 1.3 明确本 change 不修改全 app 普通按钮颜色、不固定 `FilledButton`/`ElevatedButton`/`OutlinedButton`/`TextButton`/`PlatformPrimaryAction` 的自定义主题色策略。
- [x] 1.4 确认本 change 不需要修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、数据模型、数据库、同步协议或 private/commercial hooks。

## 2. Settings surface tokens 与 seam

- [x] 2.1 在 `memos_flutter_app/lib/features/settings/settings_ui.dart` 或同层 settings token/seam 中定义按 `Brightness.light` / `Brightness.dark` 分支的 section background、row background、value area、border、divider、hover、pressed、selected 和 disabled surface tokens。
- [x] 2.2 调整 `SettingsSection`、`SettingsNavigationRow`、`SettingsValueRow`、`SettingsToggleRow`、`SettingsAction` 或等价 settings row 组件，确保普通设置行/分组默认使用统一 settings surface tokens。
- [x] 2.3 验证设置 row/cell 的 text/icon/value/toggle 布局和现有行为不变，只收敛背景、边框、分割线和交互态来源。
- [x] 2.4 保持真正按钮组件的颜色解析路径不变，避免在 `app_theme.dart` 中新增全 app button theme 改动。

## 3. 清理设置页面局部背景样式

- [x] 3.1 清理 Preferences、Desktop、AI、Components、Account/Security、Import/Export、About、Feedback 等已迁移设置页面中符合 ordinary settings row/section/cell 分类的局部背景、边框和分割线硬编码。
- [x] 3.2 对仍需要局部视觉的 theme color swatch、custom color preview、status/editing preview、danger/error action 和 native/system surface 添加明确例外说明或 allowlist。
- [x] 3.3 确保设置页面继续通过 settings/platform seam 表达设置项语义，不新增 `core -> features`、`platform -> features`、`state -> features` 或 `application -> features` 依赖。

## 4. Guardrail 与测试

- [x] 4.1 更新或新增 settings UI focused tests，验证 light/dark 下 `SettingsSection` 和代表性 settings rows 的 section background、row background、divider、border、hover/pressed/selected/disabled tokens 来自统一 seam。
- [x] 4.2 更新 `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`，阻止非 allowlisted migrated settings file 为普通设置 row/section/cell 引入 page-local background、border、divider 或 raw palette surface styling。
- [x] 4.3 在 guardrail allowlist 中保留并说明合法例外：danger/error、theme swatch、color preview、status/editing preview、media/native/system surface、window controls。
- [x] 4.4 增加一个回归检查，确认本 change 没有引入全 app button theme 固定色或移除按钮颜色自定义路径。

## 5. 验证与收尾

- [x] 5.1 从 `memos_flutter_app` 运行 `dart format` 覆盖所有修改过的 Dart 文件。
- [x] 5.2 从 `memos_flutter_app` 运行 focused tests：`flutter test test/architecture/settings_ui_drift_guardrail_test.dart test/features/settings --reporter expanded`，并补跑与被迁移 settings 页面相关的 widget tests。
- [x] 5.3 从 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 5.4 从 `memos_flutter_app` 运行 `flutter test`；如受环境限制无法完成，记录具体失败命令、原因和剩余风险。
- [x] 5.5 在 light/dark 模式下人工或截图检查设置右侧 `语言`、`字号`、`行高`、`字体`、`启动动作`、`主题色` 等设置行和分组背景，确认统一样式符合用户提供的效果图，且真正按钮颜色仍可自定义。
