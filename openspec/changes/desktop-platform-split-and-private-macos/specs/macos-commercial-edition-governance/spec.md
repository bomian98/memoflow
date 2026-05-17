## ADDED Requirements

### Requirement: 私有 macOS 版本 SHALL 拥有 Apple 原生外壳行为
私有 macOS 版本 SHALL 拥有 Apple 专属顶层外壳行为，包括窗口外观、工具栏组成、侧边栏和检查器模式、设置窗口呈现、系统菜单行为，以及刻意贴近 macOS 原生体验的动效调校。

#### Scenario: 实现 macOS 外壳
- **WHEN** 私有 macOS 版本定义顶层桌面体验
- **THEN** 它不得被建模为 Windows 外壳的轻量视觉换皮，并且必须可以使用 macOS 原生外壳语义

### Requirement: 语义一致的共享桌面能力 SHALL 优先实现一次
如果某项桌面能力在 Windows 和 macOS 上的行为基本一致，项目 SHALL 优先在共享业务层或桌面通用层实现，而不是在两个平台外壳中重复实现。

#### Scenario: 新桌面功能具有共享语义
- **WHEN** 新桌面功能在 Windows 和 macOS 上行为一致
- **THEN** 其核心行为必须先加入共享业务层或桌面通用层，再添加外壳专属呈现

### Requirement: 平台分化 SHALL 显式说明
项目 SHALL 明确识别哪些桌面能力要求跨平台一致，哪些因为平台原生预期或私有商业要求而允许在 Windows 和 macOS 之间分化。

#### Scenario: 定义桌面能力范围
- **WHEN** 规划同时面向 Windows 和 macOS 的桌面能力
- **THEN** 该变更必须说明该能力是强制共享行为，还是允许平台分化

### Requirement: 私有 macOS 发布流水线 SHALL 与公开仓库隔离
签名自动化、公证、App Store 或 TestFlight 发布工作流，以及其他 Apple 发布基础设施 SHALL 保留在私有仓库中。

#### Scenario: 创建 macOS 发布工作流
- **WHEN** 添加用于打包或发布私有 macOS 版本的自动化
- **THEN** 该自动化必须存储并从私有仓库执行，而不是存放在公开仓库中
