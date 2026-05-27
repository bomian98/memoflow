## Context

当前处于 `evolve_modularity` 阶段。若把未执行的真实桌面人工验证任务留在原 change 中，多个已完成代码整改会长期停留在 in-progress；若直接把这些任务标记为完成，又会让 OpenSpec 基线误以为相关 Windows/macOS 运行时行为已经人工确认。

这些遗留项有共同特征：

- 依赖真实 Windows 或 macOS 桌面运行时、原生窗口按钮、系统分享入口、窗口关闭语义或截图观察。
- 自动化测试、`flutter analyze`、架构 guardrail 或 OpenSpec strict validate 已在原 change 中完成。
- 不要求继续修改应用代码才能记录验证缺口。

## Goals / Non-Goals

**Goals:**

- 集中记录已完成桌面端代码整改中尚未人工确认的 smoke 项。
- 让原 change 的任务语义从“等待人工验证”变成“人工验证缺口已转移并可追踪”。
- 保持未验证风险显式存在，避免 archive 后的基线文档谎报真实平台已经验证。
- 保持运行时代码、API 代码和架构依赖不变。

**Non-Goals:**

- 不修改 Flutter 应用实现。
- 不替代真实设备/桌面环境上的人工验收。
- 不迁移尚未开始实现的 change 里的前置需求确认、审计或未来验证计划。
- 不扩大现有桌面功能范围。

## Decisions

1. 使用一个独立 change 承接跨 change 的人工 smoke 缺口。

   备选方案是每个原 change 继续保留未完成任务。这样虽然严格，但会让已完成代码整改无法成为 OpenSpec 基线。集中 change 更适合这些同质化、平台运行时依赖强的剩余项。

2. 原 change 不声称人工验证完成，只声称“已转移”。

   原任务会被改写为已完成的追踪动作，例如“记录为未手工确认，并转入 `verify-desktop-platform-smoke-gaps`”。这样归档含义是代码整改已完成，风险已转移，而不是验证已完成。

3. 只迁移已大量完成 change 的人工确认项。

   0 进度或尚未进入实现的 change 中，`确认`、`审计`、`验证` 往往是实现前置工作，不是收尾人工 smoke，继续留在原 change 更准确。

4. 不引入新的运行时 guardrail。

   本 change 只整理 OpenSpec 验证债务，不触碰运行时代码耦合热点。现有架构 guardrail 仍由各原 change 的代码整改负责。

## Risks / Trade-offs

- [Risk] 集中验证 change 可能变成长期待办池。  
  Mitigation: 每个任务保留来源 change 和具体平台场景，执行后逐项勾选。

- [Risk] 原 change archive 后，读者忽略后续验证 change。  
  Mitigation: 原 `tasks.md` 明确写出转移目标 change 名称。

- [Risk] 一些人工项实际暴露功能缺陷。  
  Mitigation: 发现缺陷时不在本 change 中直接修复；创建或更新对应功能 change，再把验证项关联到修复结果。
