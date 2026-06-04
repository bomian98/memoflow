## Context

`ExportLogsScreen` and `SelfRepairScreen` are support settings surfaces:

- `ExportLogsScreen` reads/writes UI-local include flags, reads device preferences for network logging, and delegates report generation/export/clearing to existing logging providers and stores.
- `SelfRepairScreen` presents three maintenance actions and delegates actual mutations to `selfRepairMutationServiceProvider`.

Both pages duplicate settings page chrome and local visual styling that now exists in `settings_ui.dart`. This batch keeps behavior in current owners and only changes presentation composition inside the settings feature files.

## Goals / Non-Goals

**Goals:**

- Move both utility/support pages to `SettingsPage`, `SettingsSection`, settings row components, `settingsPageTokens`, and theme/platform seams.
- Preserve log export/clear behavior, self repair confirmation/mutation behavior, haptics, toast/snackbar, clipboard copy, local state flags, and device preference updates.
- Move `export_logs_screen.dart` and `self_repair_screen.dart` from `legacyAllowlist` to `migratedFiles`.
- Add focused widget coverage that verifies settings seam usage and representative interactions without running real file export or database repair mutations.

**Non-Goals:**

- No API, model, repository, route adapter, database repair, logging provider, WebDAV, path provider, or file output behavior changes.
- No desktop routing/window, AI settings, import/export migration, QR migration/bridge routing, donation dialog, private hook, or commercial logic changes.
- No broad refactor of self repair service or log report generation.

## Decisions

- Use `SettingsPage` for root page chrome on both pages. It centralizes background, dark gradient, bounded content, app bar leading behavior, and platform page behavior.
- Use `SettingsSection`, `SettingsToggleRow`, `SettingsInputRow` or a small page-local/theme-token row helper for note entry and action rows.
- Keep confirmation dialogs page-local because they are behavior-specific overlays, but they SHALL use normal theme/button components and SHALL NOT use direct `MemoFlowPalette`.
- Preserve provider/service calls exactly where they are. Tests should focus on UI seam and safe interactions; they should not require real filesystem export or database repair.
- Shrink the drift guardrail allowlist immediately after runtime migration, so reintroducing direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard` is caught.

## Risks / Trade-offs

- `ExportLogsScreen` has file-system side effects when export is tapped. Mitigation: focused tests assert UI seam and toggles/copy row without triggering real export; runtime implementation preserves export code unchanged.
- `SelfRepairScreen` can mutate derived data after confirmation. Mitigation: tests only open confirmation dialog unless a fake service seam is already practical; runtime service calls stay unchanged.
- Some helper rows may remain page-local to represent running/disabled action state. Mitigation: helper rows must render through `PlatformListSectionRow`, `settingsPageTokens`, and theme colors.
- This batch improves settings UI modularity but does not fix known reverse dependency hotspots. Mitigation: preserve existing service/provider owners and avoid adding any new lower-layer imports.
