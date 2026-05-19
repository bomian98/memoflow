## 1. Capability Boundary

- [x] 1.1 扩展 `memos_flutter_app/lib/access_boundary/app_capability.dart`，加入首批产品级能力点，避免使用商品、套餐或价格命名。
- [x] 1.2 建立公开仓 capability decision provider / service，让功能代码通过统一 seam 查询 `AppCapability`。
- [x] 1.3 保持公开 `active_private_extension_bundle.dart` 为 Free-safe 默认实现，商业能力默认 disabled。
- [x] 1.4 增加 focused tests 验证公开默认 bundle 不暴露商业能力，且基础记录能力不受影响。

## 2. Private Overlay Simulation

- [x] 2.1 在私有 overlay 的 `active_private_extension_bundle.dart` 规划或实现本地模拟权益状态：`free`、`trial`、`subscriptionPro`、`buyoutPro`、`expired`、`refunded`、`unavailable`。
- [x] 2.2 将模拟权益状态映射到产品级 `AppCapability` 决策，不向公开共享模型暴露原始商业状态。
- [x] 2.3 确保模拟开关仅用于开发和测试，不成为公开仓或正式 release 的商业解锁路径。
- [x] 2.4 在私有 worktree 验证 overlay 覆盖后 capability decisions 可被公开功能读取。

## 3. AI Custom Summary Template Pilot

- [x] 3.1 定位 AI 自定义总结模板的数据模型、入口、创建、编辑、使用和删除路径。
- [x] 3.2 在模板创建入口接入 capability seam：Free 最多 1 个模板，Pro / buyout 允许多个模板。
- [x] 3.3 在模板使用和编辑执行路径接入 capability seam，防止绕过 UI 直接使用锁定模板。
- [x] 3.4 实现过期降级规则：模板不删除；超额模板可查看、不可使用、不可编辑、不可复制，只能删除。
- [x] 3.5 实现权益恢复规则：能力恢复后，所有已存在模板恢复可用和可编辑。
- [x] 3.6 增加 focused tests 覆盖 Free、Pro、buyout、expired 的模板数量和锁定行为。

## 4. Subscription Entry Boundary

- [x] 4.1 保持 `settings_screen.dart` 只渲染 `SettingsEntryContribution`，不加入订阅、买断、Family Sharing、trial、价格或商品判断。
- [x] 4.2 在私有 overlay 通过 private bundle 贡献订阅中心或升级入口占位。
- [x] 4.3 增加测试验证 public settings shell 不导入商业实现、不读取 access boundary 以外的商业状态。

## 5. Guardrails and Modularity

- [x] 5.1 收紧或新增 public repo guardrail，阻止 StoreKit、product ID、receipt、purchase / restore、hardcoded price、entitlement implementation 泄露到公开 runtime。
- [x] 5.2 增加 shared model guardrail，保护 preferences、session、account、update config、general repositories 不持有订阅、买断、Family Sharing 或 receipt 状态。
- [x] 5.3 增加或维护 `AccessDecision.source` guardrail，防止 diagnostic metadata 被用于业务分支。
- [x] 5.4 验证本 change 未新增 `state -> features`、`application -> features` 或 `core -> higher-layer` 依赖。
- [x] 5.5 更新相关架构测试 allowlist 时只收紧或保持稳定，不新增未经批准的边界例外。

## 6. Verification

- [x] 6.1 在 `memos_flutter_app` 运行 targeted tests：private hooks、settings shell、AI template pilot、capability boundary tests。
- [x] 6.2 在 `memos_flutter_app` 运行 `flutter analyze`，记录任何既有无关问题。
- [x] 6.3 在 `memos_flutter_app` 运行 `flutter test` 或至少相关 focused suites，记录未覆盖风险。
- [x] 6.4 运行公开仓 commercial guardrail 脚本，确认公开仓仍不包含 StoreKit、商品、价格或商业状态。
- [x] 6.5 在私有仓运行 `scripts/sync-public.sh` 后执行无签名 macOS 本地构建验证，确认 overlay 和 capability seam 可编译。
