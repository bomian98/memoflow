## 1. 准备与范围确认

- [x] 1.1 复查 `settings_ui.dart`、`SettingsScreen`、`ImageBedSettingsScreen`、`ImageCompressionSettingsScreen` 和 `settings_ui_drift_guardrail_test.dart` 的当前结构，确认本批只迁移这三个页面。
- [x] 1.2 运行或复查现有 focused tests 的覆盖点：`settings_screen_test.dart`、`platform_adaptive_settings_test.dart`、图床/图片压缩相关 provider 或 widget tests。
- [x] 1.3 确认本 change 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、provider owner、repository、model schema、desktop settings window target routing 或 commercial/private seam。

## 2. Settings UI seam 扩展

- [x] 2.1 在 `settings_ui.dart` 中复用或新增窄语义组件，覆盖本批真实需要的 settings input/select/stepper/warning/action 表达。
- [x] 2.2 确保新增 settings UI seam 使用 `PlatformListSectionRow`、`PlatformTextField`、`PlatformSwitch`、`SettingsAction`、`settingsPageTokens` 或 `ThemeData` / `ColorScheme`，避免新增页面直接使用 raw palette。
- [x] 2.3 为新增 seam 保持 API 窄而通用，不把图床 provider、图片压缩 domain labels、WebDAV 或 AI 特定概念塞进 `settings_ui.dart`。
- [x] 2.4 如新增 source-level seam 行为测试可行，补充最小测试覆盖 input/select/stepper/action 组件的基本渲染或交互。

## 3. 迁移 SettingsScreen

- [x] 3.1 将 `SettingsScreen` 内容区的 reusable settings entry/group/profile/shortcut 视觉收敛到 settings semantic seam 或 approved settings-home composition seam。
- [x] 3.2 保留现有 `PlatformPage` / `DesktopDestinationShell` / drawer / close / embedded navigation behavior，不因 UI 迁移改变顶层 settings destination 语义。
- [x] 3.3 保留 account profile entry、stats/widgets/API shortcut entries、desktop settings platform gate、private extension bundle entries、donation entry 和 version footer。
- [x] 3.4 移除或替换 `SettingsScreen` 中可复用导航 UI 的 direct `MemoFlowPalette`、私有 `_CardGroup`、`_SettingRow`、`_ProfileCard`、`_ShortcutTile` visual system。
- [x] 3.5 更新 `settings_screen_test.dart` 或 `platform_adaptive_settings_test.dart`，覆盖设置首页入口、private extension entry、donation entry、desktop settings gate 和 bounded content 仍可用。

## 4. 迁移 ImageBedSettingsScreen

- [x] 4.1 将 `ImageBedSettingsScreen` 外层 `Scaffold` / transparent `AppBar` / background gradient 迁移到 `SettingsPage` 或 approved settings page seam。
- [x] 4.2 将 enable row、provider row、base URL / credential input rows、retry/stepper rows 和 actions 迁移到 settings semantic components。
- [x] 4.3 保留 `imageBedSettingsProvider` owner、enabled toggle、provider selection、base URL normalization、credential input、retry count 和 save/update callback 行为。
- [x] 4.4 移除或替换图床页面中的 `_ToggleCard`、`_Group`、`_SelectRow`、`_InputRow`、`_StepperRow` 等可复用私有视觉组件。
- [x] 4.5 增加或更新 focused widget tests，覆盖图床 enable toggle、provider selection 或关键输入更新行为；如 provider test 已覆盖行为，则补 UI seam/source guardrail 覆盖。

## 5. 迁移 ImageCompressionSettingsScreen

- [x] 5.1 将 `ImageCompressionSettingsScreen` 外层 `Scaffold` / transparent `AppBar` / page-local background 迁移到 `SettingsPage` 或 approved settings page seam。
- [x] 5.2 将 enable row、mode/output select rows、lossless/metadata/skip toggles、resize controls、quality/size stepper rows、warning/info rows 和 actions 迁移到 settings semantic components。
- [x] 5.3 保留 `imageCompressionSettingsProvider` owner、mode/output selection、lossless warning、resize enablement、quality/dimension/size stepper、metadata 和 skip behavior。
- [x] 5.4 移除或替换图片压缩页面中的 `_ToggleCard`、`_Group`、`_SwitchRow`、`_StepperRow`、`_SelectMenuRow` 等可复用私有视觉组件。
- [x] 5.5 增加或更新 focused widget tests，覆盖图片压缩 enable toggle、mode/output selection、resize controls、lossless warning 和 stepper 行为。

## 6. Guardrails 与边界保护

- [x] 6.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `settings_screen.dart`、`image_bed_settings_screen.dart`、`image_compression_settings_screen.dart` 移出 legacy allowlist 并加入 migrated coverage。
- [x] 6.2 如迁移后仍存在必要的 page-specific palette/style exception，为 exception 添加极窄 allowance 和注释，避免宽泛放行。
- [x] 6.3 确认 migrated files 不新增 `state -> features`、`application -> features`、`core -> higher layer` 依赖，也不把 reusable settings UI 逻辑下沉到 state/application/core/data。
- [x] 6.4 检查 touched public settings files 不包含 subscription、billing、entitlement、StoreKit、receipt、paywall、product ID、private overlay 或 `AccessDecision.source` business branching。
- [x] 6.5 记录未迁移的 remaining settings pages 仍在 legacy allowlist，尤其是 `WebDavSyncScreen`、`AiSettingsScreen`、`PasswordLockScreen` 和 `DesktopSettingsWindowApp`。

## 7. 验证

- [x] 7.1 在 `memos_flutter_app` 运行 focused settings tests：`flutter test test/features/settings/settings_screen_test.dart test/features/settings/platform_adaptive_settings_test.dart`。
- [x] 7.2 在 `memos_flutter_app` 运行新增或更新的图床/图片压缩 focused tests。
- [x] 7.3 在 `memos_flutter_app` 运行 architecture guardrail：`flutter test test/architecture/settings_ui_drift_guardrail_test.dart`，必要时运行 `modularity_dependency_guardrail_test.dart`。
- [x] 7.4 在 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 7.5 在 `memos_flutter_app` 运行 `flutter test`，或记录环境/时间 blocker 与已运行的 focused coverage。（已运行；完整 suite 因 `test/private_hooks/app_ready_hook_test.dart` 的独立 dispose/ref lifecycle 问题未全绿，已运行 focused coverage。）
- [x] 7.6 运行 `openspec validate continue-settings-ui-unification --strict`。
