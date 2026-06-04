## Context

`LocalModeSetupScreen` is a task-like settings page used by local mode flows to collect or rename a local library name. It owns only transient text input, validation message presentation, and returning `LocalModeSetupResult`.

The page currently uses a direct `Scaffold` and manual cards. This batch keeps the behavior and route entry unchanged while replacing page chrome and form presentation with settings seams.

## Goals / Non-Goals

**Goals:**

- Move `LocalModeSetupScreen` to `SettingsPage`, settings section/row components, `SettingsAction`, `settingsPageTokens`, and platform/settings seams.
- Preserve `LocalModeSetupScreen.show`, title/confirm/cancel/subtitle parameters, storage info visibility, trimmed submit result, empty-name snackbar, cancel pop behavior, and debug logging.
- Move `local_mode_setup_screen.dart` from `legacyAllowlist` to `migratedFiles`.
- Update focused tests to verify settings seam usage and existing behavior.

**Non-Goals:**

- No API, route adapter, request/response model, local library repository, database, file path, sync, WebDAV, platform plugin, private hook, or commercial logic changes.
- No migration of `LocalNetworkMigrationScreen`, `memoflow_bridge_screen.dart`, `migration/*`, import/export flows, shortcut flows, or memo toolbar in this batch.
- No broad refactor of local mode flow ownership.

## Decisions

- Use `SettingsPage` for root page chrome and bounded content, with `desktopMaxWidth`/`tabletMaxWidth` tuned to the current 560px task form.
- Use `SettingsSection` and `SettingsInfoRow` for subtitle/storage info text so the page stays inside settings grouped surfaces.
- Use `SettingsInputRow` for repository name input to keep form styling in the settings seam.
- Use `SettingsAction` for confirm and cancel actions. Keep button labels from the widget parameters.
- Preserve `MaterialPageRoute` in `LocalModeSetupScreen.show`, because this batch is not changing route presentation policy for calling flows.
- Shrink the drift guardrail allowlist immediately after runtime migration.

## Risks / Trade-offs

- `SettingsInputRow` may render the text field differently from the old card. Mitigation: focused tests cover storage info, subtitle, text input, submit result, and empty validation.
- Empty-name validation still uses `ScaffoldMessenger`; `SettingsPage` provides the underlying page scaffold through platform page composition. Mitigation: run focused widget tests.
- This batch does not reduce drift in larger local migration screens. Mitigation: leave those screens allowlisted for dedicated future batches.
