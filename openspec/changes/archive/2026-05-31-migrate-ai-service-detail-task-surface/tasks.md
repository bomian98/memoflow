## 1. 准备和边界确认

- [x] 1.1 确认本 change 不修改 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`；如果实现中发现 API 相关修改必要，暂停并请求用户明确批准。
- [x] 1.2 确认 `migrate-settings-secondary-task-surfaces` 中的 presenter 模式和 guardrail 设计，保持第二阶段一致。
- [x] 1.3 复查 `AiServiceDetailScreen` 当前保存、删除、连接检查、模型管理和代理设置入口行为，记录哪些行为必须保持不变。

## 2. AI 服务详情任务表面

- [x] 2.1 新增统一打开入口，例如 `openAiServiceDetail(context, serviceId: ...)`，桌面端使用共享任务表面，移动端保留 route。
- [x] 2.2 让 `AiServiceDetailScreen` 支持嵌入 `PlatformSecondaryTaskFrame`，桌面端显示明确标题、关闭/取消和保存操作。
- [x] 2.3 更新 `AiSettingsScreen` 服务卡片和 Manage Service 入口，改用统一打开入口。
- [x] 2.4 保持 `AiServiceModelScreen(embedded: true)` 和现有模型编辑 dialog 行为不变，除非实现中发现必须做最小适配。
- [x] 2.5 保持 `AiProxySettingsScreen` 入口当前打开方式不变，并在测试或实现备注中记录它不是本 change 的迁移范围。

## 3. 未保存确认

- [x] 3.1 为 AI 服务详情页建立用户可编辑字段的 dirty 检测，至少覆盖 display name、Base URL、API Key、Headers、enabled、usesSharedProxy。
- [x] 3.2 确保连接检查产生的 validation status/message 不会被误判为用户未保存修改。
- [x] 3.3 在关闭、取消、系统返回或移动端返回时，如果存在未保存修改，显示确认弹窗。
- [x] 3.4 确认弹窗支持保存后关闭、放弃修改关闭、继续编辑；保存失败时留在当前页面或任务表面。
- [x] 3.5 删除服务成功后仍按现有语义返回父页面或关闭任务表面。

## 4. 防回退检查和测试

- [x] 4.1 增加或更新 architecture guardrail，确认 `AiSettingsScreen` 使用 `openAiServiceDetail(...)`，不再直接 push `AiServiceDetailScreen`。
- [x] 4.2 确认 `AiServiceDetailScreen` 桌面嵌入模式使用 `PlatformSecondaryTaskFrame`，且不手写 macOS traffic-light padding。
- [x] 4.3 增加 focused widget tests，覆盖桌面端详情页使用任务表面、移动端保持 route、保存结果、删除结果和未保存确认。
- [x] 4.4 增加或更新测试，确认代理设置入口仍可打开，但不要求它在本 change 中变成任务表面。

## 5. 验证

- [x] 5.1 运行 AI settings 相关 focused widget tests。
- [x] 5.2 运行相关 architecture guardrail tests。
- [x] 5.3 运行 `flutter analyze`。
- [x] 5.4 运行 `openspec validate migrate-ai-service-detail-task-surface --strict`。
- [x] 5.5 在桌面端手动验证 AI 服务详情：编辑字段、关闭未保存确认、保存并关闭、放弃修改、继续编辑、连接检查、删除服务、代理设置入口和移动端导航行为都符合预期。
