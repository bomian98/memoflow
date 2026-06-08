## Context

桌面 Home 页面已经有稳定的三层结构：

```text
Home desktop shell
├─ titlebar / command bar: window chrome + global actions
├─ sidebar: 本地库导航、目的地、标签
└─ primary content: inline compose + memo list, or desktop utility content
```

截图中红框对应的是 `MemosListScreen` 的 primary content 区域。现有 `DesktopHomeUtilityView.syncQueue` 和 `DesktopHomeUtilityView.notifications` 已经通过 `desktopPrimaryContentOverride` 在这个区域显示工具内容，同时保留左侧本地库导航和顶部全局操作栏。

草稿箱作为左侧导航中的 Home 目的地，在桌面端应该使用同一条 Home utility 机制，而不是创建一个新的 `DraftBoxNavigationScreen -> DraftBoxScreen(showDrawer: true) -> DesktopDestinationShell`。否则会把草稿箱变成二级页面 shell，破坏截图中用户期望的 Home 框架连续性。

依赖方向保持为：

```text
features/home navigation seams
  └─ select DesktopHomeUtilityView.draftBox

features/memos/memos_list_screen.dart
  └─ owns Home primary content override
  └─ embeds DraftBoxScreen(presentation: desktopEmbedded)

features/memos/draft_box_screen.dart
  └─ renders reusable Draft Box content
  └─ MUST NOT own desktop window-control geometry
```

本变更处于 `evolve_modularity`，触及 `features/memos` 与 desktop shell hot spot。实现应扩展既有 Home utility seam，而不是新增一套草稿箱专用 desktop shell。

## Goals / Non-Goals

**Goals:**

- 桌面端从 sidebar、Home root registry、macOS menu 或 Home 内联输入框工具栏打开草稿箱时，草稿箱内容显示在 Home primary content 区域。
- 保留左侧本地库导航、顶部全局操作栏、Home desktop titlebar / command bar 和窗口控件。
- 在 primary content 内使用 `DesktopEmbeddedUtilitySurface` 承载草稿箱标题和返回到主内容的 affordance。
- `DraftBoxScreen.show()` 这类二级草稿选择任务继续可用；但桌面 Home 内联输入框工具栏入口属于当前 Home 上下文，优先切换 Home utility，而不是打开 selector route。
- 保持移动端 Scaffold/AppBar 既有表现。
- 不新增或扩大 `state -> features`、`application -> features`、`core -> higher layer` 依赖。

**Non-Goals:**

- 不把草稿箱桌面导航入口改成独立顶层 desktop shell。
- 不重写 `DesktopDestinationShell`、`AppleMacosPageShell`、`WindowsDesktopPageShell` 或整个 Home shell。
- 不改变草稿选择、删除草稿、打开 create draft / edit draft 的业务行为。
- 不修改 API、数据库、WebDAV sync、草稿持久化模型或 private/commercial overlay。
- 不为草稿箱添加新的商业、订阅、授权、paywall 或 StoreKit 逻辑。

## Decisions

### 1. 桌面导航型草稿箱作为 Home utility 嵌入

目标布局：

```text
Home desktop shell
┌──────────────────────────────────────────────────────────────┐
│ ●●● / 窗口控制区                         全局搜索/操作        │
├───────────────┬──────────────────────────────────────────────┤
│ 本地库/sidebar │  草稿箱                                      │
│ - 全部笔记     │  草稿卡片列表                                  │
│ - 草稿箱       │                                              │
│ - 标签         │                                              │
└───────────────┴──────────────────────────────────────────────┘
```

实现使用 `DesktopHomeUtilityView.draftBox`，由 `MemosListScreen` 的 `desktopPrimaryContentOverride` 渲染 `DraftBoxScreen(presentation: HomeScreenPresentation.desktopEmbedded)`。这样草稿箱内容位于截图红框主内容区，Home shell 的 sidebar 和全局操作栏保持不变。

Alternative considered: 让 `DraftBoxScreen(showDrawer: true)` 自己创建 `DesktopDestinationShell`，再把 titlebar leading 清空。这能避免 macOS traffic-light 重叠，但草稿箱仍是独立页面 shell，不符合用户标注的红框位置。

### 2. 草稿箱内容复用，桌面 embedded 只改变承载面

