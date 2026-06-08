## Why

桌面主窗口统一通过 Home desktop shell 承载窗口层 chrome、拖拽区、窗口控制、全局操作和左侧本地库导航。macOS 的 hybrid titlebar 与 native traffic lights 暴露了重叠风险，但用户期望不是让草稿箱变成另一个独立 desktop shell，而是让草稿箱作为 Home 主内容区的一种状态显示在右侧 primary content 区域。

现在需要把草稿箱的桌面导航入口接入 Home desktop utility 机制：顶部全局操作栏和左侧本地库导航保持不变，右侧 primary content 区域显示草稿箱内容。桌面 Home 内联输入框工具栏里的草稿箱入口也属于当前 Home 上下文，不能再打开独立任务页；非 Home 桌面 compose surface 或移动端的 `DraftBoxScreen.show()` 二级选择任务仍可使用内容内 header；移动端继续使用现有 Scaffold/AppBar 语义。

## What Changes

- 调整桌面草稿箱导航入口：从 drawer、Home root registry、macOS menu 或桌面 Home 内联输入框工具栏打开草稿箱时，进入 `MemosListScreen` 的 `desktopPrimaryContentOverride` / `DesktopHomeUtilityView.draftBox`，显示在 Home 右侧 primary content 区域。
- 保留左侧本地库导航和顶部全局操作栏；草稿箱不再为桌面导航入口创建独立 `DesktopDestinationShell`。
- 覆盖 `DraftBoxScreen.show()` 这类无侧边栏的二级草稿选择页：非 Home 桌面 compose surface 或移动端 selector 可以继续使用内容内 header 来提供 Back/title。
- 增加 focused tests 或 architecture guardrails，防止草稿箱后续重新变成独立 desktop shell 或跑出 Home 主内容区。
- 本变更处于 `evolve_modularity` 阶段，触及 `features/memos` 与 desktop shell hot spot；实现必须复用现有 shell / platform chrome seams，并通过 guardrail tightening 让 touched area equal or better structured。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `desktop-window-chrome-safe-area`: 明确桌面导航型草稿箱不拥有 window chrome geometry，窗口避让仍由 Home desktop shell 和共享 seam 负责。
- `desktop-titlebar-navigation-context`: 明确桌面导航型草稿箱使用 Home shell 的 titlebar / command bar，不生成自己的 shell titlebar content。
- `draft-box-navigation`: 明确草稿箱桌面导航入口和桌面 Home 内联输入框工具栏入口显示在 Home primary content 区域，非 Home / 移动端二级 selector 保留独立任务 header 语义。

## Impact

- 主要影响 `memos_flutter_app/lib/features/memos/draft_box_screen.dart`、`memos_flutter_app/lib/features/memos/memos_list_screen.dart` 与 Home desktop utility navigation seams。
- 可能补充或调整 `memos_flutter_app/test/features/memos/draft_box_screen_test.dart`、`memos_flutter_app/test/platform/platform_ui_test.dart` 或 `memos_flutter_app/test/architecture/desktop_window_chrome_safe_area_guardrail_test.dart`。
- 不修改 API、数据库、同步、WebDAV、持久化模型或商业/private overlay 逻辑。
- 不新增 `state -> features`、`application -> features`、`core -> state|application|features` 依赖；window chrome geometry 不进入 feature-specific magic padding。
