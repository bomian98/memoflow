## Why

多个桌面端 change 已完成主要代码、自动化测试和架构校验，但仍保留真实 Windows/macOS 桌面运行时、原生窗口 chrome、截图和平台手感相关的人工确认项。若这些项继续挂在原 change 中，会让已完成的代码整改无法归档；若直接勾选，又会误导后续 AI 认为真实平台已验证。

本 change 将这些人工 smoke 缺口集中收口，使原 change 可以表达“代码整改完成，人工验证已转移”，同时保留未验证风险的可追踪记录。

## What Changes

- 新增一个专门承接桌面平台人工验证缺口的 OpenSpec change。
- 将已大量完成的桌面端 change 中剩余的人工确认项迁移为本 change 的待办项。
- 将原 change 中对应任务改写为“已记录为未手工确认，并转入 `verify-desktop-platform-smoke-gaps`”，避免伪造已验证状态。
- 不修改 Flutter 应用代码、API 代码、运行时能力或平台行为。
- 不把尚未开始实现的 change 中的前置需求确认、实现审计任务迁入本 change。

## Capabilities

### New Capabilities
- `desktop-platform-smoke-verification`: 记录和执行真实桌面平台上的人工 smoke 验证，包括 Windows/macOS 桌面窗口、titlebar、traffic lights、设置页导航、分享子窗口、内联输入框拉伸和截图检查。

### Modified Capabilities
- 无。

## Impact

- 影响 OpenSpec 工件：
  - `openspec/changes/verify-desktop-platform-smoke-gaps/`
  - 已完成代码但剩余人工验证项的相关 `tasks.md`
- 不影响运行时代码。
- 不涉及 API 文件。
- 当前架构阶段仍为 `evolve_modularity`；本 change 不触碰运行时代码耦合热点，也不引入新的依赖方向。
