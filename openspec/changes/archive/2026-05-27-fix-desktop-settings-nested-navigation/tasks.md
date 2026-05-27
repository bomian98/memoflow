## 0. Preparation

- [x] 0.1 Confirm active architecture phase from `openspec/config.yaml` and record whether this work is still under `evolve_modularity`.
- [x] 0.2 Read the existing desktop/page chrome seams before editing:
  - `memos_flutter_app/lib/platform/widgets/platform_page.dart`
  - `memos_flutter_app/lib/core/desktop/desktop_titlebar_navigation_policy.dart`
  - `memos_flutter_app/lib/application/desktop/desktop_settings_window.dart`
  - `memos_flutter_app/lib/features/settings/desktop_settings_window_app.dart`
- [x] 0.3 Run current focused tests before changes:
  - `flutter test test/architecture/platform_ui_guardrail_test.dart`
  - `flutter test test/features/settings/platform_adaptive_settings_test.dart`
  - any existing desktop settings window tests if present
- [x] 0.4 Confirm no API-related files are needed. If implementation appears to require `lib/data/api` or `test/data/api`, pause for explicit approval.

## 1. Inventory: Full-page Secondary Pages

- [x] 1.1 Inventory settings full-page secondary routes opened from the settings window, including at least:
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
- [x] 1.2 Inventory share-related full-page routes and distinguish them from sheets/dialogs:
  - system share entry handling
  - third-party share capture / preview pages
  - share edit / confirm pages
  - share failure or fallback full-page surfaces
  - `NoteInputSheet` and other sheet-based flows that should remain outside this change
- [x] 1.3 Inventory other app full-page secondary pages likely affected by desktop titlebar rules:
  - memo detail/editor full-page routes
  - image preview full-page routes
  - collection reader secondary routes
  - review / AI summary secondary routes
  - tags / explore secondary routes
- [x] 1.4 Create a review note or task comment listing which pages are in scope for this batch and which are intentionally deferred.

## 2. Define Shared Secondary Page Chrome Seam

- [x] 2.1 Design a shared App-level secondary page chrome API that expresses:
  - page title
  - parent/back action
  - desktop titlebar safe-area avoidance
  - phone/tablet platform back behavior
  - optional confirmation before leaving
- [x] 2.2 Decide whether the seam belongs in:
  - `platform/widgets`
  - `core/desktop`
  - a feature-owned shell such as settings/share wrappers
  - or a combination where platform code stays feature-agnostic
- [x] 2.3 Ensure the seam does not import higher layers from lower layers:
  - no `platform -> features`
  - no `core -> features`
  - no shared seam importing settings/share business state directly
- [x] 2.4 Make the default desktop secondary title layout equivalent to:
  - `Back + Page Title`
  - no App-owned top-right `X` on macOS
  - no title/back overlap with macOS traffic lights
  - no title/back overlap with Windows/Linux native window controls
- [x] 2.5 Define how pages with unsaved/pending work plug into leave confirmation without each page owning titlebar behavior.

## 3. Settings Window Root And Native Close Behavior

- [x] 3.1 Locate how the desktop settings window stores or restores its active route.
- [x] 3.2 Update the settings window so native window close keeps native close semantics:
  - macOS red close closes the settings window
  - it does not pop nested Flutter routes
  - it does not masquerade as App-level back
- [x] 3.3 Ensure reopening the desktop settings window starts at the settings home page.
- [x] 3.4 Preserve non-desktop settings navigation behavior unless the shared secondary chrome seam intentionally applies there.
- [x] 3.5 Add or update tests proving:
  - nested settings route active -> close settings window -> reopen settings -> settings home appears
  - nested settings route active -> App-level back -> parent settings page appears

## 4. Migrate Settings Full-page Secondary Pages

- [x] 4.1 Migrate settings pages opened from the settings home to the shared secondary page chrome where they are full-page routes.
- [x] 4.2 Migrate `ComponentsSettingsScreen` child pages to show `Back + Page Title` on desktop:
  - reminder settings
  - image bed settings
  - image compression settings
  - location settings
  - template settings
  - WebDAV sync settings
- [x] 4.3 Ensure migrated settings pages do not render App-owned top-right `X` on macOS.
- [x] 4.4 Ensure migrated settings pages avoid macOS traffic lights and Windows/Linux native window controls.
- [x] 4.5 Preserve existing settings behavior and providers:
  - toggles
  - saving
  - navigation
  - permissions
  - validation
  - confirmation dialogs
