## Context

AI 服务详情页当前承担多个任务：

```text
AiServiceDetailScreen
  ├─ 编辑服务字段
  ├─ 保存服务
  ├─ 检查连接
  ├─ 管理模型列表
  ├─ 删除服务
  └─ 打开代理设置
```

它比 AI 服务新增向导复杂，因为用户可能修改字段后没有保存就关闭。迁移为桌面任务表面时，如果只是把完整页面塞进弹窗，会保留旧的“直接关闭可能丢修改”体验；用户已明确接受新增未保存确认，因此第二阶段应把关闭语义补齐。

## Goals / Non-Goals

**Goals:**

- AI 服务详情在桌面端使用共享任务表面。
- 移动端继续保留原有完整页面导航体验。
- 增加未保存修改检测和关闭确认。
- 保存、删除、连接检查、模型管理继续使用现有业务 owner 和 provider。
- 代理设置入口保持现状，不在本 change 中迁移。
- 增加防回退检查，避免 AI 服务详情入口重新直接 push 旧页面。

**Non-Goals:**

- 不迁移 `AiProxySettingsScreen`。
- 不重构 AI 服务 repository、provider、HTTP adapter 或模型管理业务逻辑。
- 不改变连接检查的保存时机，除非是为了保留现有行为。
- 不把模型编辑 dialog 重新设计为任务表面，除非实现中发现它会阻塞 AI 服务详情页迁移。
- 不修改 API、数据库 schema、同步协议或商业/private overlay 行为。

## Decisions

### 1. AI 服务详情使用单独 presenter

应新增语义入口：

```text
openAiServiceDetail(context, serviceId: ...)
```

调用方不应直接判断桌面平台，也不应直接 push `AiServiceDetailScreen`。入口根据平台选择：

```text
desktop -> showPlatformSecondaryTaskSurface(...)
mobile  -> Navigator.push(...)
```

这与 Collections 和第一阶段 settings task surface pattern 保持一致。

### 2. 关闭时检查未保存修改

AI 服务详情页应维护一个“当前编辑值”和“加载时/最近保存后的基准值”的比较。关闭任务表面、点击取消、系统返回或移动端返回时，如果存在未保存修改，应显示确认弹窗。

建议语义：

```text
关闭请求
  |
  +-- 没有修改 -> 直接关闭
  |
  +-- 有修改 -> 确认弹窗
          |
          +-- 保存 -> 执行现有 save 流程，成功后关闭
          +-- 放弃修改 -> 不保存并关闭
          +-- 继续编辑 -> 留在当前任务
```

确认弹窗可以使用现有平台 dialog seam；不应引入页面级 macOS traffic-light padding。

### 3. 代理设置入口采用方案 C

用户确认代理设置先保持现状。也就是说：

```text
AI 服务详情任务表面
    |
    +-- 点击代理设置 -> 保持当前 AiProxySettingsScreen 打开方式
```

这样可以避免把 `AiProxySettingsScreen`、settings root、独立 settings window 的行为一起卷进本 change。后续如果要统一嵌套 settings 任务，可以单独开 change。

### 4. 模型管理先保持嵌入现状

`AiServiceDetailScreen` 当前内嵌 `AiServiceModelScreen(embedded: true)`。迁移时应优先保持这个布局和交互，避免同时重构模型管理。模型编辑 dialog 已经是局部临时弹层，不是本 change 的核心问题。

### 5. Guardrail 覆盖 AI 服务详情入口

迁移后应检查：

- `AiSettingsScreen` 使用 `openAiServiceDetail(...)`。
- 生产入口不再直接 push `AiServiceDetailScreen`。
- `AiServiceDetailScreen` 桌面嵌入模式使用 `PlatformSecondaryTaskFrame`。
- 页面不手写 macOS traffic-light padding 或窗口控制坐标。

## Risks / Trade-offs

- [Risk] 未保存检测可能把连接检查产生的状态变化误判为用户编辑。
  Mitigation: 基准值应聚焦用户可编辑字段，例如名称、Base URL、API Key、Headers、enabled、usesSharedProxy；连接检查状态属于系统结果，不应让关闭确认反复触发。

- [Risk] 保存失败后关闭任务表面会丢失用户输入。
  Mitigation: “保存并关闭”只有在 `_save` 成功后才关闭；失败时留在任务表面并显示现有错误反馈。

- [Risk] 代理设置从任务表面内打开完整页面会显得不统一。
  Mitigation: 这是用户确认的方案 C；本 change 只记录边界，不扩大范围。

- [Risk] AI 服务详情内容较长，任务表面高度不足。
  Mitigation: 使用 large task surface、内部滚动和固定顶部/底部操作，保持小窗口可用。

## Migration Plan

1. 新增 `openAiServiceDetail(...)` presenter。
2. 让 `AiServiceDetailScreen` 支持嵌入 `PlatformSecondaryTaskFrame`。
3. 抽取或集中 AI 服务详情 body 和 actions，使桌面任务表面和移动页面共享内容。
4. 增加用户可编辑字段的 dirty 检测。
5. 增加关闭确认弹窗，支持保存、放弃修改、继续编辑。
6. 更新 `AiSettingsScreen` 中服务卡片和 Manage Service 入口。
7. 增加 focused widget tests 和防回退 guardrail。
8. 运行 focused tests、`flutter analyze`、相关 architecture guardrails 和 `openspec validate`。

## Open Questions

- “保存并关闭”按钮是否应出现在确认弹窗里，还是确认弹窗只提供“放弃/继续编辑”，由页面主按钮负责保存。
- 如果用户在详情页里新增/编辑模型，是否应视为服务详情的未保存修改，还是继续保持模型编辑即时保存语义。
