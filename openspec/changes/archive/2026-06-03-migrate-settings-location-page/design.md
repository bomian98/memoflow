## Context

`LocationSettingsScreen` is a settings surface over an existing provider-owned state. The current implementation duplicates settings page chrome and card/list geometry locally. It also defines `_ToggleCard`, `_Group`, `_ProviderRow`, `_InputRow`, and `_PrecisionRow` to render controls that map cleanly to existing settings UI seams.

This change keeps all location behavior in existing owners and only changes presentation composition inside the settings feature file.

## Decisions

- Use `SettingsPage` for page chrome and `SettingsSection` for grouped controls.
- Replace `_ToggleCard` with `SettingsToggleRow`.
- Replace `_ProviderRow` with `SettingsMenuRow<LocationServiceProvider>` to keep dropdown semantics without local card styling.
- Replace `_InputRow` with `SettingsInputRow`.
- Keep a small `_PrecisionRow` page-local helper because precision is a segmented/choice-chip control, but it must use `settingsPageTokens` / theme colors instead of `MemoFlowPalette`.
- Add focused widget tests with a fake `LocationSettingsController` override, so tests assert UI interactions without touching real storage or provider persistence.

## Risks

- The page uses text controllers and a manual provider subscription; migration must preserve `_dirty` behavior so local edits are not overwritten by provider updates during editing.
- Provider-specific input fields are conditional; tests should cover at least provider switching and one provider-specific text input.
- `ChoiceChip` visual style can stay page-local, but direct palette usage must be removed for drift guardrail compliance.

## Alternatives

- Migrate broader location picker / geocoder flows: rejected because this batch is UI-only and must not move behavior out of current owners.
- Migrate import/export or WebDAV config transfer alongside location settings: rejected because those are behavior-heavy and can touch sync/application owners.
