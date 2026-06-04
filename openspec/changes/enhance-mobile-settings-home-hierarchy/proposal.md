## Why

当前设置首页在手机端已经使用统一的 settings row/section surface tokens，但功能入口之间的视觉层级仍偏平：头像入口、三个快捷入口、功能分组和单行入口都主要依赖边框与间距区分。用户提供的手机端效果图希望设置首页更像分层功能面板，让各个功能选项通过独立卡片、分组卡片、轻阴影、圆角和分隔线直接被区分开。

本 change 聚焦“设置首页的手机端功能入口层次感”，不重新定义全 app 按钮颜色，也不重做二级、三级设置页的业务结构。

## What Changes

- 为手机端设置首页定义 home-specific visual hierarchy：页面背景、profile card、quick shortcut tiles、grouped function sections、single-row section 的背景、圆角、阴影、间距和分割线。
- 扩展 settings-owned UI seam/token，使设置首页的卡片层级仍由 `settings_ui.dart`、`settingsPageTokens` 或 approved settings/platform seam 统一解析，避免在 `settings_screen.dart` 中散落 page-local card/shadow/color 硬编码。
- 手机端设置首页的三枚快捷入口使用独立功能卡片表现；普通功能入口继续使用 grouped section + row divider 模型，而不是每一行都拆成独立卡片。
- 桌面端和二级/三级设置页保持克制、信息密度优先的设置表单风格，只继承必要的 token，不强制套用手机端重阴影卡片视觉。
- 保留例外：头像图片、主题色/颜色预览、危险/错误操作、系统/native picker、媒体 overlay、窗口控制、真正按钮主题不属于本 change 的统一对象。
- 增加或更新 focused widget tests / drift guardrail，保护设置首页 mobile hierarchy，防止后续把功能入口视觉重新写回局部硬编码。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `platform-adaptive-ui-system`: 增加设置首页在手机端 SHALL 使用 settings-owned hierarchy tokens/seams 表达 profile、shortcut tile、function section 和 single-row section 层级的要求，并明确桌面和二级/三级页不被强制套用手机端卡片视觉。

## Impact

- 主要影响 `memos_flutter_app/lib/features/settings/settings_ui.dart` 和 `memos_flutter_app/lib/features/settings/settings_screen.dart` 的设置首页 presentation seam。
- 可能影响 `memos_flutter_app/test/features/settings/settings_screen_test.dart`、`memos_flutter_app/test/features/settings/settings_ui_semantic_components_test.dart` 和 `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`。
- 不修改 API、数据模型、数据库、同步协议、WebDAV、AI provider 业务逻辑、private/commercial hooks 或全 app button theme。
- 当前架构阶段是 `evolve_modularity`。本 change 触及 settings UI 这一耦合热点，需要通过集中 mobile settings home hierarchy tokens/seams 和 guardrail，让 touched area 至少不变差，并避免新增 `state -> features`、`application -> features`、`core -> features` 或 `platform -> features` 依赖。
