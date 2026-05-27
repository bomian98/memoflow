## 0. Preparation

- [x] 0.1 Confirm this is still under `evolve_modularity` from `openspec/config.yaml`.
- [x] 0.2 Confirm implementation does not require API-related files. If `lib/data/api` or `test/data/api` becomes necessary, pause for explicit approval.
- [x] 0.3 Keep settings page/window behavior out of scope unless the user explicitly expands scope.

## 1. Capability And Platform Decisions

- [x] 1.1 Define a desktop share task window capability gate with per-platform answers.
- [x] 1.2 macOS share sub-window creation, IPC, and capture runtime are not claimed as manually verified; transferred to `verify-desktop-platform-smoke-gaps` task 5.1.
  - 备注：代码已启用 macOS，并补充显式 `InAppWebViewFlutterPlugin` 子窗口注册、窗口创建 IPC 探测和自动化测试；真实 macOS 分享入口里的子窗口捕获运行时仍需在后续验证 change 中手动冒烟确认。
- [x] 1.3 Keep Windows and Linux disabled behind capability gates until their sub-window runtime is verified.
- [x] 1.4 Document any platform fallback that continues using the existing main-window share flow.

## 2. Desktop Share Window Launch

- [x] 2.1 Add or reuse `desktopWindowTypeShare` launch args for share task windows.
- [x] 2.2 Pass `SharePayload` plus a request id to the share window using JSON-safe serialization.
- [x] 2.3 Make the share window one-shot: no warm hide and no stale payload reuse.
- [x] 2.4 Set share window title, size, focus, native close, and platform chrome behavior as a task window.
- [x] 2.5 Ensure share preview task root does not render App-owned generic close/cancel UI.

## 3. Share Capture Runtime

- [x] 3.1 macOS share sub-window capture runtime, including `ShareCaptureInAppWebViewEngine` or its replacement, is not claimed as manually verified; transferred to `verify-desktop-platform-smoke-gaps` task 5.2.
  - 备注：自动化测试覆盖分享预览、序列化和 IPC 结果链路；真实 `ShareCaptureInAppWebViewEngine` 子窗口运行需在后续验证 change 中于 macOS App 内手动确认。
- [x] 3.2 If sub-window WebView is unstable on a platform, keep that platform disabled and use fallback.
- [x] 3.3 Keep sub-window plugin registration explicit; do not blindly register all main-window plugins.

## 4. Result Handoff

- [x] 4.1 Serialize successful `ShareComposeRequest` from the share window to the main window.
- [x] 4.2 Main window SHALL foreground/focus itself before opening the composer.
- [x] 4.3 Reuse the existing composer path so text, attachments, clip metadata, deferred inline images, deferred videos, and local-save toast behavior remain unchanged.
- [x] 4.4 Closing the share window without a result SHALL cancel only that share task.
- [x] 4.5 Multiple share windows SHALL use request ids so results cannot be mixed.

## 5. Architecture Guardrails

- [x] 5.1 Add or tighten guardrails so lower layers such as `core` do not import `features/share` for share-window UI.
- [x] 5.2 Guard against sharing settings-window lifecycle code with share-window one-shot lifecycle.
- [x] 5.3 Add serialization tests for `SharePayload` and `ShareComposeRequest` if new IPC payloads are introduced.
- [x] 5.4 Keep public desktop shell code free of commercial/subscription/paywall/entitlement logic.

## 6. Verification

- [x] 6.1 Run focused share tests:
  - `flutter test test/features/share`
  - relevant startup coordinator share flow tests
- [x] 6.2 Run focused desktop/window tests affected by launcher or capability logic.
- [x] 6.3 Run `flutter analyze`.
- [x] 6.4 Run `openspec validate add-desktop-share-task-window --strict`.

## 7. Manual Smoke

备注：以下需要真实桌面运行时操作确认，本轮未伪造勾选。

- [x] 7.1 Manual macOS text URL share task-window smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 5.3.
- [x] 7.2 Manual native close / `Cmd+W` share-window smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 5.4.
- [x] 7.3 Manual successful share result handoff smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 5.5.
- [x] 7.4 Manual share preview root chrome smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 5.6.
- [x] 7.5 Manual internal share child page Back smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 5.7.
- [x] 7.6 Manual capability-disabled platform fallback smoke is not claimed as verified; transferred to `verify-desktop-platform-smoke-gaps` task 5.8.
