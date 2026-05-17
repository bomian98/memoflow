# 第 1 阶段归属盘点

本盘点使用四种目标状态来分类桌面相关区域：

- `现在共享`
- `桌面通用候选`
- `Windows 外壳`
- `私有 macOS 候选`

## 仓库归属图

| 区域 | 当前职责 | 目标状态 | 备注 |
| --- | --- | --- | --- |
| `memos_flutter_app/lib/private_hooks/` | 私有扩展 bundle 的公开桩接入点 | 现在共享 | 已批准的接入点继续公开；活跃私有实现仍保留为桩 |
| `memos_flutter_app/lib/app.dart` | 带桌面集成的 app 运行时编排 | 桌面通用候选 | 包含共享启动和 Windows 优先桌面编排，后续应拆分 |
| `memos_flutter_app/lib/main.dart` | 应用入口和平台启动 | 桌面通用候选 | 包含后续应隔离的 Windows 启动分支 |
| `memos_flutter_app/lib/application/desktop/desktop_window_manager.dart` | 窗口、多窗口、托盘、同步桥编排 | 桌面通用候选 | 同时包含跨桌面行为和 Windows 专属行为 |
| `memos_flutter_app/lib/application/desktop/desktop_quick_input_controller.dart` | 桌面快速输入和热键协调 | 桌面通用候选 | 如果将外壳专属启动钩子抽离，其核心行为看起来可跨 Windows/macOS 复用 |
| `memos_flutter_app/lib/application/desktop/desktop_settings_window.dart` | 桌面设置窗口编排 | 桌面通用候选 | 窗口生命周期大概率可复用；窗口呈现细节可能分化 |
| `memos_flutter_app/lib/application/desktop/desktop_workspace_snapshot.dart` | 桌面窗口状态快照 | 现在共享 | 数据导向且与平台无关 |
| `memos_flutter_app/lib/application/desktop/desktop_resizable_panel_shell.dart` | 可调整大小的桌面面板原语 | 桌面通用候选 | 一旦命名/归属整理完成，它可能成为可复用外壳原语 |
| `memos_flutter_app/lib/application/desktop/desktop_tray_controller.dart` | 托盘集成 | 桌面通用候选 | 核心意图是跨桌面，但当前实现包含 Windows/Linux 专属内容 |
| `memos_flutter_app/lib/application/desktop/desktop_exit_coordinator.dart` | 桌面退出生命周期 | 桌面通用候选 | 行为部分可复用，但当前事件集成偏 Windows |
| `memos_flutter_app/lib/application/desktop/desktop_window_resize_frame.dart` | 自定义 resize frame 集成 | Windows 外壳 | 与当前 window manager 使用方式和 Windows 外壳行为强绑定 |
| `memos_flutter_app/lib/application/desktop/single_instance_coordinator.dart` | 单实例运行时 | 桌面通用候选 | 当前实现受 Windows 门控，但职责本身是跨桌面 |
| `memos_flutter_app/lib/features/home/desktop/windows_desktop_page_shell.dart` | Windows 顶层页面外壳 | Windows 外壳 | 抽取后仍必须保持 Windows 归属 |
| `memos_flutter_app/lib/features/home/desktop/windows_desktop_workspace_shell.dart` | Windows 桌面工作区布局与模态/副面板呈现 | Windows 外壳 | Windows 专属外壳和动效语言 |
| `memos_flutter_app/lib/features/home/desktop/windows_desktop_command_bar.dart` | Windows 命令栏和窗口控制组合 | Windows 外壳 | Windows 原生外壳元素 |
| `memos_flutter_app/lib/features/home/desktop/desktop_navigation_rail.dart` | 桌面导航组件 | 桌面通用候选 | 一旦脱离 Windows 外壳假设，可跨桌面复用 |
| `memos_flutter_app/lib/features/home/desktop/desktop_navigation_sidebar.dart` | 桌面侧边栏组件 | 桌面通用候选 | 可复用的结构性组件候选 |
| `memos_flutter_app/lib/features/home/desktop/desktop_overlay_navigation_panel.dart` | 桌面覆盖导航面板 | 桌面通用候选 | 可复用的结构性组件候选 |
| 直接导入 `WindowsDesktopPageShell` 的功能页面 | 页面级 Windows 外壳依赖 | Windows 外壳 | 这些页面需要桌面外壳边界，而不是直接依赖 Windows 外壳实现 |
| `memos_flutter_app/lib/core/platform_layout.dart` | 桌面布局层级和断点 | 桌面通用候选 | 当前 API 使用 Windows 命名，但大概率属于桌面通用 |
| `memos_flutter_app/lib/core/desktop/shortcuts.dart` | 桌面快捷键模型 | 桌面通用候选 | 已经在支持检查中同时考虑 Windows 和 macOS |
| `memos_flutter_app/lib/core/desktop_window_controls.dart` | 桌面窗口控制 widget/逻辑 | Windows 外壳 | 当前行为以 Windows 为目标 |
| `memos_flutter_app/lib/core/windows_adaptive_surface.dart` | Windows 专属自适应 surface helper | Windows 外壳 | 明确由 Windows 拥有 |
| `memos_flutter_app/lib/core/desktop_*_channel.dart` | 跨窗口 / 桌面 channel | 桌面通用候选 | 命名足够通用；实现仍需复查是否有 Windows 假设 |
| `memos_flutter_app/lib/state/system/reminder_scheduler.dart` | 带 Windows 通知器路径的提醒调度 | 现在共享 | 核心调度器是共享的，Windows 通知器路径目前仍留在共享模块中 |
| `memos_flutter_app/lib/state/system/session_provider.dart` | 会话存储选择，包含 Windows 锁定安全存储 | 现在共享 | 共享归属，但包含平台条件实现细节 |
| `memos_flutter_app/lib/data/repositories/windows_locked_secure_storage.dart` | Windows 安全存储协调 | Windows 外壳 | 虽然涉及跨进程协调概念，但实现是 Windows 专属 |
| `memos_flutter_app/lib/features/settings/windows_related_settings_screen.dart` | Windows 专属设置 UI | Windows 外壳 | 保持 Windows 归属 |
| `memos_flutter_app/lib/i18n/*windows* strings` | Windows 专属 UX 文案 | Windows 外壳 | 字符串归属跟随平台专属 UI 归属 |
| `memos_flutter_app/windows/` | 原生 Windows runner 和插件集成 | Windows 外壳 | 公开的 Windows 平台归属保持明确 |
| 未来私有 `memos_flutter_app/macos/` | 原生 macOS runner 和 Apple 平台脚手架 | 私有 macOS 候选 | 第 1 阶段期间必须留在公开仓库之外 |
| 未来私有 Apple 外壳模块 | macOS 标题栏、工具栏、菜单、设置窗口行为 | 私有 macOS 候选 | 在后续治理变更前保持私有 |
| 未来私有计费/权益/发布自动化 | Apple 商业运行时 | 私有 macOS 候选 | 当前治理下不得公开 |

## 临时备注

- `application/desktop/` 是当前仓库里最混杂的区域，既包含明显的桌面通用职责，也包含具体的 Windows 事件集成。
- `features/home/desktop/` 结构上就是当前 Windows 外壳。复用应该通过把共享原语向外抽取来实现，而不是把这个目录本身重新定义为共享。
- `core/platform_layout.dart` 和 `core/desktop/shortcuts.dart` 是未来抽取或重命名到 `desktop_common/` 的早期候选。
- 直接导入 `WindowsDesktopPageShell` 的功能页面现在与 Windows 外壳选择强耦合，应当是第 2 阶段最先处理的重构目标之一。
