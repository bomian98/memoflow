## 1. Product Rules

- [ ] 1.1 确认 Free/default 的 AI 总结历史额度，以及 `AppCapability.aiSummaryHistory` enabled 后的额度。
- [ ] 1.2 确认超出当前额度的历史在降级后如何处理：可查看、可复制、可 rerun、可删除分别是什么规则。
- [ ] 1.3 确认第一版是否包含搜索/筛选，还是只做按时间倒序浏览。
- [ ] 1.4 确认 rerun 语义：使用原始 memo set、当前 source scope，还是重新打开配置控件。

## 2. Data and Persistence

- [ ] 2.1 定位现有 AI 总结结果流、模板元数据和本地持久化模式。
- [ ] 2.2 增加 focused AI summary history model，只保存产品/历史元数据，不保存商业状态。
- [ ] 2.3 增加本地持久化 owner，用于创建、列表、读取和删除历史记录。
- [ ] 2.4 确保历史记录快照关键展示信息，包括 template/source/model metadata。
- [ ] 2.5 如需要，增加本地 history store 的 migration 或初始化逻辑。

## 3. Capability Gating

- [ ] 3.1 只通过公开 capability seam 使用 `AppCapability.aiSummaryHistory`。
- [ ] 3.2 将 capability decision 映射为产品额度，不存储 commercial state。
- [ ] 3.3 对 Free/default、enabled、downgraded 三类状态保持一致的历史列表/详情操作 gating。
- [ ] 3.4 保持删除能力可用，让用户能管理自己的历史记录。

## 4. UI and UX

- [ ] 4.1 从 AI 总结页面增加历史入口。
- [ ] 4.2 增加 AI summary history list，展示生成时间、模板标题、来源范围和结果预览。
- [ ] 4.3 增加 history detail view，用于阅读、复制和删除已保存结果。
- [ ] 4.4 按确认后的产品规则增加 rerun / reuse 入口。
- [ ] 4.5 为所有新增 label、empty state、locked state 和 destructive action 增加 localization。

## 5. Tests and Guardrails

- [ ] 5.1 增加成功保存 AI 总结结果的 focused tests。
- [ ] 5.2 增加 Free/default 额度行为测试。
- [ ] 5.3 增加 enabled capability 行为测试。
- [ ] 5.4 增加 downgraded history preservation 和 restricted actions 测试。
- [ ] 5.5 新增或收紧 guardrails，防止 public history feature 引入商业状态、StoreKit、product IDs、prices、receipts 或 `AccessDecision.source` 业务分支。
- [ ] 5.6 验证没有新增 `state -> features`、`application -> features` 或 `core -> higher-layer` 依赖回退。

## 6. Verification

- [ ] 6.1 运行 focused AI summary history tests。
- [ ] 6.2 运行相关 private hooks / capability boundary tests。
- [ ] 6.3 运行相关 architecture guardrails。
- [ ] 6.4 运行 `flutter analyze`。
- [ ] 6.5 运行 `flutter test`；如果完整测试不可行，记录 scoped verification 和剩余风险。
