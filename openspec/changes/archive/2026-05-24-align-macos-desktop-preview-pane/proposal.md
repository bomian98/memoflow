## Why

Windows desktop home already uses a two-tier preview-pane model: an expanded desktop width can support the right-side memo preview pane, and a wider desktop width makes memo click open or update that pane by default. macOS currently has the same preview implementation paths in code, but the effective width policy is stricter and still relies on a separate legacy desktop preview breakpoint. This makes macOS feel inconsistent: a window size that behaves like a desktop preview layout on Windows can still navigate directly to detail on macOS.

We want macOS desktop home to follow the same memo preview behavior model as Windows while keeping macOS-specific shell chrome, traffic-light handling, and titlebar behavior intact. This is desktop interaction alignment, not a request to copy Windows window controls or command-bar chrome onto macOS.

The repository is in `evolve_modularity`. This change touches `features/memos`, desktop layout policy, and desktop shell behavior, so the implementation should reduce Windows-only layout gating and express the behavior through a shared desktop preview policy.

## What Changes

- Introduce or clarify a shared desktop memo-list layout policy for preview-pane support and default click behavior.
- macOS desktop home SHALL support the right-side memo preview pane at the same expanded desktop threshold as Windows.
- macOS desktop home SHALL use memo-click-to-preview by default at the same wide desktop threshold as Windows.
- Windows desktop behavior SHALL remain unchanged.
- macOS titlebar, traffic-light safe area, native window controls, and hybrid titlebar behavior SHALL remain macOS-specific and MUST NOT become Windows-style.
- Focused tests SHALL cover the shared policy and the macOS behavior at the aligned thresholds.

## Capabilities

### Modified Capabilities

- `desktop-shell-host-boundary`: desktop memo list preview-pane behavior becomes a shared desktop layout policy rather than a Windows-only or legacy macOS breakpoint.

## Impact

- Expected affected code:
  - `memos_flutter_app/lib/core/platform_layout.dart`
  - `memos_flutter_app/lib/features/memos/memos_list_screen_view_state.dart`
  - `memos_flutter_app/lib/features/memos/widgets/memos_list_screen_body.dart` if shell composition needs adjustment
  - focused tests under `memos_flutter_app/test/core/` and `memos_flutter_app/test/features/memos/`
- No API request/response model, route adapter, or server compatibility behavior is expected to change.
- No subscription, billing, entitlement, StoreKit, paywall, or private/commercial behavior is in scope.

## Non-Goals

- Do not redesign the macOS titlebar.
- Do not replace native macOS traffic lights with Flutter-drawn window controls.
- Do not change Windows preview-pane thresholds or interaction semantics.
- Do not create macOS-only memo selection state or duplicate feature page trees.
- Do not alter memo detail rendering or Markdown preview behavior.
