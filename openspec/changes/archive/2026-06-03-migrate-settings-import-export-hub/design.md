## Context

`ImportExportScreen` is a settings hub that routes to existing import/export/migration flows:

- Export entry opens `ExportMemosScreen`.
- Import file entry opens `ImportSourceScreen`.
- Local Network Migration entry opens `LocalNetworkMigrationScreen`.

The page currently duplicates settings chrome and card styling through direct palette colors and page-local group composition. This batch keeps the target flows unchanged and only changes presentation composition in the hub.

## Goals / Non-Goals

**Goals:**

- Move `ImportExportScreen` to `SettingsPage`, `SettingsSection`, `SettingsNavigationRow`, `settingsPageTokens`, and platform/settings seams.
- Preserve `showBackButton`, haptic behavior, route construction through `buildPlatformPageRoute`, target screens, labels, values, and existing tests' navigation expectations.
- Move `import_export_screen.dart` from `legacyAllowlist` to `migratedFiles`.
- Update focused tests so the hub seam and representative navigation remain covered.

**Non-Goals:**

- No API, route adapter, request/response model, export/import/local migration implementation, path/file conversion, WebDAV, platform plugin, private hook, or commercial logic changes.
- No migration of `ExportMemosScreen`, `import_export_shared_widgets.dart`, `LocalNetworkMigrationScreen`, `memoflow_bridge_screen.dart`, or `migration/*` in this batch.
- No broad refactor of import/export flows or local migration ownership.

## Decisions

- Use `SettingsPage` for root page chrome. It centralizes background, dark gradient, bounded content, app bar leading behavior, and platform page behavior.
- Use one `SettingsSection` per hub category, with `SettingsNavigationRow` for each route target.
- Use existing `buildPlatformPageRoute` calls for navigation to avoid changing platform route behavior.
- Keep haptic behavior as a small local function reading `devicePreferencesProvider`, because it is presentation feedback already owned by the current hub.
- Shrink the drift guardrail allowlist immediately after runtime migration, so reintroducing direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard` is caught.

## Risks / Trade-offs

- `ImportExportScreen` shares visual helper widgets with larger import/export flows. Mitigation: this batch stops at the hub and does not edit shared import/export widgets or flow screens.
- Existing tests navigate into larger flows. Mitigation: preserve target routes exactly and add seam assertions before navigation.
- This batch does not reduce drift in `ExportMemosScreen`, `import_export_shared_widgets.dart`, or migration screens. Mitigation: leave those files allowlisted for dedicated future batches.
