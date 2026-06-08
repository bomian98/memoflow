## ADDED Requirements

### Requirement: macOS application activation SHALL restore the main window

macOS 主应用实例在 close-to-menu-bar hidden state、Dock reopen、菜单栏打开 MemoFlow、或 application-owned activation seam 被调用时，系统 SHALL 恢复并聚焦主 `MainFlutterWindow`。该恢复行为 SHALL NOT 依赖 feature UI 直接调用窗口 API，也 SHALL NOT 遍历并恢复所有 `desktop_multi_window` 子窗口。

#### Scenario: Dock icon restores hidden main window
- **GIVEN** macOS 主窗口已隐藏到菜单栏或无可见窗口
- **WHEN** 用户点击 Dock 中的 MemoFlow 图标
- **THEN** Runner SHALL restore only the main Flutter window
- **AND** 系统 SHALL activate app and bring the main window to front
- **AND** 已关闭或隐藏的 quick input/settings/share sub-window SHALL NOT be reopened as part of Dock reopen

#### Scenario: Dock icon restores main window when only sub-windows are visible
- **GIVEN** macOS 主窗口不可见
- **AND** 系统仍认为存在 visible window because of a sub-window or native transient surface
- **WHEN** 用户点击 Dock 中的 MemoFlow 图标
- **THEN** Runner SHALL still restore the main Flutter window
- **AND** it SHALL NOT skip restore only because `hasVisibleWindows` is true

#### Scenario: Application activation seam supports macOS
- **WHEN** `DesktopExitCoordinator.activateMainWindow()` is invoked on macOS
- **THEN** it SHALL ensure the main window manager is initialized
- **AND** it SHALL restore minimized state when needed
- **AND** it SHALL show and focus the main window
- **AND** it SHALL NOT return early only because the platform is not Windows
