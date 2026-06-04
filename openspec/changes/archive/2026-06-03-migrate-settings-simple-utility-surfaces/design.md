## Context

`TemplateSettingsScreen` and `WidgetsScreen` are small settings surfaces:

- `TemplateSettingsScreen` renders template enablement, template list management, variable settings, and variable documentation while delegating state to `memoTemplateSettingsProvider`.
- `WidgetsScreen` renders home widget previews and delegates one-tap widget pinning to `HomeWidgetService`.

Both pages duplicate settings page chrome and local visual styling that now exists in `settings_ui.dart`. This batch keeps behavior in current owners and only changes presentation composition inside the settings feature files.

## Goals / Non-Goals

**Goals:**

- Move both pages to `SettingsPage`, `SettingsSection`, settings row/action components, `settingsPageTokens`, and theme/platform seams where applicable.
- Preserve template enablement, template editor/delete dialogs, variable settings dialog, variable docs dialog, widget preview text/layout, Android support gate, toast messages, package version footer, and existing service/provider calls.
- Move `template_settings_screen.dart` and `widgets_screen.dart` from `legacyAllowlist` to `migratedFiles`.
- Add focused widget coverage that verifies settings seam usage and representative interactions without running real home widget pinning or storage writes.

**Non-Goals:**

- No API, route adapter, request/response model, template repository/model/provider, sync coordinator, home widget service, package info implementation, platform channel, private hook, or commercial logic changes.
- No desktop routing/window, AI settings, import/export migration, QR migration/bridge routing, donation dialog, shortcut editor, or memo toolbar changes.
- No broad refactor of template editing/variable dialog internals beyond removing page-level drift that would break the migrated guardrail.

## Decisions

- Use `SettingsPage` for root page chrome on both pages. It centralizes background, dark gradient, bounded content, app bar leading behavior, and platform page behavior.
- Use `SettingsToggleRow` for template enablement and `SettingsNavigationRow` / `SettingsInfoRow` for variable entries and empty/helper states.
- Keep template cards as settings-section rows using `SettingsSelectableItemRow` or an equivalent row composition because the edit/delete affordances are item-specific and already have localized tooltips.
- Keep widget previews page-local because they are literal previews of generated home widgets, but resolve page colors/action styling through `settingsPageTokens`, `ThemeData`, `ColorScheme`, or `SettingsAction` instead of direct `MemoFlowPalette`.
- Keep dialogs page-local because they are behavior-specific overlays. Dialog table/preview styling may use theme-derived colors; it must not use direct `MemoFlowPalette`.
- Shrink the drift guardrail allowlist immediately after runtime migration, so reintroducing direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard` is caught.

## Risks / Trade-offs

- `TemplateSettingsScreen` has several dialogs with table/editor UI. Mitigation: migrate page chrome and rows first, then remove direct palette/switch usage in dialog helpers only where required by the migrated-file guardrail; keep dialog validation and provider calls unchanged.
- `WidgetsScreen` contains custom previews that intentionally use page-local graphics. Mitigation: allow preview-specific colors from `ThemeData` / `ColorScheme` and constants, but remove shared settings chrome/card/action palette drift.
- `WidgetsScreen` can call platform channels when add is tapped on Android. Mitigation: focused tests run on the default non-Android target or exercise only unsupported-target toast; runtime `HomeWidgetService` code remains unchanged.
- This batch improves settings UI modularity but does not fix known AI, desktop, import/export, shortcut, QR, donation, or migration surfaces. Mitigation: preserve existing active-change boundaries and leave those pages allowlisted for dedicated future batches.
