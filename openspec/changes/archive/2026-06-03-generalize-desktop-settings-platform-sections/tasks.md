## 1. Preparation

- [x] 1.1 Audit current references with `rg WindowsRelatedSettingsScreen|windows_related|msg_windows_related_settings|msg_configure_windows_desktop_shortcuts` and remove the old Windows-related screen concept rather than keeping a compatibility wrapper.
- [x] 1.2 Confirm current desktop target handling in `settings_screen.dart`, `desktop_settings_window_app.dart`, `platform_target.dart`, and existing settings UI seams before editing.

## 2. Desktop Settings Surface

- [x] 2.1 Create or rename the Windows-related settings page to a desktop settings surface using `SettingsPage`, `SettingsSection`, `SettingsNavigationRow`, and `SettingsToggleRow`.
- [x] 2.2 Implement platform-section composition for shared desktop, Windows, and macOS states without introducing lower-layer feature imports; hide the Linux entry/pane by default.
- [x] 2.3 Keep desktop shortcut navigation in the shared desktop section for Windows/macOS and remove Windows-only copy from that shared row.
- [x] 2.4 Keep `windowsCloseToTray` visible and mutable only in the Windows section, using the existing `devicePreferencesProvider` owner.
- [x] 2.5 Migrate `DesktopShortcutsSettingsScreen` to `SettingsPage`, `SettingsSection`, and settings row seams while preserving shortcut capture, reset, duplicate detection, and platform-specific shortcut action behavior.

## 3. Entry Points And Localization

- [x] 3.1 Update the main settings page so Windows/macOS desktop targets use the “桌面设置” semantic entry instead of a Windows-only entry, and Linux does not expose the entry.
- [x] 3.2 Update `DesktopSettingsWindowApp` pane enum, label, neutral `Icons.devices_outlined` icon, and route mapping so the independent settings window renders the same desktop settings surface on Windows/macOS and hides the pane on Linux.
- [x] 3.3 Add or replace i18n keys for desktop settings and desktop shortcut copy while preserving truly Windows-specific permission/lifecycle strings.
- [x] 3.4 Regenerate localization output and verify no stale user-visible “Windows related settings” label remains in desktop settings entry points.

## 4. Guardrails And Tests

- [x] 4.1 Move the migrated desktop settings page and `DesktopShortcutsSettingsScreen` out of the settings UI drift legacy allowlist and into migrated coverage.
- [x] 4.2 Add focused widget tests for Windows and macOS desktop settings sections, plus Linux hidden entry/pane behavior.
- [x] 4.3 Add or update tests covering the main settings entry and desktop settings window pane label/route consistency.
- [x] 4.4 Check that touched public settings files do not introduce commercial terms, paid-feature branching, or `AccessDecision.source` business logic.

## 5. Verification

- [x] 5.1 Run focused settings and architecture tests from `memos_flutter_app`.
- [x] 5.2 Run `flutter analyze` from `memos_flutter_app`.
- [x] 5.3 Run `flutter test` from `memos_flutter_app` or document any environment blocker.
- [x] 5.4 Manually smoke Windows and macOS desktop settings entry points when platform access is available; document Linux as not fully adapted. Windows GUI smoke is not available in this environment; macOS/Linux entry behavior is covered by widget tests, and Linux remains hidden/not fully adapted.
