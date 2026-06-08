# Implementation Notes

本 change 修复 macOS 主窗口隐藏后 Dock 点击只激活菜单栏、不恢复窗口的问题。

## Changed

- `DesktopExitCoordinator.activateMainWindow()` 不再是 Windows-only；macOS 会通过 application-owned lifecycle seam 执行 `windowManager.ensureInitialized()`、必要的 `restore()`、`show()` 和 `focus()`。
- `AppDelegate.applicationShouldHandleReopen` 改为恢复 `MainFlutterWindow`，不再遍历并恢复所有 `NSApp.windows`。
- Dock reopen 现在在 `hasVisibleWindows == true` 但主窗口不可见时仍恢复主窗口，避免可见子窗口或 transient surface 让主窗口恢复被跳过。
- 增加 focused lifecycle test 和 macOS public shell guardrail，保护 macOS activation 与主窗口专用 reopen 行为。

## Verified

- `dart format lib/application/desktop/desktop_exit_coordinator.dart test/application/desktop/desktop_exit_coordinator_test.dart test/architecture/macos_public_shell_guardrail_test.dart`
- `flutter test test/application/desktop/desktop_exit_coordinator_test.dart test/architecture/macos_public_shell_guardrail_test.dart --reporter expanded`
- `openspec validate fix-macos-dock-reopen-main-window --strict`
- `flutter analyze`
- `flutter build macos --debug --flavor Runner` passed；输出包含既有 Pods deployment target / PrivacyInfo.xcprivacy 处理 warning。

## Notes

- 本 change 未修改 API adapter、request/response model、version compatibility logic 或 `memos_flutter_app/lib/data/api` / `memos_flutter_app/test/data/api`。
- 日志中的 Flutter `HardwareKeyboard` assertion 未在本 change 中直接修改；本修复通过稳定主窗口恢复和避免 stale sub-window restore 降低触发窗口，但不改 Flutter framework/engine key event 模型。
