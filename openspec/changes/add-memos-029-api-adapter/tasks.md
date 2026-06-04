## 1. OpenSpec

- [x] 1.1 创建 `add-memos-029-api-adapter` change，记录第一层适配范围。
- [x] 1.2 增加 `memos-029-api-adapter` delta spec，明确 `0.29.0` 支持和非目标。

## 2. API Version and Facade

- [x] 2.1 在 `MemoApiVersion` 中增加 `v029`、`0.29.0` label、parse/normalize 和 probe order。
- [x] 2.2 增加 `MemoApi029`，复用 `0.28.0` 的 modern API facade 行为但使用 `0.29.0` strict version。
- [x] 2.3 扩展 `MemoApiFacade` 所有 switch，包括 unauthenticated、authenticated、sessionAuthenticated、passwordSignIn。
- [x] 2.4 扩展 `MemoApiProbeService` endpoint hints 和 force-delete support。

## 3. Login and Session

- [x] 3.1 在登录页面手动版本选择中加入 `0.29.0`，并让默认选项跟随最新支持版本。
- [x] 3.2 更新 `session_provider.dart` 中支持范围提示和手动版本校验错误文案。
- [x] 3.3 补齐其他 exhaustive `MemoApiVersion` switch，不改变现有业务语义。

## 4. Tests

- [x] 4.1 扩展 `versioned_api_routes_integration_test.dart`，覆盖 `0.29.0` parse、facade effective version、路由和 `display_time` remap。
- [x] 4.2 扩展 create/update/attachment API compatibility tests，使 `0.29.0` 走与 `0.28.0` 相同的 modern route shape。
- [x] 4.3 更新任何因 `v029` exhaustive switch 产生的测试 fixture。

## 5. Verification

- [x] 5.1 运行 `flutter test test/data/api --reporter expanded`。
- [x] 5.2 运行 `flutter analyze`，确认 exhaustive switch 和边界没有遗漏。
- [x] 5.3 检查变更不包含 private/commercial/paywall/billing 相关代码。
