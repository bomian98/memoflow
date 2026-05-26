## 0. Preparation

- [x] 0.1 Confirm current architecture phase is still `evolve_modularity`.
- [x] 0.2 Confirm implementation does not require API-related files. If `lib/data/api` or `test/data/api` becomes necessary, pause for explicit approval.
- [x] 0.3 Keep settings page behavior unchanged.

## 1. Embedded Utility View Contract

- [x] 1.1 Add a desktop-only home utility view state for sync queue and notifications.
- [x] 1.2 Expose embedded content for `SyncQueueScreen` without standalone top-level AppBar / Back.
- [x] 1.3 Expose embedded content for `NotificationsScreen` without standalone top-level AppBar / Back.

## 2. Desktop Home Integration

- [x] 2.1 Replace homepage memo list / inline compose area with the selected utility content on desktop only.
- [x] 2.2 Route desktop drawer sync queue and notifications actions to the embedded utility view.
- [x] 2.3 Route desktop titlebar notification action and sync queue retry entry to the embedded utility view when inside homepage shell.
- [x] 2.4 Clear drawer selected destination and selected tag path while a utility view is active.
- [x] 2.5 Clear utility view when returning to memos, selecting a tag, or selecting another primary drawer destination.
- [x] 2.6 Add a desktop embedded local back action for sync queue and notifications that returns to the memo list column.
- [x] 2.7 Route desktop utility entries from non-memos drawer pages back through the homepage embedded utility destination.

## 3. Compatibility

- [x] 3.1 Preserve mobile and tablet bottom-navigation behavior.
- [x] 3.2 Preserve standalone `SyncQueueScreen` / `NotificationsScreen` route behavior for non-home contexts.
- [x] 3.3 Preserve sync queue and notification business actions.

## 4. Tests And Guardrails

- [x] 4.1 Add or update focused widget/source tests for desktop embedded sync queue and notifications.
- [x] 4.2 Add or update guardrail coverage so embedded utility views do not own top-level titlebar chrome.
- [x] 4.3 Ensure no API or commercial/private logic is introduced.
- [x] 4.4 Cover desktop embedded back affordance for sync queue and notifications.
- [x] 4.5 Guard that secondary desktop drawer pages use the shared utility destination instead of standalone notification/sync routes.

## 5. Verification

- [x] 5.1 Run focused home / sync / notifications tests.
- [x] 5.2 Run relevant architecture guardrails.
- [x] 5.3 Run `flutter analyze`.
- [x] 5.4 Run `openspec validate embed-desktop-utility-pages-in-home --strict`.
