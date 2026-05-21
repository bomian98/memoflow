## 1. Preview Planning Seam

- [x] 1.1 在 `memo_card_preview.dart` 中新增或调整 feature-local helper，显式拆分 plain measurement text 与 Markdown/HTML render source。
- [x] 1.2 让 helper 支持 `collapseReferences`，并保证引用折叠同时影响 measurement 与 render source。
- [x] 1.3 保留 `buildMemoCardPreviewText()` / `truncateMemoCardPreview()` 的 plain measurement 职责，避免将其作为默认 `MemoMarkdown` 渲染 source。

## 2. Home/List Memo Card Integration

- [x] 2.1 更新 `memos_list_memo_card.dart`，让 collapsed/full preview 的 `MemoMarkdown.data` 使用 source-preserving render source。
- [x] 2.2 保留现有 `maxLines: kMemoCardPreviewMaxLines` collapsed clipping 行为，不重新引入 rich `TextSpan` preview。
- [x] 2.3 保持 collapsed preview 的 `renderImages: false` 与 `MemoInlineImageSyntax.none`，确保 Markdown/raw HTML images 不触发 image request。
- [x] 2.4 调整 memo card render cache key/source token，使 `collapseReferences`、render source、highlight query 与 image policy 不复用 stale preview。

## 3. Draft Card Integration

- [x] 3.1 更新 `draft_box_memo_card.dart`，复用同一 preview planning 规则生成 measurement 和 render source。
- [x] 3.2 保持 draft card collapsed preview 的 image-free 渲染策略与 `maxLines` 裁剪行为。

## 4. Coverage

- [x] 4.1 增加/更新 `memo_card_preview_test.dart`，覆盖 preview planning 的 measurement/render source 拆分、引用折叠和 plain normalization 边界。
- [x] 4.2 增加/更新 home/list memo card widget test，验证 `<sup>`、`<sub>`、inline code、code block/link 在卡片预览中保留渲染语义。
- [x] 4.3 增加/更新 draft box widget test，验证草稿卡片遵循同样的 Markdown/HTML 预览规则。
- [x] 4.4 增加/更新 image suppression test，验证 collapsed preview 保留非图片语义但不渲染 Markdown/raw HTML inline images。
- [x] 4.5 增加/更新 regression test，验证 long collapsed preview 继续走 `MemoMarkdown maxLines` 裁剪，而不是 rich `TextSpan` preview。

## 5. Verification

- [x] 5.1 在 `memos_flutter_app` 运行 focused tests：`flutter test test/features/memos/memo_card_preview_test.dart test/features/memos/memos_list_memo_card_container_test.dart test/features/memos/draft_box_screen_test.dart test/features/memos/memo_markdown_widget_smoke_test.dart`。
- [x] 5.2 在 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 5.3 检查本次改动未触及 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`。
- [x] 5.4 检查本次改动未引入 subscription、billing、entitlement、paywall、StoreKit 或其他商业逻辑。
