# Context

macOS close-to-menu-bar 设计中，主窗口 close request 可隐藏到菜单栏，后续菜单栏或 Dock 激活应恢复同一个主窗口。当前 Dart 激活入口 `DesktopExitCoordinator.activateMainWindow()` 只在 Windows 平台执行，macOS 会提前 return；而 Runner 的 `applicationShouldHandleReopen` 对所有 `NSApp.windows` 做 `makeKeyAndOrderFront`，没有限定主窗口。

这两个问题叠加时，用户点击 Dock 图标后可能只看到应用菜单栏切到 MemoFlow，但主窗口没有恢复。若同时存在已隐藏、已关闭或释放中的多窗口插件子窗口，遍历全部窗口还会增加 stale engine/window channel 噪声。

# Decisions

## Decision 1: 激活恢复由 `DesktopExitCoordinator` 覆盖 Windows 和 macOS

`DesktopExitCoordinator.activateMainWindow()` 仍作为 application-owned desktop lifecycle seam。实现上 Windows 继续保留 setSkipTaskbar/show/focus 行为；macOS 通过 `windowManager.ensureInitialized()`、必要的 `restore()`、`show()`、`focus()` 恢复主窗口。

Rationale: 这样单实例激活、菜单栏恢复和后续需要主窗口的 application command 能复用同一个 seam，不把主窗口恢复逻辑放回 feature UI。

## Decision 2: Dock reopen 只恢复主 `MainFlutterWindow`

Runner 增加一个小的 `restoreMainWindow` helper，优先使用 `sender.mainWindow`，并确认窗口是 `MainFlutterWindow`。`applicationShouldHandleReopen` 在无可见窗口时调用该 helper，而不是遍历全部 `NSApp.windows`。

Rationale: `desktop_multi_window` 子窗口有自己的 engine 和 channel 生命周期。Dock reopen 的用户意图是恢复主应用窗口，不应重新 order 已关闭或 hidden 的 task sub-window。

## Decision 3: 不在本 change 处理 Flutter `HardwareKeyboard` bug

日志中的 `HardwareKeyboard` assertion 很可能由系统热键/窗口切换时的重复 keydown 或 stale engine key state 触发。本 change 通过稳定主窗口/子窗口生命周期降低触发概率，但不修改 Flutter engine 或测试模拟事件模型。

# Risks

- macOS `windowManager.focus()` 使用 `NSApp.activate(ignoringOtherApps: false)`；因此先调用 `show()`，保留插件内部的 front/activate 行为，再调用 `focus()`。
- Runner helper 如果找不到 `MainFlutterWindow`，会退回 `sender.mainWindow`；这比遍历所有窗口风险更低，但仍保持 Dock 点击可恢复可用窗口。
