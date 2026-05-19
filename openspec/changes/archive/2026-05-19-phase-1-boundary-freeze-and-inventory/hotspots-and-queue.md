# 第 1 阶段热点与第 2 阶段队列

## Windows 优先热点

### 1. `lib/app.dart` 和 `lib/main.dart` 里的运行时编排

为什么这是热点：
- 这两个文件把应用启动、Windows 专属桌面启动、窗口管理、托盘设置和运行时分支混在一起。
- macOS 也需要其中一部分职责，但不会使用同样的外壳接线方式。

目标方向：
- 抽取桌面通用的生命周期/启动职责。
- 把 Windows 启动钩子留在 Windows 归属的外壳/启动层。

### 2. `lib/application/desktop/` 里的窗口和多窗口编排

为什么这是热点：
- 该目录把核心桌面运行时职责和 Windows 专属事件流、插件集成混在一起。
- 如果 macOS 以后需要副窗口、快速输入、设置窗口或托盘/菜单栏集成，这里会成为主要分叉点。

目标方向：
- 将共享桌面运行时模型与 Windows 专属集成适配器拆分开。

### 3. `lib/features/home/desktop/` 里的 Windows 外壳 widget

为什么这是热点：
- 这里就是当前顶层 Windows 外壳，应该继续保持为 Windows 外壳。
- 风险不在于这些 widget 存在，而在于功能页面直接依赖它们。

目标方向：
- 保持 Windows 外壳的 Windows 归属。
- 引入更高层的桌面外壳边界，避免页面直接绑定到 Windows 外壳。

### 4. 导入 `WindowsDesktopPageShell` 的功能页面

观察到的页面：
- `features/about/about_screen.dart`
- `features/collections/collections_screen.dart`
- `features/explore/explore_screen.dart`
- `features/memos/draft_box_screen.dart`
- `features/memos/recycle_bin_screen.dart`
- `features/notifications/notifications_screen.dart`
- `features/resources/resources_screen.dart`
- `features/review/ai_summary_screen.dart`
- `features/review/daily_review_screen.dart`
- `features/settings/settings_screen.dart`
- `features/tags/tags_screen.dart`
- `features/memos/widgets/memos_list_screen_body.dart`

为什么这是热点：
- 页面级导入 Windows 外壳类会让未来 macOS 外壳组合变得昂贵。

目标方向：
- 用桌面外壳抽象或外壳宿主边界替代直接的 Windows 外壳依赖。

### 5. Windows 专属设置和 UX 字符串

为什么这是热点：
- 仓库里已经有 Windows 专属设置界面和 Windows 专属用户引导。
- 这些确实属于 Windows 拥有，但需要明确归属，避免无意间溢出到跨桌面流程。

目标方向：
- 保持 Windows 专属设置位于 Windows 归属模块中。
- 定义跨桌面设置如何与平台专属设置分离。

## 公开目录目标图

### `memos_flutter_app/lib/application/desktop/`
- 目标：拆分为 `desktop-common candidate` 和 `Windows shell`
- 首批抽取候选：
  - 快速输入协调
  - 设置窗口生命周期
  - 多窗口状态模型
  - 单实例策略抽象
- 预计保留的 Windows 归属残留：
  - resize frame 细节
  - 明确只有 Windows 需要的 window manager 事件处理

### `memos_flutter_app/lib/features/home/desktop/`
- 目标：大部分保持 `Windows shell`
- 可复用原语以后可能向外移动，但该目录本身应保留为 Windows 外壳主目录

### `memos_flutter_app/lib/private_hooks/`
- 目标：`现在共享`
- 公开接入点保持不变，实现在本仓库中仍为公开桩

### `memos_flutter_app/lib/core/`
- 归属混合
- 早期桌面通用候选：
  - `platform_layout.dart`
  - `desktop/shortcuts.dart`
  - `desktop_*_channel.dart`
- Windows 归属文件：
  - `desktop_window_controls.dart`
  - `windows_adaptive_surface.dart`

### `memos_flutter_app/lib/state/`
- 大部分为 `现在共享`
- 平台专属分支可以留在共享状态模块中，但归属必须明确记录

### 相关功能页面
- 目标：停止直接依赖 `WindowsDesktopPageShell`
- 未来方向：消费一个可以路由到 Windows 或 macOS 外壳实现的桌面外壳宿主边界

## 桌面通用抽取候选

- 桌面快捷键模型和绑定
- 桌面快速输入协调模型
- 桌面设置窗口生命周期模型
- 桌面多窗口状态和消息 channel
- 桌面布局层级、面板状态和副面板模型
- 桌面托盘/菜单宿主抽象
- 单实例运行时抽象

## 抽取后应保持 Windows 归属的行为

- 窗口控制和最大化/最小化/关闭操作
- Windows 命令栏布局
- Windows 标题栏行为和拖拽区域
- Windows 专属外壳动效和面板呈现
- Windows 专属设置页面
- Windows 原生安全存储协调
- Windows 相机设置流程和权限 UX
- `memos_flutter_app/windows/` 下的 Windows runner 集成

## 私有 macOS 覆盖仓库启动前的公开前置条件

1. 边界冻结文档已接受
2. 归属盘点已接受
3. 热点列表已接受
4. 第 2 阶段重构队列已打开
5. 已批准屏幕不再直接导入 Windows 外壳的后续规则
6. 已批准在可行时先进行桌面通用抽取，再推进私有 macOS 外壳

## 首批 macOS 私有归属区域

- `macos/` 平台脚手架
- Apple 外壳外观
- 工具栏 / 标题栏 / 侧边栏 / 检查器约定
- macOS 设置窗口行为
- app 菜单和命令处理
- StoreKit 和订阅运行时
- 权益评估
- 价格 / 产品标识符
- Apple 签名、公证、TestFlight / App Store 工作流

## 第 1 阶段完成标准

当满足以下条件时，第 1 阶段完成：

1. `boundary-freeze.md` 已存在并被接受
2. `inventory.md` 已存在并对桌面相关区域完成分类
3. `hotspots-and-queue.md` 已存在并识别了第 2 阶段工作
4. 已为首批抽取和收敛工作打开后续实现变更
5. `tasks.md` 已反映这些完成项
