## 1. Inventory and Guardrails

- [x] 1.1 Create an Apple UI migration inventory note under `openspec/changes/adapt-apple-platform-ui/` covering scaffold / app bar / navigation, tab / sidebar / drawer, dialog / alert, bottom sheet / popup menu, picker, controls, text input, grouped list / card, icons, transitions / back gesture, scrolling, safe area, dark mode, dynamic type, accessibility, and macOS menu / window behavior.
- [x] 1.2 Add or tighten an architecture guardrail that prevents `memos_flutter_app/lib/platform/` from importing `features/*`, `state/*`, `application/*`, or `data/*`.
- [x] 1.3 Add or tighten a public commercial guardrail so Apple UI shell and platform adapter files cannot introduce StoreKit, product IDs, prices, receipt, purchase / restore, paywall, entitlement implementation, subscription, buyout, or `AccessDecision.source` business branching.

## 2. Platform UI Foundation

- [x] 2.1 Create the public platform UI seam under `memos_flutter_app/lib/platform/` with platform target detection for Android, iPhone, iPadOS / tablet Apple layouts, macOS, Windows, Linux, and web.
- [x] 2.2 Implement `PlatformIcons` for key navigation and action icons: back, close, more, share, add, edit, delete, settings, search, notifications, sidebar, check, warning, and destructive action.
- [x] 2.3 Implement `PlatformRoute` so migrated flows preserve existing Material / Windows behavior and use Apple-appropriate route transition and back gesture behavior on Apple platforms.
- [x] 2.4 Implement `PlatformPage` and navigation chrome abstractions for title, leading, actions, safe area, bottom bar, sidebar / drawer slot, toolbar slot, and Material fallback.
- [x] 2.5 Implement `PlatformDialog`, `PlatformActionSheet`, and `PlatformPicker` semantic APIs with Apple, Windows / desktop, and Material fallback behavior.
- [x] 2.6 Implement `PlatformGroupedList`, `PlatformListTile`, `PlatformSwitch`, `PlatformCheckbox`, `PlatformRadio`, `PlatformSlider`, `PlatformProgress`, and `PlatformTextField` wrappers.
- [x] 2.7 Add focused widget tests for platform target resolution, fallback behavior, route selection, dialog / picker semantics, grouped list rendering, and basic adaptive controls.

## 3. Settings Pilot

- [x] 3.1 Migrate `SettingsScreen` page chrome and primary list groups to `PlatformPage`, `PlatformGroupedList`, `PlatformListTile`, and `PlatformIcons` while preserving private extension settings entry rendering through the existing bundle seam.
- [x] 3.2 Migrate `PreferencesSettingsScreen` enum, font, theme, switch, slider, text input, color, and route interactions to platform picker / dialog / control wrappers.
- [x] 3.3 Migrate high-frequency settings child pages that are directly reachable from the main settings screen to platform page chrome and grouped list components where the change is low-risk.
- [x] 3.4 Update the migration inventory to mark the settings pilot complete, in progress, and pending areas explicitly.
- [x] 3.5 Add focused tests for settings shell behavior, private extension entry rendering, public commercial boundary preservation, and Apple grouped-list fallback behavior.

## 4. Apple Shells

- [x] 4.1 Update `HomeEntryScreen` or its composition boundary so iOS, iPadOS, macOS, Android, Windows, Linux, and web choose the correct shell without duplicating feature pages.
- [x] 4.2 Implement Apple mobile shell for iPhone-sized layouts with Apple-style tab / primary navigation, safe-area handling, route behavior, and no Android drawer-first presentation.
- [x] 4.3 Implement Apple tablet shell for iPadOS / tablet-sized Apple layouts with sidebar or split-view navigation and narrow-width fallback.
- [x] 4.4 Implement Apple desktop shell for macOS with independent sidebar, toolbar, menu / shortcut / window semantics, and no final dependency on Windows window controls.
- [x] 4.5 Refactor `DesktopShellHost` or equivalent desktop composition so Windows-specific shell code stays in Windows-owned files and macOS shell code is separately owned.
- [x] 4.6 Update app-level theme / scroll / safe-area behavior so Apple shells respect dark mode, platform scrolling expectations, and dynamic text constraints without regressing Android / Windows.
- [x] 4.7 Add widget or architecture tests covering shell selection, destination reuse, and Windows / macOS shell separation.

## 5. Memo Main Flow

- [ ] 5.1 Migrate `MemosListScreen` and `MemosListScreenBody` page chrome, list header, search entry, quick actions, more menu, drawer/sidebar hooks, route pushes, and primary actions to platform UI adapters.
- [ ] 5.2 Migrate memo card and memo detail high-perception actions such as more menu, share, edit, delete, archive, restore, relation, visibility, and destructive confirmation to platform action sheet / dialog APIs.
- [ ] 5.3 Migrate `MemoEditorScreen` page chrome, close / save / discard flows, toolbar actions, picker actions, route behavior, safe area, keyboard avoidance, and desktop modal presentation to platform adapters.
- [ ] 5.4 Migrate `NoteInputSheet` and compose-related transient UI to platform action sheet / picker / dialog / text field wrappers while preserving draft, attachment, location, template, and tag-autocomplete behavior.
- [ ] 5.5 Remove or centralize iOS / macOS platform checks discovered in memo flow pages into `platform/` target or UI adapter APIs.
- [ ] 5.6 Add focused tests for memo list shell behavior, action menu semantics, editor close decisions, note input presentation, and route fallback.

## 6. Remaining Feature Coverage

- [ ] 6.1 Migrate WebDAV and high-density settings pages to platform page, grouped list, picker, dialog, switch, text input, and destructive action wrappers.
- [ ] 6.2 Migrate collections and reader flows where they use page chrome, empty-state actions, reader settings sheets, sliders, menus, and route pushes.
- [ ] 6.3 Migrate reminders, review, stats, resources, notifications, share, import, onboarding, lock, image preview, and debug flows for high-perception Apple UI components.
- [ ] 6.4 Replace high-frequency direct `MaterialPageRoute`, `AlertDialog`, `SimpleDialog`, `showModalBottomSheet`, `PopupMenuButton`, `DropdownButton`, and direct Material control usage in migrated flows with platform adapters or document accepted exceptions.
- [ ] 6.5 Update the migration inventory after each remaining feature batch with complete / in-progress / pending status.

## 7. macOS App Store Experience

- [ ] 7.1 Ensure macOS shell exposes App Store-appropriate menu, command, shortcut, close / minimize / fullscreen, window restoration, and toolbar behavior without adding private commercial release automation.
- [ ] 7.2 Verify macOS public shell metadata and UI code remain free of StoreKit, entitlement, receipt, product, price, paywall, signing secret, notarization, TestFlight, or App Store Connect configuration leakage.
- [ ] 7.3 Add or update focused macOS desktop behavior tests where practical, and document manual verification steps for behavior that cannot be covered by Flutter tests.

## 8. Completion and Verification

- [ ] 8.1 Run `flutter analyze` from `memos_flutter_app` and resolve or document any unrelated pre-existing issues.
- [ ] 8.2 Run focused widget / architecture tests added by this change.
- [ ] 8.3 Run `flutter test` from `memos_flutter_app`, or document any local blocker and residual risk.
- [ ] 8.4 Run the relevant public commercial guardrail scan and architecture dependency guardrail tests.
- [ ] 8.5 Produce a final Apple UI migration completion report listing all high-perception areas, their status, accepted exceptions, verification commands, and remaining risks.
