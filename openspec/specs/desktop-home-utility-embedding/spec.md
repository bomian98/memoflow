# desktop-home-utility-embedding Specification

## Purpose
TBD - created by archiving change embed-desktop-utility-pages-in-home. Update Purpose after archive.
## Requirements
### Requirement: Desktop home SHALL embed utility views in the primary content column

When sync queue or notifications are opened from the desktop homepage shell, the app SHALL render the selected utility view inside the homepage primary content column instead of navigating to a standalone secondary page.

#### Scenario: Desktop user opens sync queue from home
- **GIVEN** the user is on the desktop homepage shell
- **WHEN** the user opens the sync queue from a drawer quick action, titlebar-adjacent action, or sync-status retry entry
- **THEN** the homepage primary content column SHALL show sync queue content
- **AND** the memo inline compose and memo list content SHALL be replaced while the sync queue utility view is active
- **AND** the desktop window titlebar / chrome SHALL remain owned by the homepage shell
- **AND** the sync queue local title SHALL expose a back affordance that returns the primary content column to the memo list.

#### Scenario: Desktop user opens notifications from home
- **GIVEN** the user is on the desktop homepage shell
- **WHEN** the user opens notifications from the drawer quick action or titlebar action
- **THEN** the homepage primary content column SHALL show notifications content
- **AND** the memo inline compose and memo list content SHALL be replaced while the notifications utility view is active
- **AND** the desktop window titlebar / chrome SHALL remain owned by the homepage shell
- **AND** the notifications local title SHALL expose a back affordance that returns the primary content column to the memo list.

#### Scenario: Desktop user opens utility view from another drawer page
- **GIVEN** the user is on a desktop drawer page other than all memos, such as explore, stats, tags, resources, recycle bin, settings, or about
- **WHEN** the user opens sync queue or notifications from that page's drawer chrome
- **THEN** the app SHALL return to the desktop homepage shell
- **AND** the homepage primary content column SHALL show the requested utility view
- **AND** the app SHALL NOT open a standalone sync queue or notifications route for that desktop drawer action.

### Requirement: Embedded utility views SHALL clear drawer selection

Desktop homepage utility views SHALL NOT highlight a primary drawer destination while active.

#### Scenario: Sync queue utility view is active
- **WHEN** the desktop homepage primary content column shows the sync queue utility view
- **THEN** the drawer selected destination SHALL be empty
- **AND** the selected tag path SHALL be empty.

#### Scenario: Notifications utility view is active
- **WHEN** the desktop homepage primary content column shows the notifications utility view
- **THEN** the drawer selected destination SHALL be empty
- **AND** the selected tag path SHALL be empty.

### Requirement: Mobile and standalone routes SHALL keep existing behavior

Embedding sync queue and notifications in the homepage primary column SHALL be limited to desktop homepage contexts.

#### Scenario: Mobile user opens sync queue or notifications
- **WHEN** the user opens sync queue or notifications on a mobile or tablet bottom-navigation surface
- **THEN** the app SHALL preserve the existing standalone or embeddedBottomNav navigation behavior
- **AND** it SHALL NOT replace the memo list primary content column via the desktop utility view state.

#### Scenario: Standalone route is opened outside desktop home
- **WHEN** `SyncQueueScreen` or `NotificationsScreen` is opened outside the desktop homepage shell
- **THEN** the screen SHALL preserve its existing standalone title, navigation, actions, and body behavior.

### Requirement: Embedded utility content SHALL NOT own top-level titlebar chrome

Embedded sync queue and notifications content SHALL render business content and local actions only, while delegating desktop titlebar and window-control avoidance to the homepage shell.

#### Scenario: Utility content is embedded in desktop home
- **WHEN** sync queue or notifications content is rendered inside the homepage primary content column
- **THEN** it SHALL NOT render a standalone `PlatformPage`, `DesktopShellHost`, `Scaffold.appBar`, or route-level Back affordance as the top-level titlebar owner
- **AND** it SHALL NOT encode macOS traffic-light or caption-control padding locally.

### Requirement: Embedded utility back SHALL clear utility state

Desktop embedded sync queue and notifications back affordances SHALL be local content navigation, not window or route dismissal.

#### Scenario: User returns from sync queue utility view
- **GIVEN** the desktop homepage primary content column shows the sync queue utility view
- **WHEN** the user activates the local back affordance
- **THEN** the utility view state SHALL be cleared
- **AND** the primary content column SHALL show the memo list and inline compose area again.

#### Scenario: User returns from notifications utility view
- **GIVEN** the desktop homepage primary content column shows the notifications utility view
- **WHEN** the user activates the local back affordance
- **THEN** the utility view state SHALL be cleared
- **AND** the primary content column SHALL show the memo list and inline compose area again.

