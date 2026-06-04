## Context

`ApiPluginsScreen` and `WebhooksSettingsScreen` are settings surfaces over existing integration behavior:

- `ApiPluginsScreen` reads the current account from `appSessionProvider`, calls existing personal access token API methods through `memosApiProvider`, and persists one-time token values through `personalAccessTokenRepositoryProvider`.
- `WebhooksSettingsScreen` watches `userWebhooksProvider` and calls existing webhook API methods through `memosApiProvider`.

Both pages duplicate settings page chrome and local visual styling that now exists in `settings_ui.dart`. This batch keeps behavior in the current owners and only changes presentation composition inside the settings feature files.

## Goals / Non-Goals

**Goals:**

- Move both integrations pages to `SettingsPage`, `SettingsSection`, existing settings row components, `settingsPageTokens`, and theme/platform seams.
- Preserve token and webhook behavior exactly at the provider/API seam: create/copy/refresh tokens, add/edit/delete webhooks, invalidation, toasts, dialogs, bottom sheets, and error messages.
- Move `api_plugins_screen.dart` and `webhooks_settings_screen.dart` from `legacyAllowlist` to `migratedFiles`.
- Add focused widget coverage that verifies settings seam usage and representative user interactions without real network calls.

**Non-Goals:**

- No API, model, repository, route adapter, version compatibility, or provider behavior changes.
- No desktop routing/window, AI settings, import/export, migration, shortcut editor, memo toolbar, private hook, or commercial logic changes.
- No broad refactor of integration business logic out of these screens unless required to support a focused UI seam test.

## Decisions

- Use `SettingsPage` for root page chrome on both pages. It already centralizes background, dark gradient, bounded content, app bar leading behavior, and platform page behavior.
- Use `SettingsSection` and existing `SettingsInputRow`, `SettingsMenuRow`, `SettingsInfoRow`, `SettingsNavigationRow`, or a small shared settings action row if needed, instead of local rounded card/group containers.
- Keep token/webhook dialogs and token-created sheet page-local because they are interaction-specific overlays. Their visual decisions SHALL use theme colors or `settingsPageTokens`; they SHALL NOT use direct `MemoFlowPalette` in migrated files.
- Keep token status badge page-local because it encodes token expiry UI state, but use `Theme.of(context).colorScheme` colors rather than palette constants.
- Preserve API/provider calls exactly where they are. If tests need fake behavior, override providers in tests rather than changing runtime owners.
- Shrink the drift guardrail allowlist immediately after runtime migration, so reintroducing direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard` is caught.

## Risks / Trade-offs

- Token API screens have asynchronous initial refresh behavior. Mitigation: focused tests should override providers/repositories and assert rendered seam structure without relying on real storage or network.
- Webhook provider may load/error/empty depending on overrides. Mitigation: test at least empty or loaded state and representative edit/delete affordances through provider overrides.
- Existing overlay dialogs and bottom sheets are not fully normalized by settings seams. Mitigation: keep them scoped and theme-based, and cover page-level drift with guardrail.
- This batch improves settings UI modularity but does not address known reverse dependency hotspots. Mitigation: record that the touched area is not one of those hotspots and avoid adding any new lower-layer imports.
