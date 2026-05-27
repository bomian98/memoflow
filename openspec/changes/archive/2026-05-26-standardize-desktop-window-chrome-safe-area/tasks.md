## 0. Preparation

- [x] 0.1 Confirm current architecture phase is still `evolve_modularity` from `openspec/config.yaml`.
- [x] 0.2 Confirm implementation does not require API-related files. If `lib/data/api` or `test/data/api` becomes necessary, pause for explicit approval.
- [x] 0.3 Keep settings page/window behavior stable unless a focused safe-area regression requires a minimal shell-level fix.

## 1. Desktop Chrome Inventory

- [x] 1.1 Inventory desktop windows and shell roots that can render top-leading content near native/custom window controls: main macOS shell, settings window, quick input window, share task window, login/onboarding, and other desktop task roots.
- [x] 1.2 Classify which surfaces already consume `resolveDesktopWindowChromeInsets` or an equivalent shared safe-area seam.
- [x] 1.3 Document explicit exclusions for surfaces that use a native frame or do not draw Flutter content near window controls.

## 2. Shared Safe-Area Shell

- [x] 2.1 Add or reuse a shared desktop chrome shell/wrapper, such as `DesktopWindowChromeScaffold` or `DesktopTaskWindowShell`, that consumes centralized chrome metrics.
- [x] 2.2 Keep all macOS traffic-light / Windows caption-control geometry in `core/desktop` or an equivalent lower-layer-safe policy seam.
- [x] 2.3 Ensure the shared shell supports non-macOS fallback without applying macOS traffic-light leading inset to Windows, Linux, mobile, or web layouts.
- [x] 2.4 Ensure the shared shell does not render App-owned generic close/cancel UI by default; close/cancel/back remain task semantics supplied by the consumer.

## 3. Share Task Window Consumer

- [x] 3.1 Migrate share task window root to consume the shared desktop chrome safe-area shell.
- [x] 3.2 Ensure the share root title, optional internal Back affordance, status content, and first top-leading controls do not overlap macOS traffic lights.
- [x] 3.3 Preserve share task root semantics: native close cancels the task, and no App-owned generic close/cancel UI is rendered.
- [x] 3.4 Preserve internal child-page Back behavior, such as video preview returning to the share task root.

## 4. Existing Surface Compatibility

- [x] 4.1 Verify main macOS shell and settings window continue using the centralized safe-area seam without visual or navigation regressions.
- [x] 4.2 If inventory finds another desktop root with title/control overlap, migrate it to the shared shell or document why it should remain out of scope.
- [x] 4.3 Avoid broad settings page rewrites; any settings touch must stay shell-level and behavior-preserving.
- [x] 4.4 Migrate stats, sync queue, and notifications desktop page roots to consume the shared chrome safe-area seam without changing settings page behavior.

## 5. Guardrails And Tests

- [x] 5.1 Add or update core desktop chrome safe-area tests for macOS reserved inset and non-macOS fallback.
- [x] 5.2 Add a focused share task window widget/layout test proving top-level title/content uses the shared chrome safe-area rule.
- [x] 5.3 Add or tighten architecture/source guardrail coverage so new desktop task window roots do not bypass the shared safe-area seam with page-local traffic-light magic padding.
- [x] 5.4 Keep public desktop shell code free of StoreKit, subscription, entitlement, receipt, paywall, billing, or other commercial logic.

## 6. Verification

- [x] 6.1 Run `flutter analyze`.
- [x] 6.2 Run focused desktop/window tests affected by chrome safe-area logic.
- [x] 6.3 Run focused share tests affected by the share task window root wrapper.
- [x] 6.4 Run relevant architecture guardrails.
- [x] 6.5 Run `openspec validate standardize-desktop-window-chrome-safe-area --strict`.
- [x] 6.6 Run focused verification for the expanded stats / sync queue / notifications chrome safe-area consumers.

## 7. Manual Smoke

备注：macOS 已完成真实桌面运行时操作确认，未发现问题；Windows/Linux 和其他桌面端本轮未测试。

- [x] 7.1 On macOS, open a share task window and confirm the title/top-leading content does not overlap red/yellow/green traffic lights.
- [x] 7.2 On macOS, confirm share task native close / `Cmd+W` still cancels only the share task and does not show App-owned close/cancel UI.
- [x] 7.3 On macOS, confirm settings window behavior remains visually and navigationally unchanged except for any safe-area preservation already present.
- [x] 7.4 已记录：Windows/Linux 和其他桌面端本轮未测试；后续声明跨桌面覆盖前仍需另行验证。
