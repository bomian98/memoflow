## 0. Preparation

- [ ] 0.1 Confirm active architecture phase from `openspec/config.yaml` and record whether this work is still under `evolve_modularity`.
- [ ] 0.2 Read the existing desktop/page chrome seams before editing:
  - `memos_flutter_app/lib/platform/widgets/platform_page.dart`
  - `memos_flutter_app/lib/core/desktop/desktop_titlebar_navigation_policy.dart`
  - `memos_flutter_app/lib/application/desktop/desktop_settings_window.dart`
  - `memos_flutter_app/lib/features/settings/desktop_settings_window_app.dart`
- [ ] 0.3 Run current focused tests before changes:
  - `flutter test test/architecture/platform_ui_guardrail_test.dart`
  - `flutter test test/features/settings/platform_adaptive_settings_test.dart`
  - any existing desktop settings window tests if present
- [ ] 0.4 Confirm no API-related files are needed. If implementation appears to require `lib/data/api` or `test/data/api`, pause for explicit approval.

## 1. Inventory: Full-page Secondary Pages

- [ ] 1.1 Inventory settings full-page secondary routes opened from the settings window, including at least:
  - `PreferencesSettingsScreen`
  - `ComponentsSettingsScreen`
  - reminder settings
  - image bed settings
  - image compression settings
  - location settings
  - template settings
  - WebDAV sync settings
  - AI/provider/proxy/model settings pages reached from settings
  - import/export and other settings detail pages reached from settings
- [ ] 1.2 Inventory share-related full-page routes and distinguish them from sheets/dialogs:
  - system share entry handling
  - third-party share capture / preview pages
  - share edit / confirm pages
  - share failure or fallback full-page surfaces
  - `NoteInputSheet` and other sheet-based flows that should remain outside this change
- [ ] 1.3 Inventory other app full-page secondary pages likely affected by desktop titlebar rules:
  - memo detail/editor full-page routes
  - image preview full-page routes
  - collection reader secondary routes
  - review / AI summary secondary routes
  - tags / explore secondary routes
- [ ] 1.4 Create a review note or task comment listing which pages are in scope for this batch and which are intentionally deferred.

## 2. Define Shared Secondary Page Chrome Seam

- [ ] 2.1 Design a shared App-level secondary page chrome API that expresses:
  - page title
  - parent/back action
  - desktop titlebar safe-area avoidance
  - phone/tablet platform back behavior
  - optional confirmation before leaving
- [ ] 2.2 Decide whether the seam belongs in:
  - `platform/widgets`
  - `core/desktop`
  - a feature-owned shell such as settings/share wrappers
  - or a combination where platform code stays feature-agnostic
- [ ] 2.3 Ensure the seam does not import higher layers from lower layers:
  - no `platform -> features`
  - no `core -> features`
  - no shared seam importing settings/share business state directly
- [ ] 2.4 Make the default desktop secondary title layout equivalent to:
  - `Back + Page Title`
  - no App-owned top-right `X` on macOS
  - no title/back overlap with macOS traffic lights
  - no title/back overlap with Windows/Linux native window controls
- [ ] 2.5 Define how pages with unsaved/pending work plug into leave confirmation without each page owning titlebar behavior.

## 3. Settings Window Root And Native Close Behavior

- [ ] 3.1 Locate how the desktop settings window stores or restores its active route.
- [ ] 3.2 Update the settings window so native window close keeps native close semantics:
  - macOS red close closes the settings window
  - it does not pop nested Flutter routes
  - it does not masquerade as App-level back
- [ ] 3.3 Ensure reopening the desktop settings window starts at the settings home page.
- [ ] 3.4 Preserve non-desktop settings navigation behavior unless the shared secondary chrome seam intentionally applies there.
- [ ] 3.5 Add or update tests proving:
  - nested settings route active -> close settings window -> reopen settings -> settings home appears
  - nested settings route active -> App-level back -> parent settings page appears

## 4. Migrate Settings Full-page Secondary Pages

- [ ] 4.1 Migrate settings pages opened from the settings home to the shared secondary page chrome where they are full-page routes.
- [ ] 4.2 Migrate `ComponentsSettingsScreen` child pages to show `Back + Page Title` on desktop:
  - reminder settings
  - image bed settings
  - image compression settings
  - location settings
  - template settings
  - WebDAV sync settings
