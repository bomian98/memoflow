## 1. 范围确认与复现基线

- [x] 1.1 确认本 change 只影响桌面首页 resizable inline compose 布局，不修改附件选择、staging、压缩、上传、API、数据库、同步、private hooks 或商业逻辑。
- [x] 1.2 在代码中记录当前失败路径：`MemosListInlineComposeCard` 的 `_InlineAttachmentPreview` 增加约 72px editor 外高度，而 `DesktopResizablePanelShell` tight height 让现有 `totalHeight - editorViewportHeight` 无法稳定反映真实 chrome 需求。
- [x] 1.3 用现有测试或临时本地复现确认 Windows/macOS supported desktop + saved `homeInlineComposePanelLayout.editorHeight` + pending attachment 会触发或可解释为 bottom overflow；不得提交临时调试代码。

## 2. Layout metrics seam

- [x] 2.1 调整 `InlineComposeLayoutMetrics` 或等价 metrics seam，使其能够表达不受 tight parent 截断的 editor viewport height 与 dynamic chrome height / desired total height。
- [x] 2.2 在 `MemosListInlineComposeCard` 内集中计算或测量 attachment preview、linked memo、location、toolbar、padding 等 editor 外 chrome，避免在 `memos_list_screen.dart` 复制附件 tile 高度常量。
- [x] 2.3 保持 `desktopEditorViewportHeight` 下 `PlatformTextField.expands == true`，并确保 editor viewport 高度仍等于父级传入的 `editorHeight`。
- [x] 2.4 保持非 resizable inline compose、移动 `NoteInputSheet` 和 fullscreen compose 的现有布局路径不受影响。

## 3. 父级 resizable panel 集成

- [x] 3.1 更新 `memos_list_screen.dart` 的 `_handleHomeInlineLayoutMetrics` / panel rect 构造逻辑，使用最新 chrome height 计算 `panelHeight = chromeHeight + editorHeight`。
- [x] 3.2 添加附件、删除附件、linked memo 和 location 状态变化时，面板高度 SHALL 自动更新，并在 available viewport 内 clamp。
- [x] 3.3 保持 `homeInlineComposePanelLayout.editorHeight` 持久化语义不变；resize drag 结束后仍只保存 width、editorHeight、xRatio、yRatio。
- [x] 3.4 避免引入新的 `application -> features`、`state -> features` 或 `core -> higher-layer` imports；如需要 helper，应放在现有 feature-owned seam 或 feature-agnostic application seam。

## 4. 测试与 guardrail

- [x] 4.1 更新 `memos_flutter_app/test/features/memos/widgets/memos_list_inline_compose_card_test.dart` 或 `memos_flutter_app/test/features/memos/memos_list_inline_compose_card_test.dart`，覆盖受控 `desktopEditorViewportHeight` + pending attachment 的 metrics，断言 attachment chrome 计入 desired height。
- [x] 4.2 更新 `memos_flutter_app/test/features/memos/memos_list_screen_test.dart`，覆盖 Windows desktop resizable home inline compose 加 pending attachment 后无 Flutter overflow，且 `DesktopResizablePanelShell.rect.height` 足以容纳 editor + chrome。
- [x] 4.3 增加删除附件或 attachment list 变空后的回归断言，确认 chrome height 不会卡在错误状态，工具栏和发送按钮仍可见、可点击。
- [x] 4.4 如触及 `DesktopResizablePanelShell` contract，更新 `memos_flutter_app/test/application/desktop/desktop_resizable_panel_shell_test.dart`，确认 bounds / hit-test 行为不回退。

## 5. 验证与收尾

- [x] 5.1 从 `memos_flutter_app` 运行 `dart format` 覆盖所有修改过的 Dart 测试和实现文件。
- [x] 5.2 从 `memos_flutter_app` 运行 focused tests：inline compose card tests、memos list screen desktop resize tests、必要的 desktop panel shell tests。
- [x] 5.3 从 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 5.4 从 `memos_flutter_app` 运行 `flutter test`；若环境或既有失败阻塞，记录具体命令、失败用例和与本 change 的关系。
- [x] 5.5 在 Windows 或 macOS desktop 手动检查：添加图片/普通文件/视频后输入卡片无黄黑 overflow、附件预览可删除、工具栏和发送按钮可操作，拖拽 resize 后布局仍可恢复。

### 5.4 验证记录

- `flutter test` 已运行；full suite 被 4 个既有/无关失败阻塞，失败不在本 change 修改范围内：
  - `test/private_hooks/app_ready_hook_test.dart` 的 `App notifies private bundle when app is ready`：`DesktopQuickInputController.unregisterHotKey` 在 `App.dispose` 后读 `ref`。
  - `test/features/home/home_bottom_nav_shell_test.dart` 的 `opening about from shell preserves bottom navigation on back`：About 页面相关 `RenderFlex` bottom overflow 157px。
  - `test/features/home/home_bottom_nav_shell_test.dart` 的 `standalone about back returns to HomeEntryScreen shell`：同一 About 页面相关 `RenderFlex` bottom overflow 157px。
  - `test/features/onboarding/platform_adaptive_onboarding_test.dart` 的 `local workspace setup keeps mobile actions full width`：期望宽度 `358`，实际 `326.0`。
