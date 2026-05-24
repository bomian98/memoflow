## 1. Policy and scope

- [x] 1.1 Confirm whether the shared desktop preview policy applies to Windows + macOS only, or all desktop targets including Linux.
- [x] 1.2 Identify and document any remaining legitimate use of `kMemoFlowDesktopPreviewPaneBreakpoint = 1440` before changing home memo preview behavior.

## 2. Shared desktop preview layout policy

- [x] 2.1 Add or refactor a desktop-neutral layout policy that expresses `supportsPreviewPane` at `width >= 1200`.
- [x] 2.2 Add or refactor a desktop-neutral layout policy that expresses `defaultMemoClickOpensPreview` at `width >= 1360`.
- [x] 2.3 Keep Windows shell navigation and window-control policy separate from shared memo preview policy.

## 3. Memo list behavior

- [x] 3.1 Update `buildMemosListScreenLayoutState` so macOS uses the shared preview support/default-click tiers.
- [x] 3.2 Preserve Windows current behavior at narrow, compact, expanded, and wide widths.
- [x] 3.3 Ensure macOS wide memo clicks open/update `MemosListDesktopPreviewPane` and do not navigate directly to `MemoDetailScreen`.
- [x] 3.4 Ensure macOS expanded width supports the pane without forcing default click-to-preview unless the pane is already active or explicitly opened.

## 4. Verification

- [x] 4.1 Add focused layout-policy tests for macOS at `1199`, `1200`, `1359`, and `1360`.
- [x] 4.2 Add or update widget tests proving macOS `1360` wide layout opens the desktop preview pane on memo tap.
- [x] 4.3 Add or update tests proving macOS `1200..1359` supports preview-pane state without defaulting ordinary memo taps to detail-breaking behavior beyond the agreed rule.
- [x] 4.4 Re-run existing Windows desktop preview tests to prove behavior is unchanged.
- [x] 4.5 Run `flutter analyze` and the relevant focused Flutter tests from `memos_flutter_app`.

## 5. Guardrails

- [x] 5.1 Check changed files for private/commercial, billing, subscription, StoreKit, entitlement, paywall, or `AccessDecision.source` business branching before commit.
- [x] 5.2 Ensure the implementation does not add new lower-layer imports from `features/memos`.