`DraftBoxScreen` 继续负责草稿列表、空状态、删除、选择草稿等内容逻辑。`HomeScreenPresentation.desktopEmbedded` 只改变外层承载面：使用 `DesktopEmbeddedUtilitySurface`，不创建 drawer、不创建 `DesktopDestinationShell`、不硬编码 traffic-light 或 caption-control padding。

Alternative considered: 为 Home 主内容区新增一个单独的 `DraftBoxUtilityScreen`。当前阶段会复制列表/删除/选择逻辑，风险更高；复用 `DraftBoxScreen` 更小。

### 3. 二级 selector 与当前 Home 入口区分

`DraftBoxScreen.show()` 是非 Home compose surface 或移动 compose 发起的二级选择任务，不等同于 sidebar 的草稿箱导航入口。桌面 Home 内联输入框工具栏里的草稿箱按钮属于当前 Home 上下文，应先保存当前 inline draft，再激活 `DesktopHomeUtilityView.draftBox`，只替换右侧 primary content。selector 可以保留 Back/title 内容 header；桌面 Home 入口必须嵌入 Home primary content。

Alternative considered: 所有桌面草稿箱形态都统一成 Home utility。selector 是临时任务 route，需要返回 selection 给调用方，强行塞入 Home utility 会破坏调用语义。

### 4. Guardrail 覆盖红框嵌入路径

测试重点不是像素级 snapshot，而是合同：

- 桌面 drawer / root / macOS menu / Home inline compose toolbar 草稿箱入口使用 `DesktopHomeUtilityView.draftBox`。
- `MemosListScreen` 保留 desktop command bar 和 sidebar，同时在 `desktopPrimaryContentOverride` 内显示草稿箱。
- embedded 草稿箱使用 `DesktopEmbeddedUtilitySurface`，不创建独立 `DesktopDestinationShell`。
- mobile 草稿箱仍使用原有导航页面和 AppBar。

## Risks / Trade-offs

- [Risk] 草稿箱从独立 route 改成 Home utility 后，返回语义变化。  
  Mitigation: `DesktopEmbeddedUtilitySurface.onBack` 调用 `_clearDesktopHomeUtilityView()`，返回 Home 主内容；系统 Back 在 utility active 时也清除 utility。

- [Risk] 点击 create draft 或 edit draft 后行为丢失。  
  Mitigation: create draft 复用 inline compose restore；edit draft 复用现有 memo resolve + `MemoEditorScreen(initialEditDraft:)` 语义。

- [Risk] drawer 选中态不正确。  
  Mitigation: `DesktopHomeUtilityView.draftBox` 时 `selectedDrawerDestination` 显示为 `AppDrawerDestination.draftBox`。

## Migration Plan

1. 扩展 `DesktopHomeUtilityView`，新增 `draftBox`。
2. 调整 `buildDrawerDestinationScreen`、`buildHomeRootScreen` 和 macOS menu 草稿箱入口，桌面端进入 `MemosListScreen(initialDesktopUtilityView: draftBox)`。
3. 调整桌面 Home inline compose toolbar 草稿箱入口，保存当前 inline draft 后激活当前 `MemosListScreen` 的 `DesktopHomeUtilityView.draftBox`。
4. 在 `MemosListScreen` 中通过 `desktopPrimaryContentOverride` 渲染 embedded `DraftBoxScreen`。
5. 让 embedded `DraftBoxScreen` 使用 `DesktopEmbeddedUtilitySurface`，并保留草稿列表/删除/选择行为。
6. 补 focused tests 和 architecture guardrails，覆盖红框主内容区嵌入、inline toolbar 入口、drawer 选中、mobile fallback。
7. 运行 focused tests、architecture guardrails 和 `flutter analyze`。

Rollback strategy: 如果 desktop utility 嵌入产生严重回归，可以临时让 `DesktopHomeUtilityView.draftBox` 回退到独立 route，但必须保留 guardrail 中的显式例外，避免无意重新破坏 Home shell 连续性。

## Open Questions

- embedded 草稿箱是否需要在 header 右侧增加 actions，目前先不新增。
- edit draft 在桌面 Home utility 中是否应优先打开 desktop modal editor，目前保持现有 `MemoEditorScreen(initialEditDraft:)` route 行为。
