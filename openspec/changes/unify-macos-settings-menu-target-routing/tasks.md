## 1. 扫描和分类

- [ ] 1.1 扫描 `app.dart`、`AppDelegate.swift`、`settings_screen.dart`、`desktop_settings_window_app.dart`、`components_settings_screen.dart`、`preferences_settings_screen.dart` 和桌面设置页中的 settings-like route 入口。
- [ ] 1.2 形成候选清单，将每个 macOS menu command 分类为 `settings target`、`task surface candidate` 或 `business/tool page`。
- [ ] 1.3 标记与 `generalize-desktop-settings-platform-sections` 重叠的桌面设置/快捷键入口，并决定实施顺序。
- [ ] 1.4 确认本 change 不修改 API、数据库 schema、同步协议或商业/private overlay 行为。

## 2. Target Routing 扩展

- [ ] 2.1 在 `DesktopSettingsWindowTarget` 或等价结构中增加批量迁移所需的 settings targets。
- [ ] 2.2 支持 pane 内 nested target，例如 components/template、components/location、preferences/memoToolbar。
- [ ] 2.3 让 `DesktopSettingsWindowApp` 根据 target 选择 pane 并在 pane navigator 中打开目标页面。
- [ ] 2.4 保持 target-to-widget mapping 在 settings window UI composition 中，避免 `application` 或 `core` 新增 feature UI imports。

## 3. macOS 菜单迁移

- [ ] 3.1 将 `macosMenuCommandAiProvider` 迁移到 settings window target 或记录为需要确认后暂缓。
- [ ] 3.2 将 `macosMenuCommandShortcutSettings` 迁移到桌面设置/快捷键 target，并与桌面设置平台分段 change 保持一致。
- [ ] 3.3 将 `macosMenuCommandTemplateSettings` 迁移到 components/template target。
- [ ] 3.4 将 `macosMenuCommandMemoToolbarSettings` 迁移到 preferences/memoToolbar target。
- [ ] 3.5 将 `macosMenuCommandLocationSettings`、`macosMenuCommandImageBedSettings`、`macosMenuCommandImageCompression` 迁移到 components nested targets。
- [ ] 3.6 保持 `AI Summary`、`AI Reports`、`Quick Prompts`、`Self Repair`、`Export Diagnostics`、导入导出和迁移类命令不纳入 settings window target routing。
- [ ] 3.7 为每个迁移项保留 unsupported / failed fallback 到原页面。

## 4. Guardrails And Tests

- [ ] 4.1 增加 settings window target tests，覆盖至少一个顶层 pane target 和一个 pane nested target。
- [ ] 4.2 增加 macOS menu focused tests 或 guardrail，确认已迁移 settings-like commands 主路径使用 target settings window。
- [ ] 4.3 增加扫描清单或 implementation note，记录哪些 commands 被迁移、暂缓或保持普通 route，以及理由。
- [ ] 4.4 检查 touched public files 不包含商业、订阅、付费、StoreKit、entitlement、private overlay 或 `AccessDecision.source` 业务分支。

## 5. 验证

- [ ] 5.1 运行 macOS menu / settings window focused tests。
- [ ] 5.2 运行相关 architecture guardrail tests。
- [ ] 5.3 从 `memos_flutter_app` 运行 `flutter analyze`。
- [ ] 5.4 运行 `flutter test` 或记录环境 blocker。
- [ ] 5.5 运行 `openspec validate unify-macos-settings-menu-target-routing --strict`。
- [ ] 5.6 在 macOS 手动 smoke 已迁移 settings-like menu commands：窗口聚焦、pane/nested route、返回、失败 fallback。
