## 0. Preparation

- [x] 0.1 Confirm active architecture phase is `evolve_modularity` from `openspec/config.yaml`.
- [x] 0.2 Run the existing platform/settings focused tests before editing implementation:
  - `flutter test test/platform/platform_ui_test.dart`
  - `flutter test test/features/settings/platform_adaptive_settings_test.dart`
  - `flutter test test/features/settings/preferences_settings_screen_test.dart`
  - `flutter test test/features/settings/components_settings_screen_test.dart`
- [x] 0.3 Capture a lightweight inventory of `features/settings/*.dart` direct UI decisions:
  - direct `return Scaffold(`
  - direct `MemoFlowPalette.`
  - direct `Switch(` / `Switch.adaptive(`
  - direct `styleFrom(`
  - private `_ToggleCard`, `_CardGroup`, `_SectionCard`, `_CardRow`
  - direct platform checks such as `Platform.is*`, `defaultTargetPlatform`, `Theme.of(context).platform`
- [x] 0.4 Record the initial allowlist in the architecture test or a linked note so future migrations can shrink it intentionally.

## 1. Platform Experience Classification

- [x] 1.1 Design a normalized platform experience model that separates:
  - runtime platform
  - form factor
  - input model
  - window model
  - visual family
  - navigation model
- [x] 1.2 Add the model in an appropriate platform seam, reusing `PlatformTarget` where practical and avoiding `features/*`, `state/*`, `application/*`, or `data/*` imports.
- [x] 1.3 Preserve existing `resolvePlatformTarget(context)` behavior for current callers.
- [x] 1.4 Add focused tests for the classification of:
  - Android phone
  - iPhone
  - iPad-width iOS
  - macOS desktop
  - Windows desktop
  - Linux desktop
  - web fallback if locally testable
- [x] 1.5 Identify first migrated callers that should use the new model:
  - settings UI seam
  - `PlatformPage` / `PlatformListSection` if needed
  - no broad app-wide replacement in this batch

## 2. Settings UI Seam

- [x] 2.1 Create a settings-owned UI seam, initially scoped to settings screens rather than generic `platform/`.
- [x] 2.2 Add `SettingsPage` or equivalent wrapper that owns:
  - `PlatformPage` composition
  - background color
  - optional top dark gradient if still required
  - content safe area
  - desktop max width
  - title/leading action behavior
- [x] 2.3 Add `SettingsSection` or equivalent wrapper that owns:
  - grouped/inset section behavior
  - desktop dense section border/divider behavior
  - padding and spacing
- [x] 2.4 Add row components for common settings semantics:
  - `SettingsNavigationRow`
  - `SettingsValueRow` or select row
  - `SettingsToggleRow`
  - optional `SettingsToggleCard` only if Components needs card-like emphasis
- [x] 2.5 Add action components or variants:
  - primary
  - secondary/outlined
  - text
  - danger
- [x] 2.6 Ensure the settings seam delegates low-level platform behavior to existing platform widgets where possible:
  - `PlatformPage`
  - `PlatformListSection`
  - `PlatformListSectionRow`
  - `PlatformSwitch`
  - `PlatformPrimaryAction`
- [x] 2.7 Keep the seam free of commercial branching terms:
  - StoreKit
  - subscription
  - entitlement
  - receipt
  - paywall
  - productId
  - AccessDecision.source

## 3. Pilot: PreferencesSettingsScreen

- [x] 3.1 Replace screen-local `_Group` usage with the new `SettingsSection`.
- [x] 3.2 Replace `_SelectRow` with `SettingsValueRow` / `SettingsNavigationRow` where the row semantics match.
- [x] 3.3 Replace `_ToggleRow` with `SettingsToggleRow`.
- [x] 3.4 Keep specialized theme color picker widgets local only if they are genuinely page-specific.
- [x] 3.5 Move repeated background/text color derivation behind `SettingsPage` or a settings token helper.
- [x] 3.6 Preserve existing behavior for:
  - language picker
  - theme mode picker
  - theme color selection
  - custom theme editor
  - font picker
  - font size / line height
  - bottom navigation customization entry
  - memo toolbar settings entry
- [x] 3.7 Verify iPhone still renders Apple grouped settings rows where expected.
- [x] 3.8 Verify desktop still uses bounded dense content.

## 4. Pilot: ComponentsSettingsScreen

- [x] 4.1 Replace direct `Scaffold` + transparent `AppBar` with `SettingsPage` or equivalent.
- [x] 4.2 Replace private `_ToggleCard` with shared `SettingsToggleRow` or `SettingsToggleCard`.
- [x] 4.3 Replace direct `Switch` with the shared settings toggle seam / `PlatformSwitch`.
- [x] 4.4 Remove page-local card color, shadow, radius, and background decisions that are now owned by the seam.
- [x] 4.5 Preserve all existing component toggles and navigation:
  - reminders
  - third-party share
  - image bed
  - image compression
  - location
  - template
  - WebDAV sync
- [x] 4.6 Preserve reminder permission flow and third-party share confirmation flow.
- [x] 4.7 Verify the page visually matches `PreferencesSettingsScreen` as a sibling settings page on:
  - phone width
  - iPad/tablet width
  - desktop width
- [x] 4.8 Add or update widget tests that assert Components uses shared settings/platform controls instead of private card/switch behavior.

## 5. Guardrails

