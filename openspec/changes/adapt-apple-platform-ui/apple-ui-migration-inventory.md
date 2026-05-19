# Apple UI Migration Inventory

## Scope

This inventory tracks high-perception Apple UI adaptation areas for `adapt-apple-platform-ui`. It is intentionally scoped to public UI and platform shell work. It does not authorize StoreKit, subscription, buyout, entitlement, receipt, price, paywall, App Store Connect, signing, notarization, TestFlight, or private release automation logic in the public repository.

Status values:

- `pending`: Not migrated to platform UI adapters yet.
- `in progress`: Adapter exists or a first page batch uses it, but coverage is incomplete.
- `complete`: High-perception use sites in the named area are migrated or have documented accepted exceptions.
- `accepted exception`: Existing behavior is intentionally retained with rationale.

## Current Baseline

- `features/*` pages directly use many Material primitives including `Scaffold`, `AppBar`, `MaterialPageRoute`, `AlertDialog`, `SimpleDialog`, `showModalBottomSheet`, `PopupMenuButton`, `DropdownButton`, `Card`, `ListTile`, and Material form controls.
- `features/home/desktop/*` contains a Windows-first desktop shell. macOS currently has runtime/menu support in scattered areas, but no independent Apple desktop shell.
- `HomeBottomNavShell` is mobile-oriented but still Material-first. Some mobile-native checks only target Android and need centralization in `platform/`.
- Settings and WebDAV screens are dense with grouped list, picker, dialog, switch, text input, and destructive-action patterns, making settings the first migration pilot.

## Area Inventory

