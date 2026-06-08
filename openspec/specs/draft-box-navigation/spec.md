# draft-box-navigation Specification

## Purpose
Define Draft Box navigation entry behavior across the sidebar and configurable bottom navigation, including selected-draft edit launch and architecture boundaries.
## Requirements
### Requirement: Draft Box appears as a sidebar destination
The app navigation SHALL expose Draft Box as a sidebar destination by default, and SHALL allow the user to hide or show that sidebar entry from the existing sidebar customization settings.

#### Scenario: Sidebar shows Draft Box by default
- **WHEN** the sidebar renders with default workspace preferences
- **THEN** it includes a Draft Box destination entry
- **AND** the entry uses the localized Draft Box label

#### Scenario: Sidebar customization can hide Draft Box
- **GIVEN** the user opens Laboratory > Customize Sidebar
- **WHEN** the user disables the Draft Box toggle
- **THEN** the workspace sidebar preferences persist Draft Box as hidden
- **AND** the sidebar no longer displays the Draft Box destination entry

#### Scenario: Sidebar customization can show Draft Box again
- **GIVEN** the Draft Box sidebar entry is hidden
- **WHEN** the user enables the Draft Box toggle in Laboratory > Customize Sidebar
- **THEN** the workspace sidebar preferences persist Draft Box as visible
- **AND** the sidebar displays the Draft Box destination entry again

### Requirement: Draft Box can be selected for bottom navigation slots
The bottom navigation configuration SHALL include Draft Box as a selectable home root destination without making it a default slot.

#### Scenario: Bottom navigation destination picker lists Draft Box
- **WHEN** the user opens the bottom navigation slot picker
- **THEN** Draft Box appears as a selectable destination
- **AND** the option uses the localized Draft Box label and the registered Draft Box icon

#### Scenario: Bottom navigation can open Draft Box
- **GIVEN** a bottom navigation slot is configured as Draft Box
- **WHEN** the user taps that bottom navigation item
- **THEN** the app displays the Draft Box screen inside the active home navigation flow
- **AND** the bottom navigation shell remains the active home navigation shell

#### Scenario: Draft Box is not assigned by default
- **WHEN** a workspace uses default home navigation preferences
- **THEN** Draft Box is not assigned to any bottom navigation slot by default
- **AND** the default visible bottom navigation destinations remain unchanged

### Requirement: Navigation-launched Draft Box opens selected drafts for editing
When Draft Box is opened from app navigation, selecting a draft SHALL open the appropriate editor for that draft type. Create drafts SHALL open the note input editor with that create draft restored. Sent memo edit drafts SHALL open the existing memo editor for the bound original memo with the edit draft restored.

#### Scenario: Sidebar Draft Box selection opens create draft editor
- **GIVEN** the user opens Draft Box from the sidebar
- **AND** draft A is a create draft
- **WHEN** the user taps draft A
- **THEN** the app opens the note input editor
- **AND** the editor restores draft A for editing

#### Scenario: Sidebar Draft Box selection opens sent memo edit draft editor
- **GIVEN** the user opens Draft Box from the sidebar
- **AND** draft A is an edit draft bound to an existing sent memo
- **WHEN** the user taps draft A
- **THEN** the app opens the existing memo editor for the bound memo
- **AND** the editor restores draft A for editing

#### Scenario: Bottom navigation Draft Box selection opens create draft editor
- **GIVEN** the user opens Draft Box from a bottom navigation destination
- **AND** draft A is a create draft
- **WHEN** the user taps draft A
- **THEN** the app opens the note input editor
- **AND** the editor restores draft A for editing

#### Scenario: Bottom navigation Draft Box selection opens sent memo edit draft editor
- **GIVEN** the user opens Draft Box from a bottom navigation destination
- **AND** draft A is an edit draft bound to an existing sent memo
- **WHEN** the user taps draft A
- **THEN** the app opens the existing memo editor for the bound memo
- **AND** the editor restores draft A for editing

#### Scenario: Navigation Draft Box refreshes after create draft editor close
- **GIVEN** the user opens Draft Box from app navigation
- **AND** the user taps create draft A and edits its content
- **WHEN** the user exits the note input editor without submitting
- **THEN** Draft Box displays draft A with the latest saved draft content
- **AND** the user does not need to leave and re-enter Draft Box to see the update

#### Scenario: Navigation Draft Box refreshes after edit draft editor close
- **GIVEN** the user opens Draft Box from app navigation
- **AND** the user taps edit draft A and edits its content
- **WHEN** the user exits the existing memo editor by adding the edit to Draft Box again
- **THEN** Draft Box displays draft A with the latest saved edit draft content
- **AND** Draft Box does not create a duplicate edit draft for the same original memo

#### Scenario: Empty Draft Box remains viewable from navigation
- **GIVEN** the user opens Draft Box from app navigation
- **WHEN** there are no saved drafts
- **THEN** the app displays the existing empty Draft Box state
- **AND** no note input editor or memo editor is opened automatically

### Requirement: Draft Box navigation preserves architecture boundaries
Draft Box navigation SHALL use existing navigation registry, preference provider, typed draft selection, and editor restoration seams. It MUST NOT introduce new reverse dependencies from `state` to `features`, from `application` to `features`, or from `core` to higher layers.

#### Scenario: Navigation uses destination registry seams
- **WHEN** Draft Box is added to sidebar and bottom navigation
- **THEN** the implementation routes through the existing drawer and home root destination seams
- **AND** destination metadata remains centralized with the other home root destinations

#### Scenario: Create draft restoration remains owned by note input
- **WHEN** a navigation-launched Draft Box returns a selected create draft
- **THEN** navigation code delegates create draft restoration to the note input entry point
- **AND** navigation code does not duplicate `ComposeDraftSnapshot` restoration logic for create drafts

#### Scenario: Edit draft restoration remains owned by memo editor draft seams
- **WHEN** a navigation-launched Draft Box returns a selected sent memo edit draft
- **THEN** navigation code delegates edit draft restoration to the existing memo editor entry point and edit draft helper seams
- **AND** lower layers do not import Draft Box or memo editor presentation widgets to perform routing

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

