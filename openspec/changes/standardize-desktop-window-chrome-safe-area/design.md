## Context

项目已经有 `desktop-window-chrome-safe-area` 主规格和 `memos_flutter_app/lib/core/desktop/window_chrome_safe_area.dart`，用于集中描述 macOS traffic-light reserved inset。主窗口和设置窗口也已有相关测试/guardrail。

这次截图暴露的是另一个层面：新的 desktop task window root 没有强制消费该 seam，导致 `ShareClipScreen` 这类 feature root 仍可把标题放进 macOS traffic lights 区域。也就是说，问题不是“完全没有 safe-area helper”，而是“helper 没有成为所有桌面窗口 root 的组合规则”。

当前架构阶段为 `evolve_modularity`。本 change 会触及 desktop shell、share task window wrapper 和 architecture guardrail；目标是把窗口控件避让继续收敛到 `core/desktop` 或 shell layer，而不是让 `features/share`、`features/settings` 等页面拥有平台窗口控件几何知识。

## Goals / Non-Goals

**Goals:**

- 让 desktop task window / shell root 的标题、返回、toolbar、top-leading content 统一避开原生窗口控件。
- 复用或扩展既有 `resolveDesktopWindowChromeInsets` / `DesktopWindowChromeInsets` seam，而不是新增另一套 magic padding。
- 将分享 task window 作为第一批消费方，解决“预览”标题与 macOS traffic lights 重叠。
- 增加 focused tests 或 source guardrail，防止后续 task window root 绕过共享 safe-area seam。
- 保持设置页/设置窗口当前行为不因本 change 被重新设计；后续若触碰设置窗口 chrome，也应复用同一规则。

**Non-Goals:**

- 不重新设计设置页视觉、导航或布局。
- 不把 native close 改成 App-owned close/cancel 控件。
- 不要求一次性迁移所有历史页面；本 change 要先建立规则、清点消费方，并迁移当前暴露问题的 task window。
- 不修改 API、数据库、同步模型或商业化/私有 overlay 逻辑。

## Decisions

### 1. 规则归属到 `desktop-window-chrome-safe-area`，分享 change 只消费

当前 `add-desktop-share-task-window` 的核心语义是：分享预览成为 one-shot task window，native close = cancel，成功结果回传主窗口。它不应承担“所有桌面窗口 chrome 避让”的通用规则。

因此本 change 修改既有 `desktop-window-chrome-safe-area` capability，定义 task window / shell root 的通用 safe-area 接入要求。分享窗口 change 只保留消费关系：

```text
standardize-desktop-window-chrome-safe-area
  └─ owns desktop chrome safe-area rule / shell / guardrail

add-desktop-share-task-window
  └─ share task root consumes the shared rule
```

### 2. 用 shell/root wrapper 消费 safe-area，而不是 feature 页面自算

推荐实现形态是共享 shell 或 wrapper，例如：

```text
DesktopWindowChromeScaffold / DesktopTaskWindowShell
  ├─ reads DesktopWindowChromeInsets from core/desktop policy
  ├─ reserves macOS traffic-light leading/top area when needed
  ├─ renders optional title / back / actions in chrome-safe area
  └─ hosts feature body without exposing platform chrome geometry
```

Feature 页面继续表达语义内容：

```text
Share task root
  ├─ title: 预览
  ├─ task root: true
  ├─ generic close/cancel: false
  └─ body/actions: share preview content
```

Feature 页面不应写 `Padding(left: 88)`、`Positioned(top: 28)` 这类 traffic-light 避让。若第一版必须使用保守常量，也必须集中在 `core/desktop/window_chrome_safe_area.dart` 或等价 policy 中，并有测试覆盖。

### 3. Native close 和 safe-area 是两个独立语义

Safe-area 只解决布局可用区域：

```text
native controls visible
  -> reserve layout space
  -> App content does not overlap
```

它不改变关闭规则：

```text
share task window native close
  -> cancel this share task
  -> no App-owned close/cancel button
```

因此共享 shell 不能因为需要避让 traffic lights 就顺手渲染一个 `X`、取消按钮或返回按钮。返回/取消只由任务语义显式决定。

### 4. 分批迁移，先清点再接入

本 change 不需要一次性重写所有页面。实现应先清点所有 desktop root/window chrome 消费方：

- main macOS shell：已使用 safe-area seam，确认不回退。
- settings window：已使用 safe-area seam，保持现状，不为本 change 重新设计。
- share task window：当前缺口，作为第一迁移对象。
- quick input、login/onboarding 或其他窗口：判断是否绘制到 native chrome 区域；只有受影响者才需要接入共享 shell。

### 5. Guardrail 优先防止问题复发

因为此类问题很容易以单页修补形式复发，除了 widget/layout tests，还应补 source guardrail：

- `core/desktop/window_chrome_safe_area.dart` 保持 lower-layer safe，不 import `features/*` / `application/*` / `state/*`。
- 新增 desktop task window root 时，应使用共享 shell 或在测试/文档中说明 native frame 不需要避让。
- 分享 task window wrapper 不应直接使用页面级 traffic-light magic padding。

## Risks / Trade-offs

- [Risk] 抽象过宽导致需要迁移过多页面。  
  Mitigation：本 change 只要求会绘制到 native/custom titlebar 旁的 desktop shell/task roots 参与；普通内容页不需要额外包装。

- [Risk] 保守 inset 在不同 macOS 版本或窗口样式下不完全精确。  
  Mitigation：沿用集中 metric seam；后续若能从 native 侧提供真实 `NSWindow` button frames，可替换 seam 实现而不改 feature pages。

- [Risk] 共享 shell 误伤设置窗口当前满意体验。  
  Mitigation：设置窗口本轮只验证不回退，不做视觉重构；任何设置窗口改动必须有 focused tests。

- [Risk] 分享窗口为了避让 traffic lights 重新引入 App-owned close/cancel。  
  Mitigation：spec 明确 safe-area 不改变 native close semantics，测试覆盖 task root 不渲染 generic close/cancel。

## Migration Plan

1. 审计 desktop windows / shell roots，列出哪些窗口会绘制到 native/custom titlebar 区域。
2. 设计或复用 `DesktopWindowChromeScaffold` / `DesktopTaskWindowShell`，内部消费 `resolveDesktopWindowChromeInsets`。
3. 将 share task window root 接入共享 shell，确保标题与 top-leading content 不再和 macOS traffic lights 重叠。
4. 保持设置窗口现状，仅补不回退验证；如发现设置窗口仍有独立 magic padding，记录为后续清理任务。
5. 增加 widget/source guardrail，覆盖 macOS reserved inset、非 macOS fallback、以及 share task root 消费共享 safe-area。
6. 运行 `flutter analyze`、focused desktop/share tests、architecture guardrails 和 `openspec validate`。

Rollback：如果共享 shell 在某个平台造成布局回归，可只让该平台临时回退到既有 frame 行为；保留 core metric seam 和 tests，后续按平台修正。

## Open Questions

- 共享 shell 第一版是否只提供 title/top-leading safe area，还是同时纳入 drag region 语义？
- Windows/Linux 启用 share task window 前，是否需要先定义 caption-control safe area 的具体像素/平台策略？
- 是否需要把现有 settings window 的 safe-area wrapper 命名统一迁移，还是保持当前实现并只补 guardrail？
