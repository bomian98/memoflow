## 1. Preparation

- [x] 1.1 Confirm active architecture phase is still `evolve_modularity` from `openspec/config.yaml`.
- [x] 1.2 Confirm implementation does not require API-related files. If `memos_flutter_app/lib/data/api` or `memos_flutter_app/test/data/api` appears necessary, pause for explicit approval.
- [x] 1.3 Inventory current top-level desktop destination shell splits with `rg "\\?\\s*DesktopShellHost\\(" memos_flutter_app/lib/features -g '*.dart'`.
- [x] 1.4 Read existing shell and policy seams before editing:
  - `memos_flutter_app/lib/features/home/desktop/desktop_shell_host.dart`
  - `memos_flutter_app/lib/features/home/desktop/windows_desktop_page_shell.dart`
  - `memos_flutter_app/lib/features/home/desktop/apple_macos_page_shell.dart`
  - `memos_flutter_app/lib/core/desktop/desktop_titlebar_navigation_policy.dart`
  - `memos_flutter_app/lib/platform/widgets/platform_page.dart`
- [x] 1.5 Run current focused architecture tests:
  - `flutter test test/architecture/desktop_shell_boundary_guardrail_test.dart`
  - `flutter test test/architecture/platform_ui_guardrail_test.dart`

## 2. Unified Desktop Destination Shell Seam

- [x] 2.1 Add or enhance a top-level desktop destination shell seam under the desktop shell boundary.
- [x] 2.2 Support semantic inputs for selected drawer destination, title, actions/trailing content, body, secondary pane, modal surface, and navigation context.
- [x] 2.3 Keep Windows command bar, window controls, overlay/rail/sidebar routing, and secondary pane behavior owned by the Windows shell.
- [x] 2.4 Keep macOS toolbar, traffic-light safe area, expanded-sidebar title suppression, and stable titlebar spacer behavior owned by the macOS shell.
- [x] 2.5 Add an explicit way to express top-level dismissal intent when needed, without embedding back/close controls inside title widgets.
- [x] 2.6 Ensure the new seam does not introduce lower-layer imports from `core`, `application`, `state`, `data`, or `platform` into feature UI.

## 3. Page Migration

- [x] 3.1 Migrate `DailyReviewScreen` to the unified top-level desktop destination shell and preserve filter action behavior.
- [x] 3.2 Migrate `ExploreScreen` and preserve search, preview pane, drawer navigation, tag navigation, and notifications entry behavior.
- [x] 3.3 Migrate `AiSummaryScreen` and preserve template/settings/share actions and report mode behavior.
- [x] 3.4 Migrate `TagsScreen`, `ResourcesScreen`, and `AboutScreen` while preserving existing top-level actions and drawer navigation.
- [x] 3.5 Migrate `CollectionsScreen` and preserve collection creation/opening flows and desktop content layout.
- [x] 3.6 Migrate `NotificationsScreen` and preserve embedded utility/back behavior where it differs from top-level drawer destination behavior.
- [x] 3.7 Migrate `RecycleBinScreen` and preserve clear/delete actions and route back semantics.
- [x] 3.8 Evaluate `SettingsScreen` separately; migrate only if close semantics can be represented through the unified shell intent without changing user behavior.
- [x] 3.9 Remove migrated pages from the inventory of `? DesktopShellHost(...) : Scaffold(...)` top-level shell splits.

## 4. Guardrails And Tests

- [x] 4.1 Add or tighten architecture guardrail coverage so migrated top-level desktop destination pages cannot reintroduce page-local Windows/macOS shell splits.
- [x] 4.2 Add guardrail or focused source coverage preventing migrated pages from putting back/close/done controls inside `DesktopShellHost.leadingTitle` or equivalent title slots.
- [x] 4.3 Add focused widget tests covering Windows command bar rendering through the unified shell for at least one migrated destination.
- [x] 4.4 Add focused widget tests covering macOS expanded-sidebar title suppression through the unified shell for at least one migrated destination.
- [x] 4.5 Add focused widget tests covering at least one title-visible fallback mode such as rail/overlay/narrow desktop navigation.
- [x] 4.6 Update existing daily review regression coverage so Windows and macOS top-level destination chrome remain consistent.

## 5. Verification

- [x] 5.1 Run `flutter analyze` from `memos_flutter_app`.
- [x] 5.2 Run focused desktop shell and platform guardrails:
  - `flutter test test/architecture/desktop_shell_boundary_guardrail_test.dart`
  - `flutter test test/architecture/platform_ui_guardrail_test.dart`
  - `flutter test test/architecture/modularity_dependency_guardrail_test.dart`
- [x] 5.3 Run focused widget tests for every migrated destination touched in this change.
- [x] 5.4 Run `openspec validate unify-desktop-destination-shell-navigation --strict`.
- [x] 5.5 Run `git diff --check`.
- [x] 5.6 If time allows before PR readiness, run full `flutter test`.

## 6. Manual Smoke

- [ ] 6.1 On Windows desktop, switch through migrated drawer destinations and confirm top-left back/close buttons only appear where semantically intended.
- [x] 6.2 On macOS desktop expanded sidebar, switch through migrated drawer destinations and confirm duplicate top-leading titles remain suppressed.
- [x] 6.3 On macOS rail/narrow mode, confirm current destination title remains visible where sidebar labels are not persistently visible.
  - Follow-up note: added a labeled navigation menu entry to rail mode, moved Draft Box onto the unified desktop destination shell, and routed All Notes/Archive through the shared macOS rail shell so their navigation position matches the other destination pages; needs manual retest.
- [ ] 6.4 Confirm migrated pages still expose their existing actions such as filter, search, create, clear, share, and mode menus.
- [ ] 6.5 Confirm desktop memo list inline compose resize still works after shell migration, especially when returning from migrated destinations to all memos.
