## 1. 共享标签区规则

- [x] 1.1 在 `memos_flutter_app/lib/core/tags.dart` 中集中实现 strict tag-zone 判定：只考虑首个和最后一个非空内容行，且候选行必须完全由空白分隔的 `#tag` token 组成。
- [x] 1.2 调整 `extractTags` 的 fallback 内容提取，使 `测试文本 #这是测试文本`、`今天记录一下 #生活`、中间正文 `#middle-tag` 不再产出标签。
- [x] 1.3 保留现有 tag grammar 对 `_`、`-`、`/`、`&`、Unicode letters/numbers/symbols/marks、ZWJ 的支持，并保持 `normalizeTagPath` 行为不变。
- [x] 1.4 保持 Markdown protected contexts 行为：code block、inline code、links、images、URL fragments 中的 `#...` 不得产出标签。
- [x] 1.5 放宽 strict tag-zone 为行首 tag prefix：支持 `#测试文本 测试文本`，但 `#first text #ignored` 只提取 `first`。

## 2. 展示与写路径一致性

- [x] 2.1 调整 `memos_flutter_app/lib/features/memos/memo_markdown_preprocessor.dart` 的 tag decoration，使其只装饰 strict tag-zone lines 中的标签。
- [x] 2.2 审计使用 `extractTags` 的 memo create/edit/import/sync fallback/self-repair 路径，确认它们共享 `core/tags.dart` 规则且没有在 feature/widget 层复制解析逻辑。
- [x] 2.3 确认非空后端 `Memo.tags` payload 仍保持权威，不因 strict tag-zone fallback 被丢弃或重算。
- [x] 2.4 避免新增 `state -> features`、`application -> features` 或 `core -> higher-layer` 依赖；如发现需要跨层协作，优先使用现有 lower-layer seam。

## 3. 回归测试与验证

- [x] 3.1 更新 `memos_flutter_app/test/core/tags_test.dart`，覆盖 strict tag-zone 允许与拒绝样例，包括 `测试文本 #这是测试文本`。
- [x] 3.2 更新 memo persistence/self-repair 测试，覆盖历史误识别标签通过显式 repair 按新规则移除，合法首尾标签区仍保留。
- [x] 3.3 更新 memo render pipeline contract 测试，确认正文 hash 不渲染为 `memotag`，首尾标签区仍可装饰。
- [x] 3.4 运行聚焦测试：`flutter test test/core/tags_test.dart --reporter expanded`、相关 memo persistence/self-repair 测试、相关 memo render pipeline 测试。
- [x] 3.5 运行 `flutter analyze`；若改动范围扩大，再运行 `flutter test`。
- [x] 3.6 最终检查 staged/unstaged diff，确认没有引入 private/commercial/subscription/billing/entitlement/paywall/StoreKit 相关代码。
- [x] 3.7 补充行首 tag prefix 的提取与渲染回归测试。
