## 0. Preparation

- [x] 0.1 Confirm active architecture phase is still `evolve_modularity` from `openspec/config.yaml`.
- [x] 0.2 Confirm implementation does not require API-related files. If `memos_flutter_app/lib/data/api` or `memos_flutter_app/test/data/api` appears necessary, pause for explicit approval.
- [x] 0.3 Read current desktop inline compose paths before editing:
  - `memos_flutter_app/lib/features/home/home_root_destination_registry.dart`
  - `memos_flutter_app/lib/features/home/app_drawer_destination_builder.dart`
  - `memos_flutter_app/lib/features/memos/memos_list_screen.dart`
  - `memos_flutter_app/lib/features/memos/widgets/memos_list_inline_compose_card.dart`
  - `memos_flutter_app/lib/application/desktop/desktop_resizable_panel_shell.dart`
- [x] 0.4 Run current focused tests that cover desktop inline compose and resizable shell:
  - `flutter test test/application/desktop/desktop_resizable_panel_shell_test.dart`
  - `flutter test test/features/home/home_root_destination_registry_test.dart`
  - `flutter test test/features/memos/memos_list_screen_test.dart --plain-name "windows home compose flag shows desktop resize handles"`

## 1. Capability And Entry Consistency

- [x] 1.1 Add or identify a shared capability decision for desktop home inline compose resize.
- [x] 1.2 Ensure supported Windows desktop home memo routes use the same capability decision from:
  - initial `HomeRootDestination.memos`
  - drawer `AppDrawerDestination.memos`
  - desktop utility return/replacement route where applicable
- [x] 1.3 Keep embedded bottom-nav, mobile, tablet, and unsupported Linux paths on the non-resizable fallback.
- [x] 1.4 Decide whether macOS is enabled in this batch; if enabled, include focused coverage and preserve macOS shell chrome rules.
- [x] 1.5 Avoid introducing new lower-layer imports from `core`, `application`, or `state` into `features/memos`.

## 2. Resize Behavior Fix

- [x] 2.1 Verify `DesktopResizablePanelShell` is actually present on the affected Windows route after the entry consistency fix.
- [x] 2.2 Add a real drag regression test that drags a visible resize handle in the home memo route and proves geometry or persisted layout changes.
- [x] 2.3 If the real drag test still fails while handles exist, fix the smallest hit-test/layout issue in `DesktopResizablePanelShell` or the immediate parent layout.
- [x] 2.4 Preserve existing min/max width, min/max editor height, viewport clamping, and scroll anchor behavior.
- [x] 2.5 Preserve inline compose state: draft text, pending attachments, linked memos, location state, tag autocomplete, and focus behavior.
- [x] 2.6 Preserve desktop preview pane state and selected memo keyboard behavior while resizing.

## 3. Persistence And Restore

- [x] 3.1 Keep `homeInlineComposePanelLayout` persistence owned by `devicePreferencesProvider` / `DevicePreferences`.
- [x] 3.2 Verify resize completion persists width, editor height, `xRatio`, and `yRatio`.
- [x] 3.3 Verify saved layout restores inside a smaller desktop viewport and remains above minimum usable size.
- [x] 3.4 Ensure unsupported Linux/non-desktop fallback does not read or apply resize-only geometry in a way that breaks inline compose.
- [x] 3.5 Prime saved layout on the first loaded desktop frame to avoid a visible default-size flash when returning to all memos.

## 4. Guardrails

- [x] 4.1 Add or update focused tests so drawer memos route and initial home route agree on resize capability.
- [x] 4.2 Add source or widget coverage preventing future desktop memos entry paths from bypassing the shared resize capability decision.
- [x] 4.3 Run architecture guardrails relevant to desktop layering and platform UI:
  - `flutter test test/architecture/platform_ui_guardrail_test.dart`
  - any desktop shell/layering guardrail touched by the implementation
- [x] 4.4 Keep public shell files free of commercial/subscription/paywall/entitlement terms.

## 5. Verification

- [x] 5.1 Run focused tests:
  - `flutter test test/application/desktop/desktop_resizable_panel_shell_test.dart`
  - `flutter test test/features/home/home_root_destination_registry_test.dart`
  - focused `memos_list_screen_test` cases for inline compose resize and route consistency
- [x] 5.2 Run `flutter analyze` from `memos_flutter_app`.
- [x] 5.3 Run `openspec validate fix-desktop-inline-compose-resize --strict`.
- [x] 5.4 If time allows before PR readiness, run full `flutter test`.

## 6. Manual Smoke

- [x] 6.1 Manual Windows initial home inline compose drag smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 2.1.
- [x] 6.2 Manual Windows drawer-return resize smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 2.2.
- [x] 6.3 Manual resized layout persistence smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 2.3.
- [x] 6.4 Manual draft/attachment/preview preservation smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 2.4.
- [x] 6.5 Manual macOS resize/titlebar smoke, if applicable, is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 2.5.