| Area | Current hotspots | Target adapter / seam | Status | Notes |
| --- | --- | --- | --- | --- |
| Scaffold / AppBar / Navigation | `features/*/*_screen.dart`, `MemosListScreenBody`, `SettingsScreen`, collection / reminder / review pages | `PlatformPage`, platform navigation chrome | in progress | `SettingsScreen`, `PreferencesSettingsScreen`, `AboutUsScreen`, `ImportExportScreen`, and `WidgetsScreen` now use `PlatformPage`; complex settings children, home shell, memo flow, and other feature pages are pending. |
| Tab / Sidebar / Drawer | `HomeEntryScreen`, `HomeBottomNavShell`, `AppDrawer`, `features/home/desktop/*` | Apple mobile shell, Apple tablet shell, Apple desktop shell | in progress | iPhone now uses Apple-styled bottom navigation in `HomeBottomNavShell`; iPadOS/tablet-sized Apple layouts use `AppleTabletHomeShell` with a sidebar/split view and narrow-width fallback. `DesktopShellHost` now delegates macOS to `AppleMacosPageShell` and keeps Windows shell code in Windows-owned files. |
| Dialog / AlertDialog / SimpleDialog | settings, WebDAV, memo list/detail/editor, auth, collections, review | `PlatformDialog` | in progress | Preferences launch-action and surface color dialogs use `PlatformDialog`; destructive and confirm flows outside the pilot remain pending. |
| BottomSheet / PopupMenu / Context Menus | `NoteInputSheet`, memo action menus, title menu, settings enum sheets, collection sheets | `PlatformActionSheet`, platform menu / popover | in progress | Preferences enum and font selection use `PlatformPicker`; memo/context menus remain pending. |
| DatePicker / TimePicker / Dropdown / Picker | preferences, reminders, WebDAV schedules, reader style sheets | `PlatformPicker` | in progress | Preferences enum and font pickers migrated. Language dropdown remains as a Material fallback until a broader picker pass. |
| Switch / Checkbox / Radio / Slider / Progress | settings, reader style, WebDAV, reminders, stats | platform control wrappers | in progress | Preferences toggles use `PlatformSwitch`; other controls remain pending. |
| TextField / Form / Input | login, settings forms, WebDAV, memo editor, note input, search | `PlatformTextField`, platform search field | in progress | Custom theme hex inputs use `PlatformTextField`; broader forms remain pending. |
| List / Card / Grouped List | `SettingsScreen`, preferences, WebDAV, account security, AI settings | `PlatformGroupedList`, `PlatformListTile` | in progress | `SettingsScreen` and `PreferencesSettingsScreen` grouped containers now route through platform grouped-list wrappers on Apple targets. |
| Icon / Back / More / Share / Add | Broad `Icons.*` usage in navigation and action surfaces | `PlatformIcons` | in progress | Settings close/back and chevron affordances use `PlatformIcons` where platform-sensitive; broad icon replacement remains pending. |
| Page Transition / Back Gesture | `MaterialPageRoute` in app, presentation, settings, memo, collections | `PlatformRoute` | in progress | Settings primary route pushes, Preferences toolbar route, About release/donor routes, and Import/Export child routes use `PlatformRoute`; remaining routes are pending. |
| Scrolling Behavior | app scroll behavior, lists, reader, memo list, settings | platform scroll/theme policy | in progress | App-level scroll behavior now routes through `PlatformAppScrollBehavior`, preserving mouse/stylus/trackpad drag devices and using Apple bounce physics on iPhone, iPadOS, and macOS. Per-flow scrollbar density decisions remain pending. |
| SafeArea / Status Bar / Home Indicator | page shells, bottom sheets, editor, note input | `PlatformPage`, platform sheet wrappers | in progress | iPhone bottom navigation and iPad split shell now wrap primary navigation/content in platform safe areas; editor, note input, and remaining sheets are pending. |
| Dark Mode | `app_theme.dart`, `MemoFlowPalette`, custom page gradients/cards | `platform_theme.dart`, existing theme fallback | pending | Avoid one-off Apple dark tweaks inside feature pages. |
| Dynamic Type / Accessibility | app font size prefs, line height prefs, editor/list density | platform text policy, widget tests/manual checks | pending | Must avoid viewport-scaled fonts and clipping. |
| macOS Menu / Window Behavior | `app.dart`, macOS menu channel, desktop runtime, Windows desktop shell | Apple desktop shell, menu/shortcut/window semantics | in progress | macOS now has an independent desktop page shell without Windows window controls. Existing macOS menu command channel remains public UI behavior; final App Store metadata/manual verification is still pending. |
| Public Commercial Boundary | Apple UI shell and platform seam | guardrails and scans | pending | Public UI must not add StoreKit/entitlement/paywall logic. |

## Batch Tracking

| Batch | Scope | Status |
| --- | --- | --- |
| 1 | Inventory and guardrails | in progress |
| 2 | Platform UI foundation | complete |
| 3 | Settings pilot | complete for pilot scope |
| 4 | Apple shells | complete for shell batch |
| 5 | Memo main flow | pending |
| 6 | Remaining feature coverage | pending |
| 7 | macOS App Store experience | pending |
| 8 | Completion and verification | pending |

## Accepted Exceptions

| File | UI behavior | Reason | Verification |
| --- | --- | --- | --- |
| `memos_flutter_app/lib/features/settings/preferences_settings_screen.dart` | `ColorPickerSlider` inside custom theme color picker | This is a specialized color-selection control from `flutter_colorpicker`, not a generic value slider. It remains acceptable during the settings pilot while surrounding dialog and hex inputs move to platform adapters. | `flutter test test/features/settings/memo_toolbar_settings_screen_test.dart` and settings focused tests passed after migration. |
| `memos_flutter_app/lib/features/settings/account_security_screen.dart`, `api_plugins_screen.dart`, `password_lock_screen.dart`, `feedback_screen.dart`, `laboratory_screen.dart`, `components_settings_screen.dart`, `user_guide_screen.dart` | Remaining direct settings child pages | These pages are either form-heavy, state-heavy, or lower-risk for the first pilot. They remain pending for later settings coverage or task 6.1 rather than being partially migrated without focused tests. | Pilot coverage verified with focused settings tests; remaining pages are tracked as pending. |