- [x] 4.6 Add or update widget/source tests for representative settings pages:
  - one direct settings page from settings home
  - one Components child page
  - one page with confirmation or pending work if available
- [x] 4.7 Leave any deferred settings pages documented with explicit reason and follow-up priority.

## 5. Migrate Share-related Full-page Flows

- [x] 5.1 Identify share surfaces that are actual full-page routes and should use secondary page chrome.
- [x] 5.2 Keep sheets/dialogs outside this migration:
  - bottom sheets remain sheet chrome
  - dialogs remain dialog chrome
  - tooltip/popover behavior remains unchanged
- [x] 5.3 Migrate full-page share routes so non-root share steps use `Back + Page Title`.
- [x] 5.4 Ensure share cancellation is explicit:
  - use labeled cancel/task action where needed
  - do not use macOS-style App-owned top-right `X`
  - confirm if canceling would discard pending share work
- [x] 5.5 Preserve share behavior:
  - incoming system share payload handling
  - third-party share capture
  - share preview/edit
  - deferred image/video processing
  - save/cancel outcomes
- [x] 5.6 Add focused tests for one representative full-page share flow if testable locally.

## 6. Desktop Titlebar And Platform Behavior

- [x] 6.1 Update or extend `DesktopTitlebarNavigationPolicy` so secondary page context has a clear, reusable rule.
- [x] 6.2 Verify macOS desktop:
  - traffic lights stay unobstructed
  - no App-owned top-right `X`
  - secondary page title and back control are visible
  - red close closes the window
  - reopening settings starts at settings home
- [x] 6.3 Verify Windows/Linux desktop:
  - native window controls stay unobstructed
  - secondary page title and back control are visible
  - native close closes the window
  - App-level back returns to parent page
- [x] 6.4 Verify phone/tablet:
  - platform-appropriate back affordance remains
  - safe areas are respected
  - no desktop-only titlebar padding leaks into mobile layout

## 7. Guardrails

- [x] 7.1 Add or tighten architecture guardrail tests so migrated secondary pages do not hand-roll:
  - macOS traffic-light padding
  - App-owned top-right `X`
  - local close-vs-back behavior
  - direct titlebar offsets outside approved seams
- [x] 7.2 Add or update tests for platform layer dependency direction:
  - `platform/` does not import `features/`
  - `core/desktop` does not import feature screens
- [x] 7.3 Add an allowlist only for legacy pages not migrated in this batch.
- [x] 7.4 Document how future migrated pages should shrink the allowlist.

## 8. Verification

- [x] 8.1 Run focused tests:
  - desktop settings window navigation tests
  - settings page chrome tests
  - share flow tests touched by the migration
  - platform adaptive settings tests
- [x] 8.2 Run architecture guardrails:
  - `flutter test test/architecture/platform_ui_guardrail_test.dart`
  - any new secondary-page navigation guardrail
- [x] 8.3 Run `flutter analyze`.
- [x] 8.4 Run full `flutter test` before final readiness if time allows.
- [x] 8.5 Run `openspec validate fix-desktop-settings-nested-navigation --strict`.

## 9. Manual Review Checklist

> 自动化测试已覆盖 `ComponentsSettingsScreen -> Image Bed` 的二级导航、返回、刷新回首页，以及 share preview 的返回/取消语义。以下项目仍保留给真实桌面窗口人工验收，尤其是 macOS 原生红色关闭按钮。

- [x] 9.1 Manual macOS nested settings route smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 4.1.
- [x] 9.2 Manual `Back + Page Title` visual smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 4.2.
- [x] 9.3 Manual macOS traffic-light overlap smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 4.3.
- [x] 9.4 Manual App-level back smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 4.4.
- [x] 9.5 Manual macOS red close button smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 4.5.
- [x] 9.6 Manual settings reopen route smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 4.6.
- [x] 9.7 Manual desktop full-page share route secondary-page smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 4.7.
- [x] 9.8 Manual phone/tablet migrated page navigation smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 4.8.

## 10. Follow-up Planning

- [x] 10.1 Record any full-page secondary pages deferred from this batch.
- [x] 10.2 Prioritize deferred pages by risk:
  - titlebar overlap risk
  - App-owned `X` risk
  - close-vs-back confusion risk
  - share data loss risk
- [x] 10.3 Decide whether the shared secondary page chrome should become mandatory for every new full-page route in future guardrails.
