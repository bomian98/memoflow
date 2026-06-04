## 手动验收记录

- 2026-06-03：用户反馈 macOS close-to-menu-bar 验收未通过。
- 已通过部分：右上角菜单栏图标里的退出可以正常退出。
- 失败部分：打开窗口后，左上角 App 菜单 `MemoFlow > Quit` 无法退出 App，会被 close-to-menu-bar 路径拦截。
- 本轮修复：将 macOS App 菜单 Quit 从 native `NSApplication.terminate(_)` 改为显式 `quit` menu command，由 Flutter 调用 `DesktopExitCoordinator.requestExit(reason: 'macos_app_menu_quit')`，绕过普通 close-to-menu-bar 策略并复用完整退出清理。
- 2026-06-03：用户复测确认左上角 App 菜单退出已可正常退出。
- 当前状态：`Cmd+Q`、App 菜单 Quit、菜单栏状态图标退出与 close-to-menu-bar 手动 smoke 已通过。
