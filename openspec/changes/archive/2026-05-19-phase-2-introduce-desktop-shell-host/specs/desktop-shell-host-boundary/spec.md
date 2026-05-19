## ADDED Requirements

### Requirement: 桌面功能页面 SHALL 通过外壳宿主组合
项目 SHALL 让桌面功能页面通过桌面外壳宿主边界完成组合，而不是直接导入 Windows 外壳实现。

#### Scenario: 功能页面需要桌面外壳包装
- **WHEN** 某个功能页面在桌面端需要标题栏、导航、命令栏或页面外壳
- **THEN** 该页面必须依赖桌面外壳宿主边界，而不是直接依赖 `WindowsDesktopPageShell`

### Requirement: 外壳宿主 SHALL 支持平台外壳路由
桌面外壳宿主 SHALL 提供一个组合点，未来可以按平台路由到 Windows 外壳或私有 macOS 外壳。

#### Scenario: 私有 macOS 外壳接入
- **WHEN** 私有 macOS 版本提供自己的顶层外壳实现
- **THEN** 功能页面必须能通过外壳宿主边界接入该实现，而不需要导入私有 macOS 外壳模块
