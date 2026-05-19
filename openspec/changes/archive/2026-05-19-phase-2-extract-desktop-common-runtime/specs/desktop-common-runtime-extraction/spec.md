## ADDED Requirements

### Requirement: 桌面通用运行时职责 SHALL 被抽取到明确归属
项目 SHALL 将已确认的跨桌面运行时职责从 Windows 优先入口和桌面运行时模块中抽取到明确的桌面通用归属。

#### Scenario: 运行时职责可跨桌面复用
- **WHEN** 某个启动、生命周期、窗口状态或消息协调职责在 Windows 和 macOS 上语义一致
- **THEN** 该职责必须由桌面通用运行时拥有，而不是由 Windows 专属入口直接拥有

### Requirement: Windows 专属适配器 SHALL 与桌面通用服务分离
项目 SHALL 保持 Windows 插件接线、Windows 事件处理和 Windows 原生行为位于 Windows 专属适配器中。

#### Scenario: 桌面通用服务需要调用平台能力
- **WHEN** 桌面通用运行时需要访问平台窗口、托盘、单实例或原生事件能力
- **THEN** 它必须通过平台适配器边界调用，而不是直接依赖 Windows 专属实现
