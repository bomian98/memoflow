## Context

现有桌面子窗口入口在 `main.dart` 中按 `desktopWindowTypeKey` 分发：

```text
desktop_multi_window launch args
  ├─ quick_input  -> DesktopQuickInputWindowApp
  └─ settings     -> DesktopSettingsWindowApp
```

分享预览当前不是子窗口，而是在主窗口 navigator 中 push `ShareClipScreen`，再通过 `Navigator.pop(ShareComposeRequest)` 交回主窗口继续打开编辑/输入流程。

这导致分享预览同时拥有两种身份：

```text
代码身份：main-window secondary route
用户心智：一次性分享任务 root
```

后续目标是把它改成真正的 desktop task window：

```text
incoming share payload
  │
  ▼
DesktopShareWindowLauncher
  ├─ capability supported
  │     └─ create one-shot share task window
  └─ capability unsupported / launch failed
        └─ fallback to existing main-window share flow
```

## Decision: common seam, staged platform enablement

采用桌面通用 seam，而不是 macOS-only 特例：

```text
DesktopShareWindowCapability
  ├─ macOS: first enable target after sub-window runtime is verified
  ├─ Windows: enable after WebView/plugin capability is verified
  └─ Linux: enable after platform support is verified
```

第一阶段可以只让 macOS 走新窗口，但代码结构 SHOULD 直接面向 all desktop platforms。Windows/Linux 不应复制另一套分享窗口流程，只应通过 capability gate 打开或 fallback。

## Native Close Model

分享窗口关闭采用平台原生窗口语义：

```text
native close / Cmd+W / Alt+F4 / taskbar close
  -> cancel current share task window
  -> main window remains alive
  -> no main-window route pop
```

分享窗口 SHALL NOT 自绘 generic close/cancel UI。现有“保存备忘录”“仅使用链接”“重试”“下载并附加”等任务动作可以保留，因为它们不是 generic window close/cancel。

如果分享窗口内部再打开子页面，例如视频预览，则子页面 MAY 使用 App-level Back 返回分享预览。Back 只属于分享窗口内部 navigation，不代表关闭整个分享任务。

## Dependency: Desktop Chrome Safe Area

分享任务窗口会保留平台原生窗口控件，因此 Flutter 顶层内容不能假设窗口左上角完全可用。截图中的标题与 macOS traffic lights 重叠，属于 desktop window chrome safe-area 问题，但通用规则不应由本分享窗口 change 承担。

通用规则、shared shell/policy、跨窗口 guardrail 和其他页面迁移由 `standardize-desktop-window-chrome-safe-area` 跟踪。本 change 只表达消费关系：

```text
Share task window root
  └─ consumes desktop-window-chrome-safe-area shared rule
       ├─ no page-local magic padding
       ├─ no App-owned generic close/cancel UI
       └─ native close still cancels only this share task
```

## Result Handoff

分享窗口不直接打开主窗口编辑器。它应通过 `DesktopMultiWindow.invokeMethod(0, ...)` 或后续 shared IPC seam 把结构化结果发给主窗口。

```text
Share task window
  └─ ShareComposeRequest result
       ▼
Main window method handler
  ├─ validate request id / payload shape
  ├─ foreground main window
  ├─ open existing composer path
  └─ acknowledge result
       ▼
Share task window closes itself
```

主窗口继续复用现有 composer 行为，保留：

- text / selection
- attachments
- clip metadata
- deferred inline image attachments
- deferred video attachments
- `showLocalSaveSuccessToast`

## WebView Strategy

`ShareClipScreen` 默认依赖 `ShareCaptureInAppWebViewEngine`，后者使用 `flutter_inappwebview` / headless WebView。桌面子窗口是否能稳定运行该能力必须按平台验证。

优先验证方案 A：

| Option | Result | Trade-off |
| --- | --- | --- |
| A. 分享窗口自己运行 `ShareCaptureInAppWebViewEngine` | 窗口自包含，模型最直接 | 需要子窗口安全注册 WebView 插件 |
| B. 主窗口运行捕获，分享窗口显示状态/结果 | 避免子窗口 WebView 风险 | IPC 状态同步更复杂 |
| C. 保持旧主窗口 route fallback | 风险最低 | 该平台体验暂时不统一 |

推荐顺序：先验证 A。如果某个平台 A 不稳定，则该平台 capability 暂时走 C；必要时后续再设计 B。

## Multi-Share Behavior

第一版 SHOULD 允许多个分享任务窗口并行。每个窗口持有独立 request id，结果回传时由主窗口按 request id 独立处理。

不建议第一版做队列或替换当前分享窗口，因为这会引入额外状态机，也更容易造成 payload/result 串线。

## Dependency Direction And Modularity

当前相关热点：

```text
application/startup
  └─ imports features/share for ShareClipScreen and ShareComposeRequest
```

目标不是立刻完成大重构，而是在 touched area equal or better structured：

```text
application/startup
  └─ asks application/desktop share launcher to open supported task window

application/desktop share seam
  ├─ owns capability, window creation, IPC method names
  └─ does not import feature UI from core/lower layers

features/share
  ├─ owns share UI and share payload/result mapping
  └─ may provide JSON-safe serialization helpers if needed
```

Guardrail 要求：

- `core` 不新增对 `features/share`、`application/startup`、state 的向上依赖。
- 设置窗口不复用分享窗口 lifecycle，也不因本 change 变化。
- 如果修改 sub-window plugin registration，必须保持 explicit allowlist，不能为了方便盲目调用完整主窗口插件注册。
- 不引入商业化、订阅、支付、entitlement、StoreKit 等逻辑。

## Risks

- [Risk] macOS/Windows/Linux 子窗口不能稳定运行 `HeadlessInAppWebView`。  
  Mitigation: platform capability gate；失败时 fallback 到现有主窗口分享流程。

- [Risk] 分享窗口成功后主窗口未前置，用户看不到编辑器。  
  Mitigation: 主窗口收到结果后先 foreground/focus，再打开 composer。

- [Risk] 多个分享窗口同时回传结果造成串线。  
  Mitigation: 每个窗口带 request id；主窗口按 request id 处理并 ack。

- [Risk] payload/result serialization 放到错误层级，扩大反向依赖。  
  Mitigation: 增加 architecture guardrail 或 source test。

## Open Questions

- macOS 子窗口注册 `flutter_inappwebview_macos` 后是否稳定？
- Windows 子窗口是否能稳定运行 `flutter_inappwebview_windows` 和 `HeadlessInAppWebView`？
- Linux 是否具备同等分享入口和窗口能力，是否需要后续单独 spike？
- 分享窗口尺寸是否各平台一致，还是按平台采用不同默认尺寸？