- [ ] 4.3 Ensure migrated settings pages do not render App-owned top-right `X` on macOS.
- [ ] 4.4 Ensure migrated settings pages avoid macOS traffic lights and Windows/Linux native window controls.
- [ ] 4.5 Preserve existing settings behavior and providers:
  - toggles
  - saving
  - navigation
  - permissions
  - validation
  - confirmation dialogs
- [ ] 4.6 Add or update widget/source tests for representative settings pages:
  - one direct settings page from settings home
  - one Components child page
  - one page with confirmation or pending work if available
- [ ] 4.7 Leave any deferred settings pages documented with explicit reason and follow-up priority.

## 5. Migrate Share-related Full-page Flows

- [ ] 5.1 Identify share surfaces that are actual full-page routes and should use secondary page chrome.
- [ ] 5.2 Keep sheets/dialogs outside this migration:
  - bottom sheets remain sheet chrome
  - dialogs remain dialog chrome
  - tooltip/popover behavior remains unchanged
- [ ] 5.3 Migrate full-page share routes so non-root share steps use `Back + Page Title`.
- [ ] 5.4 Ensure share cancellation is explicit:
  - use labeled cancel/task action where needed
  - do not use macOS-style App-owned top-right `X`
  - confirm if canceling would discard pending share work
- [ ] 5.5 Preserve share behavior:
  - incoming system share payload handling
  - third-party share capture
  - share preview/edit
  - deferred image/video processing
  - save/cancel outcomes
- [ ] 5.6 Add focused tests for one representative full-page share flow if testable locally.

## 6. Desktop Titlebar And Platform Behavior

- [ ] 6.1 Update or extend `DesktopTitlebarNavigationPolicy` so secondary page context has a clear, reusable rule.
- [ ] 6.2 Verify macOS desktop:
  - traffic lights stay unobstructed
  - no App-owned top-right `X`
  - secondary page title and back control are visible
  - red close closes the window
  - reopening settings starts at settings home
- [ ] 6.3 Verify Windows/Linux desktop:
  - native window controls stay unobstructed
  - secondary page title and back control are visible
  - native close closes the window
  - App-level back returns to parent page
- [ ] 6.4 Verify phone/tablet:
  - platform-appropriate back affordance remains
  - safe areas are respected
  - no desktop-only titlebar padding leaks into mobile layout

## 7. Guardrails

- [ ] 7.1 Add or tighten architecture guardrail tests so migrated secondary pages do not hand-roll:
  - macOS traffic-light padding
  - App-owned top-right `X`
  - local close-vs-back behavior
  - direct titlebar offsets outside approved seams
- [ ] 7.2 Add or update tests for platform layer dependency direction:
  - `platform/` does not import `features/`
  - `core/desktop` does not import feature screens
- [ ] 7.3 Add an allowlist only for legacy pages not migrated in this batch.
- [ ] 7.4 Document how future migrated pages should shrink the allowlist.

## 8. Verification

- [ ] 8.1 Run focused tests:
  - desktop settings window navigation tests
  - settings page chrome tests
  - share flow tests touched by the migration
  - platform adaptive settings tests
- [ ] 8.2 Run architecture guardrails:
  - `flutter test test/architecture/platform_ui_guardrail_test.dart`
  - any new secondary-page navigation guardrail
- [ ] 8.3 Run `flutter analyze`.
- [ ] 8.4 Run full `flutter test` before final readiness if time allows.
- [ ] 8.5 Run `openspec validate fix-desktop-settings-nested-navigation --strict`.

## 9. Manual Review Checklist

- [ ] 9.1 On macOS, open settings home, navigate to `ComponentsSettingsScreen`, then open a child detail page.
- [ ] 9.2 Confirm the child detail page shows `Back + Page Title`.
- [ ] 9.3 Confirm title/back controls do not overlap macOS traffic lights.
- [ ] 9.4 Click App-level back and confirm it returns to the parent settings page.
- [ ] 9.5 From a nested settings page, click the macOS red close button and confirm the settings window closes.
- [ ] 9.6 Reopen settings and confirm it starts at settings home.
- [ ] 9.7 Review one full-page share route on desktop and confirm it follows the same secondary page rules.
- [ ] 9.8 Review phone/tablet navigation for migrated pages and confirm platform back behavior still feels native.

## 10. Follow-up Planning

- [ ] 10.1 Record any full-page secondary pages deferred from this batch.
- [ ] 10.2 Prioritize deferred pages by risk:
  - titlebar overlap risk
  - App-owned `X` risk
  - close-vs-back confusion risk
  - share data loss risk
- [ ] 10.3 Decide whether the shared secondary page chrome should become mandatory for every new full-page route in future guardrails.
