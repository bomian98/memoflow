## Why

首页 memo 卡片和草稿卡片的预览目前会先把正文归一化为纯文本，再交给 `MemoMarkdown` 渲染。这样会导致 `<sup>`、`<sub>`、inline code、code block、链接等 Markdown/HTML 语义在列表页丢失，而点击进入详情页后又能正常渲染，造成同一 memo 在不同表面的表现不一致。

这次变更的目标是把“用于判断是否过长的 plain preview text”和“用于实际渲染的 Markdown source”分离：渲染优先，允许继续使用现有 `maxLines` 裁剪，即使长文最后一行仍可能被裁切。

## What Changes

- 调整 home/list memo card 的预览数据流，让 `MemoMarkdown` 接收保留 Markdown/HTML 语义的 source，而不是已经纯文本化的 `previewText`。
- 保留 `buildMemoCardPreviewText()` / `truncateMemoCardPreview()` 作为轻量长度判断和展开按钮决策路径，避免重新引入 rich `TextSpan` 预览。
- 明确 collapsed preview 仍不得加载 inline images；图片继续走现有附件/媒体网格或 expanded article body 路径。
- 同步 draft box memo card 预览规则，避免草稿卡片和正式 memo 卡片出现不同渲染语义。
- 理清 `collapseReferences` 在预览测量和渲染 source 中的职责，避免 cache key 与实际 preview 构造参数不一致。
- 增加 focused widget/unit coverage，覆盖 home card、draft card、短内容 rich semantics、长内容 collapsed clipping、链接点击和 image suppression。
- 不引入新的 API、数据模型、订阅/商业逻辑或 `lib/data/api` 变更。

## Capabilities

### New Capabilities

- `memo-card-markdown-preview`: 定义 home/list memo card 与 draft card 的 Markdown/HTML 预览渲染规则，要求卡片预览保留正文语义，同时将纯文本归一化限制在长度判断职责内。

### Modified Capabilities

- `memo-inline-image-rendering`: 补充 collapsed home/list card Markdown preview 与 expanded article body/inline image policy 的边界，确保保留 Markdown/HTML 语义时仍不在 collapsed preview 中加载 inline images。

## Impact

- 主要影响：
  - `memos_flutter_app/lib/features/memos/widgets/memos_list_memo_card.dart`
  - `memos_flutter_app/lib/features/memos/widgets/draft_box_memo_card.dart`
  - `memos_flutter_app/lib/features/memos/memo_card_preview.dart`
  - `memos_flutter_app/lib/features/memos/memo_markdown.dart`
- 测试影响：
  - `memos_flutter_app/test/features/memos/memo_card_preview_test.dart`
  - `memos_flutter_app/test/features/memos/memos_list_memo_card_container_test.dart`
  - `memos_flutter_app/test/features/memos/draft_box_screen_test.dart`
  - `memos_flutter_app/test/features/memos/memo_markdown_widget_smoke_test.dart`
- OpenSpec/架构：
  - 当前 architecture phase 为 `evolve_modularity`。
  - 触及 checklist item 4：避免把可复用的 memo preview 文本/渲染 source 决策继续隐藏在 widget build 细节里。
  - 计划通过 scoped helper/seam 将 preview measurement 与 render source selection 明确拆分，保持 touched area equal or better structured。
