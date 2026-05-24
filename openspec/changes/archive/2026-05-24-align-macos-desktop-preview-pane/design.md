## Context

Current desktop memo preview behavior is mostly shared in state and UI:

```text
MemosListScreen
  ├─ DesktopHomePaneState
  ├─ DesktopMemoPreviewSession
  ├─ MemosListDesktopPreviewPane
  └─ MemosListDesktopSplitLayout / DesktopShellHost slots
```

The mismatch is layout policy:

```text
Windows:
  1200 <= width < 1360   expanded: supports secondary pane
  width >= 1360          wide: click memo opens/updates preview by default

macOS:
  width >= 1440          legacy desktop preview breakpoint
```

The desired behavior is not "macOS becomes Windows shell". It is:

```text
shared desktop memo preview policy
  ├─ expanded threshold: supports right-side preview pane
  └─ wide threshold: memo click opens/updates preview pane by default

platform shell policy
  ├─ Windows: Windows command bar/window controls
  └─ macOS: native traffic lights + macOS titlebar/chrome semantics
```

## Decision: shared desktop preview tiers

Use a shared desktop preview layout policy, either by extracting a new desktop-neutral helper or by refactoring the current Windows tier helper so the preview-specific parts are not Windows-only.

Recommended semantic model:

```text
DesktopMemoListLayoutTier
  narrow    < 960
  compact   960..1199
  expanded  1200..1359   supportsPreviewPane = true
  wide      >= 1360      supportsPreviewPane = true
                           defaultMemoClickOpensPreview = true
```

The exact names may differ, but the implementation should make these semantics explicit:

| Behavior | Windows | macOS |
| --- | --- | --- |
| Supports right-side preview pane | `width >= 1200` | `width >= 1200` |
| Memo click opens/updates preview by default | `width >= 1360` | `width >= 1360` |
| Platform titlebar/window controls | Windows-specific | macOS-specific |

This means the existing `kMemoFlowDesktopPreviewPaneBreakpoint = 1440` should no longer be the macOS home preview gate. It may remain for unrelated legacy helpers only if documented, but the home memo preview behavior should use the shared desktop policy.

## Interaction model

```text
macOS expanded desktop width (1200..1359)
┌────────────┬───────────────────────────────┐
│ sidebar    │ memo list                      │
│            │                               │
│            │ [preview toggle available if  │
│            │  surfaced by current toolbar] │
└────────────┴───────────────────────────────┘

macOS wide desktop width (>=1360)
┌────────────┬──────────────────────┬──────────────┐
│ sidebar    │ memo list            │ preview pane  │
│            │ click memo updates ─▶│ selected memo │
└────────────┴──────────────────────┴──────────────┘
```

Clicking a memo in macOS wide layout SHALL select the memo and open/update the right-side preview pane instead of navigating directly to `MemoDetailScreen`. Double-click and explicit detail actions may continue to open detail according to existing desktop memo-list behavior.

In macOS expanded layout, the pane is supported but not necessarily the default click target unless it is already open or the user activates an available preview toggle. This mirrors the Windows expanded/wide distinction.

## Modularity

This should improve the touched area by removing or isolating a Windows-only preview policy:

```text
core/platform_layout.dart
  └─ shared desktop preview layout policy

features/memos/memos_list_screen_view_state.dart
  └─ consumes shared policy and decides feature layout state

features/memos/widgets
  └─ renders platform-appropriate shell/body slots
```

Rules:

- Preview support and default click behavior are desktop-common layout semantics.
- Native titlebar/chrome, traffic-light safe area, and Windows caption controls remain platform shell semantics.
- `state`, `application`, and lower layers MUST NOT import `features/memos` to support this change.
- No commercial/private code paths may be introduced.

## Risks / Trade-offs

- [Risk] At 1200..1359 macOS may have less horizontal room than the previous 1440 gate.  
  Mitigation: expanded tier supports the pane but does not have to default memo clicks to preview; wide tier starts at 1360.

- [Risk] Reusing a Windows-named helper would preserve confusing architecture.  
  Mitigation: prefer desktop-neutral names for preview-specific policy, while leaving Windows shell chrome policy Windows-specific.

- [Risk] macOS titlebar work from `move-macos-quick-actions-to-titlebar` could be conflated with preview-pane behavior.  
  Mitigation: keep this change scoped to memo preview layout tiers and interaction; do not modify titlebar design except where an existing toolbar action needs to expose the preview toggle.

## Open Questions

- [Resolved] macOS expanded width does not need a new visible preview toggle in this change. Existing state/context support is enough for the first implementation; toolbar/titlebar affordance can be handled separately if needed.
- [Resolved] This change aligns Windows and macOS home memo preview behavior only. Linux remains on the existing legacy desktop preview helper unless a separate OpenSpec change explicitly brings Linux into the shared expanded/wide preview tier.

## Legacy breakpoint note

`kMemoFlowDesktopPreviewPaneBreakpoint = 1440` may remain as a legacy generic desktop preview breakpoint for non-home or not-yet-aligned surfaces, such as Explore, and for platforms outside this change's Windows/macOS scope. The home memo list MUST NOT use that legacy breakpoint to gate macOS right-side preview support or default click-to-preview behavior.
