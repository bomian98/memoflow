## ADDED Requirements

### Requirement: Draft Box desktop navigation SHALL render in Home primary content
草稿箱从桌面 Home 导航入口打开时 SHALL 显示在 Home shell 的 primary content 区域。该区域是 sidebar 右侧、顶部全局操作栏下方的主内容区域；实现 SHALL 保留 Home 的左侧本地库导航、desktop titlebar / command bar、全局搜索/操作和窗口控件。桌面导航型草稿箱 SHALL NOT 创建独立 `DesktopDestinationShell`、`DraftBoxNavigationScreen` 或新的顶层页面壳。

#### Scenario: Sidebar Draft Box opens inside Home primary content
- **WHEN** the user opens Draft Box from the Home sidebar on macOS, Windows, or Linux desktop
- **THEN** the current Home shell SHALL remain visible
- **AND** the Local Library sidebar SHALL remain visible with Draft Box selected
- **AND** the desktop titlebar / command bar global actions SHALL remain visible
- **AND** Draft Box content SHALL render in the primary content area to the right of the sidebar
- **AND** Draft Box SHALL NOT replace the whole window with an independent desktop destination shell

#### Scenario: Home root Draft Box uses the same desktop utility route
- **WHEN** a desktop Home root destination resolves `HomeRootDestination.draftBox`
- **THEN** it SHALL build a `MemosListScreen` with `initialDesktopUtilityView: DesktopHomeUtilityView.draftBox`
- **AND** the resulting screen SHALL use the Home primary content override to show Draft Box

#### Scenario: macOS menu Draft Box uses the same Home shell
- **WHEN** the user invokes the macOS Draft Box menu command
- **THEN** the app SHALL open the Home shell with drawer/sidebar and desktop compose capabilities enabled
- **AND** it SHALL activate `DesktopHomeUtilityView.draftBox`
- **AND** it SHALL NOT route to a standalone Draft Box desktop page

#### Scenario: Inline compose toolbar Draft Box opens inside current Home primary content
- **WHEN** the user opens Draft Box from the inline compose toolbar on macOS, Windows, or Linux desktop Home
- **THEN** the current Home shell SHALL remain visible
- **AND** the Local Library sidebar SHALL remain visible
- **AND** the desktop titlebar / command bar global actions SHALL remain visible
- **AND** Draft Box content SHALL replace only the Home primary content area to the right of the sidebar
- **AND** the inline toolbar action SHALL NOT push `DraftBoxScreen.show()`, `DraftBoxNavigationScreen`, or a new top-level `MemosListScreen` route when the current Home can host the utility view

#### Scenario: Embedded Draft Box returns to primary destination
- **WHEN** Draft Box is shown as `HomeScreenPresentation.desktopEmbedded`
- **THEN** it SHALL render inside `DesktopEmbeddedUtilitySurface`
- **AND** activating the embedded back affordance SHALL clear the active desktop utility view and reveal the normal memo primary content

#### Scenario: Draft selector remains a task route
- **WHEN** the user opens Draft Box through `DraftBoxScreen.show()` from a non-Home desktop compose surface or mobile compose surface
- **THEN** the Draft Box selector MAY use its own task header / route chrome
- **AND** selecting a create draft SHALL still return that draft selection to the compose caller
- **AND** selecting an edit draft SHALL preserve the existing edit-draft handling behavior for that caller

#### Scenario: Mobile Draft Box keeps AppBar chrome
- **WHEN** Draft Box is rendered on a mobile platform
- **THEN** it SHALL keep the existing `DraftBoxNavigationScreen` and Scaffold/AppBar behavior
- **AND** it SHALL NOT use `DesktopHomeUtilityView.draftBox`