- [x] 5.1 Add a settings UI drift guardrail with an initial allowlist for legacy settings files.
- [x] 5.2 The guardrail SHOULD warn or fail for non-allowlisted settings files that introduce:
  - direct `MemoFlowPalette.`
  - direct `styleFrom(`
  - direct `Switch(` / `Switch.adaptive(`
  - private `_ToggleCard`
  - new direct `return Scaffold(` when `SettingsPage` is expected
- [x] 5.3 Add a platform experience guardrail or test to ensure platform classification logic stays in the approved platform seam.
- [x] 5.4 Keep existing `platform_ui_guardrail_test.dart` passing: `platform/` must not import higher layers.
- [x] 5.5 Update allowlist comments to describe how future migrations should remove entries.

## 6. Verification

- [x] 6.1 Run focused tests:
  - `flutter test test/platform/platform_ui_test.dart`
  - `flutter test test/features/settings/platform_adaptive_settings_test.dart`
  - `flutter test test/features/settings/preferences_settings_screen_test.dart`
  - `flutter test test/features/settings/components_settings_screen_test.dart`
  - any new settings UI seam tests
  - any new platform experience tests
- [x] 6.2 Run architecture guardrails touched by the change:
  - `flutter test test/architecture/platform_ui_guardrail_test.dart`
  - new settings UI guardrail test
  - new platform experience guardrail test if separate
- [x] 6.3 Run `flutter analyze`.
- [x] 6.4 Run full `flutter test` before final PR readiness if time allows.

## 7. Manual Review Checklist

- [ ] 7.1 Open Settings -> Preferences and Settings -> Components on phone width.
- [ ] 7.2 Open both pages on iPad/tablet width.
- [ ] 7.3 Open both pages on macOS desktop width.
- [ ] 7.4 Open both pages on Windows desktop width if available.
- [ ] 7.5 Compare:
  - page title/chrome
  - background color
  - grouped sections
  - row density
  - toggle geometry and active color
  - navigation row trailing indicators
  - desktop bounded width
  - dark mode
- [ ] 7.6 Confirm Components no longer looks like a separate card system from Preferences.
- [ ] 7.7 Confirm no setting behavior changed while UI shell changed.

## 8. Follow-up Planning

- [x] 8.1 Create a remaining settings page migration list after the pilot is complete.
- [x] 8.2 Prioritize next pages by visual impact:
  - `SettingsScreen`
  - `ImageBedSettingsScreen`
  - `ImageCompressionSettingsScreen`
  - `WebDavSyncScreen`
  - `AiSettingsScreen`
  - `PasswordLockScreen`
  - `DesktopSettingsWindowApp`
- [x] 8.3 Decide whether `SettingsToggleCard` remains a permanent semantic component or should be folded into section rows.
- [x] 8.4 Decide whether platform experience model will gradually replace `PlatformTarget` helpers or stay as a richer layer above them.

## 9. Components Visual Pilot

- [x] 9.1 Add settings UI seam support for feature modules:
  - module title layer
  - module Tooltip / help popover trigger
  - feature entry compound button
  - semantic status indicator
  - 70/30 detail-vs-toggle interaction split
- [x] 9.2 Migrate `ComponentsSettingsScreen` from section toggle rows to feature modules:
  - reminders
  - third-party share
  - image bed
  - image compression
  - location
  - template
  - WebDAV sync
- [x] 9.3 Preserve existing behavior while changing visual shell:
  - reminder permission request before enabling
  - reminder navigation
  - third-party share confirmation before enabling
  - image bed navigation and toggle
  - image compression navigation and toggle
  - location navigation and toggle
  - template navigation and toggle
  - WebDAV navigation and toggle
- [x] 9.4 Add or update focused tests for the Components feature module structure.
- [x] 9.5 Run focused Components/settings seam tests and touched architecture guardrails.
- [x] 9.6 Run `flutter analyze`.

## 10. Components Visual Layout Revision

- [x] 10.1 Update the visual decision record to replace per-feature header/status modules with the compact list layout.
- [x] 10.2 Revise the settings UI seam so `SettingsFeatureModule` renders as a single compact row:
  - left 70% detail/open area
  - right 30% switch/control area
  - row-level `?` Tooltip at the far right
  - no separate per-feature title layer
  - no status icon layer
- [x] 10.3 Update `ComponentsSettingsScreen` to match the compact layout while preserving all existing toggles and navigation.
- [x] 10.4 Update focused tests and guardrails for the revised Components feature row structure.
- [x] 10.5 Run focused Components/settings tests and `flutter analyze`.

## 11. Components Row Clarification Revision

- [x] 11.1 Update the visual decision record for the clarified row layout:
  - each feature title owns its own `?` Tooltip beside the title text, about 10px away
  - the Tooltip is not a page-title control and is not placed at the far row end
  - restore the semantic status icon near the detail/open area end
  - the switch area is fixed to switch width plus about 5px horizontal redundancy on each side, not a 30% column
- [x] 11.2 Revise `SettingsFeatureModule` so the row renders:
  - title + `?` Tooltip inline on the left
  - status icon before the divider
  - divider between detail/open area and switch area
  - fixed-width switch area with mobile/desktop tap behavior preserved
- [x] 11.3 Update `ComponentsSettingsScreen` to pass semantic status for every feature while preserving existing toggle and navigation behavior.
- [x] 11.4 Update focused tests and guardrails for the clarified Components feature row structure.
- [x] 11.5 Run focused Components/settings tests and `flutter analyze`.
