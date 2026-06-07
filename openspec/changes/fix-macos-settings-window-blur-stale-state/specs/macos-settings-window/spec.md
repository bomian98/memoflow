## ADDED Requirements

### Requirement: Settings sub-window visibility SHALL clear main-window blur

macOS 设置子窗口关闭、隐藏或失效后，系统 SHALL 及时清理主窗口记录的可见子窗口状态，并 SHALL 自动移除主窗口模糊遮罩。用户 SHALL NOT need to click the home page or another main-window surface to recover from stale blur.

#### Scenario: Settings window closes through in-window close action

- **WHEN** 用户在 macOS 设置窗口内触发关闭动作
- **THEN** 设置窗口 SHALL report `desktop.subWindow.visibility` with `visible=false` to the main window before or during hide
- **AND** the main window SHALL remove that sub-window id from its visible set
- **AND** the main window SHALL stop rendering the blur overlay without requiring an additional home-page click

#### Scenario: Settings window closes through native macOS close

- **WHEN** 用户通过 macOS 原生红色关闭按钮或 `Cmd+W` 关闭设置子窗口
- **THEN** the main window SHALL reconcile tracked sub-window visibility against the current `desktop_multi_window` sub-window id list or equivalent visibility query
- **AND** stale settings sub-window ids SHALL be removed
- **AND** the main window SHALL stop rendering the blur overlay without requiring an additional home-page click

#### Scenario: Hidden settings window is not resurrected by blur overlay click

- **GIVEN** the main window still has a tracked settings sub-window id
- **AND** that settings sub-window is no longer visible
- **WHEN** 用户点击主窗口模糊遮罩
- **THEN** the system SHALL clear the stale visibility tracking for that id
- **AND** it SHALL NOT re-show the hidden settings window merely because the blur overlay was clicked

### Requirement: Settings visibility sync SHALL preserve desktop boundaries

设置窗口可见性同步 SHALL remain owned by desktop lifecycle/application seams and SHALL NOT introduce new architecture boundary regressions, private commercial behavior, or macOS sub-window plugin violations.

#### Scenario: Visibility reconciliation is implemented

- **WHEN** settings sub-window visibility reconciliation is added or changed
- **THEN** `application/desktop` SHALL NOT add new imports from `features/*`
- **AND** `core` SHALL NOT add new imports from `state`, `application`, or `features`
- **AND** `app.dart` SHALL continue to delegate sub-window visibility state to `DesktopWindowManager` or an equivalent application-owned seam

#### Scenario: macOS settings sub-window plugin boundary is preserved

- **WHEN** the macOS settings sub-window reports close, hide, focus, ping, or visibility state
- **THEN** it SHALL NOT require registering `WindowManagerPlugin` into the settings sub-window Flutter engine
- **AND** it SHALL NOT call `window_manager` APIs that depend on the plugin's `mainWindow`

#### Scenario: Public settings window lifecycle remains commercial-free

- **WHEN** settings window lifecycle or blur recovery code is added or changed
- **THEN** it MUST NOT include subscription, billing, entitlement, receipt, paywall, StoreKit, private overlay, paid-feature branching, App Store Connect, signing secret, notarization, TestFlight, or private release automation logic
