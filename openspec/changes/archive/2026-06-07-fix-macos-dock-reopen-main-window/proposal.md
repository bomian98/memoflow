# Why

macOS 上关闭主窗口到菜单栏后，点击 Dock 中的软件图标可能只激活菜单栏状态，而没有恢复主窗口。日志中还出现 stale sub-window lifecycle 与 keyboard state assertion，说明当前 reopen/activate 路径没有稳定地区分主窗口恢复与子窗口生命周期。

现有 `DesktopExitCoordinator.activateMainWindow()` 只处理 Windows，导致单实例激活或需要恢复主窗口的 application seam 在 macOS 上直接返回。原生 `applicationShouldHandleReopen` 也遍历 `NSApp.windows`，会尝试恢复所有不可见窗口，容易把已经关闭或释放中的 `desktop_multi_window` 子窗口带入无效 engine/window 状态。

# What Changes

- 让 application-owned desktop lifecycle seam 支持 macOS 主窗口激活恢复。
- 调整 macOS Runner 的 Dock reopen 行为，只恢复主 `MainFlutterWindow`，并使用 native main-window order/front activation。
- 增加 focused tests/guardrails，覆盖 macOS activation 不再是 Windows-only，且 reopen 不再遍历所有窗口。
- 保持 quick input/settings/share 子窗口生命周期、API 层、私有扩展 seam 和商业能力边界不变。

# Impact

- 涉及 `memos_flutter_app/lib/application/desktop/desktop_exit_coordinator.dart`。
- 涉及 `memos_flutter_app/macos/Runner/AppDelegate.swift`。
- 涉及 desktop lifecycle focused tests 与 macOS public shell guardrail。
- 不修改 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`。
