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
| Scaffold / AppBar / Navigation | `features/*/*_screen.dart`, `MemosListScreenBody`, `SettingsScreen`, collection / reminder / review pages | `PlatformPage`, platform navigation chrome | pending | Start with settings pilot, then home shell and memo flow. |
| Tab / Sidebar / Drawer | `HomeEntryScreen`, `HomeBottomNavShell`, `AppDrawer`, `features/home/desktop/*` | Apple mobile shell, Apple tablet shell, Apple desktop shell | pending | iPhone may keep tab model with Apple styling; iPadOS prefers sidebar / split-view; macOS uses independent desktop shell. |
| Dialog / AlertDialog / SimpleDialog | settings, WebDAV, memo list/detail/editor, auth, collections, review | `PlatformDialog` | pending | Prioritize destructive and confirm flows. |
| BottomSheet / PopupMenu / Context Menus | `NoteInputSheet`, memo action menus, title menu, settings enum sheets, collection sheets | `PlatformActionSheet`, platform menu / popover | pending | iPhone action sheet; iPadOS popover/sheet; macOS menu/dialog. |
| DatePicker / TimePicker / Dropdown / Picker | preferences, reminders, WebDAV schedules, reader style sheets | `PlatformPicker` | pending | Enum and font pickers are settings pilot candidates. |
| Switch / Checkbox / Radio / Slider / Progress | settings, reader style, WebDAV, reminders, stats | platform control wrappers | pending | Use wrappers over scattered direct `.adaptive` calls. |
| TextField / Form / Input | login, settings forms, WebDAV, memo editor, note input, search | `PlatformTextField`, platform search field | pending | Memo editor and note input remain separate high-risk batches. |
| List / Card / Grouped List | `SettingsScreen`, preferences, WebDAV, account security, AI settings | `PlatformGroupedList`, `PlatformListTile` | pending | Settings pilot validates grouped-list tokens. |
| Icon / Back / More / Share / Add | Broad `Icons.*` usage in navigation and action surfaces | `PlatformIcons` | pending | First replace key chrome/action icons, not every decorative icon. |
| Page Transition / Back Gesture | `MaterialPageRoute` in app, presentation, settings, memo, collections | `PlatformRoute` | pending | iOS route and edge-back behavior must be centralized. |
| Scrolling Behavior | app scroll behavior, lists, reader, memo list, settings | platform scroll/theme policy | pending | Preserve desktop pointer support; add Apple bounce/scrollbar decisions. |
| SafeArea / Status Bar / Home Indicator | page shells, bottom sheets, editor, note input | `PlatformPage`, platform sheet wrappers | pending | Should move safe-area defaults into platform wrappers. |
| Dark Mode | `app_theme.dart`, `MemoFlowPalette`, custom page gradients/cards | `platform_theme.dart`, existing theme fallback | pending | Avoid one-off Apple dark tweaks inside feature pages. |
| Dynamic Type / Accessibility | app font size prefs, line height prefs, editor/list density | platform text policy, widget tests/manual checks | pending | Must avoid viewport-scaled fonts and clipping. |
| macOS Menu / Window Behavior | `app.dart`, macOS menu channel, desktop runtime, Windows desktop shell | Apple desktop shell, menu/shortcut/window semantics | pending | Must be App Store-appropriate without private release automation. |
| Public Commercial Boundary | Apple UI shell and platform seam | guardrails and scans | pending | Public UI must not add StoreKit/entitlement/paywall logic. |

## Batch Tracking

| Batch | Scope | Status |
| --- | --- | --- |
| 1 | Inventory and guardrails | in progress |
| 2 | Platform UI foundation | pending |
| 3 | Settings pilot | pending |
| 4 | Apple shells | pending |
| 5 | Memo main flow | pending |
| 6 | Remaining feature coverage | pending |
| 7 | macOS App Store experience | pending |
| 8 | Completion and verification | pending |

## Accepted Exceptions

None yet. Future accepted exceptions must name the file, UI behavior, platform impact, reason, and verification performed.
