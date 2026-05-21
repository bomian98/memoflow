## Context

当前卡片预览把一个 helper 同时用于两件事：

```text
memo.content
  │
  ▼
buildMemoCardPreviewText()
  │
  ├─ 作为长度判断输入
  └─ 作为 MemoMarkdown(data: ...)
```

`buildMemoCardPreviewText()` 会把 Markdown/HTML 压成 lightweight plain text。这适合做长度判断，但不适合作为 renderer source。因此首页列表中 `<sup>`、`<sub>`、inline code、code block、link 等语义被提前丢失；详情页直接渲染原始正文，所以点击后正常。

当前 architecture phase 是 `evolve_modularity`。本变更触及 memo presentation 层，并涉及 checklist item 4：避免把可复用的 preview 规则继续藏在 widget build 细节中。设计上应把 preview measurement 与 render source selection 抽到 feature-local seam，而不是把更多条件堆进 `MemoListCardState.build()`。

## Goals / Non-Goals

**Goals:**

- home/list memo card 的 `MemoMarkdown` 输入 SHALL 保留 Markdown/HTML 渲染语义。
- draft box memo card SHALL 使用同样的预览原则。
- plain preview normalization SHALL 只用于长度判断、empty fallback、toggle 决策和必要的 summary 文本。
- collapsed preview SHALL 继续禁用 inline image rendering，不发起 remote/local image request。
- 长内容 collapsed preview 可以继续使用现有 `maxLines` 裁剪，接受最后一行被裁切的旧行为。
- 清理 `collapseReferences` 在 cache key、measurement 和 render source 中的不一致。

**Non-Goals:**

- 不重新引入 rich `TextSpan` / AST preview。
- 不要求 collapsed preview 行尾安全，不解决最后一行被裁切。
- 不改变 memo detail 的 Markdown 渲染策略。
- 不改变 API models、Memos server compatibility、SQLite schema、WebDAV sync 或 attachment upload 行为。
- 不引入商业、订阅、entitlement、StoreKit 或 private overlay 逻辑。

## Decisions

### Decision 1: Split measurement text from render source

卡片预览应生成两个概念上独立的值：

```text
raw memo content
  │
  ├──────────────► measurementText
  │                 plain text; for length/truncation/toggle only
  │
  └──────────────► renderSource
                    Markdown/HTML source; for MemoMarkdown only
```

建议新增 feature-local helper，例如在 `memo_card_preview.dart` 中引入 `MemoCardPreviewPlan` 或等价结构：

```text
MemoCardPreviewPlan
  plainTextForMeasurement
  renderSource
  truncated
  showToggle
```

这个 seam 的价值是让 `MemoListCard` 和 `DraftBoxMemoCard` 不再分别拼装 preview 规则，减少 widget build 中重复的内容策略。

Alternatives considered:

- 修改 `_normalizeMemoCardPreviewText()` 让它半保留 Markdown：拒绝。这个函数职责是 plain text normalization，混入渲染 source 会让链接、HTML、code fence 截断行为更难推理。
- 在 `MemoMarkdown` 中恢复语义：不可行。传入 `MemoMarkdown` 时语义已经丢失。
- rich `TextSpan` preview：拒绝。它绕开现有 `HtmlWidget`/Markdown renderer，覆盖面和 link behavior 都更脆弱。

### Decision 2: Use layout clipping for collapsed rendering source

collapsed 状态不应对 Markdown source 做 rune-level 截断。对于长内容，`MemoMarkdown` 可以接收 reference-adjusted source，并通过现有 `maxLines` clip 路径限制高度：

```text
showCollapsed == true
  MemoMarkdown(
    data: renderSource,
    maxLines: kMemoCardPreviewMaxLines,
    renderImages: false,
    imageSyntax: MemoInlineImageSyntax.none,
  )
```

这样可以避免把 code fence、HTML tag、Markdown link 截断成不完整结构。代价是 collapsed preview 不再依赖 source 字符串尾部的 `...` 提示；展开按钮仍由 measurement path 决定。

Alternatives considered:

- 对 raw Markdown 做 line/rune 截断并追加 `...`：风险较高，可能切断 code fence、HTML tag、link destination 或 inline code delimiter。
- 使用 plain truncated text 作为 collapsed renderer source：保留旧视觉省略号，但继续丢失渲染语义，不满足目标。

### Decision 3: Reference collapsing happens before both paths, but only as a shallow source transform

`collapseReferences` 需要同时影响 measurement 和 render source。建议增加一个 shallow transform：

```text
raw content
  ├─ collapseReferences=false -> raw content
  └─ collapseReferences=true  -> remove quoted lines, append localized "Quoted N lines"
```

这个 transform 不应做 Markdown/HTML normalization。它只改变文档行集合，剩余行仍保持原始 Markdown/HTML 语义。随后：

- measurement path 对 transformed source 调用 plain normalization。
- render path 直接把 transformed source 交给 `MemoMarkdown`。

这能让 cache key 中的 `collapseReferences` 与实际渲染输入一致。

### Decision 4: Image suppression stays in MemoMarkdown image policy

collapsed/preview 卡片继续传：

```text
renderImages: false
imageSyntax: MemoInlineImageSyntax.none
```

`MemoRenderPipeline` 已经会在 `MemoInlineImageSyntax.none` 下 strip Markdown images 和 raw HTML images。这样保留 `<sup>`、`<sub>`、`code`、`a` 等语义时，不会让 collapsed preview 加载 inline images。

Expanded article body 和 existing inline-image specs 不变。

### Decision 5: Tests target behavior, not implementation shape

测试应验证用户可见语义和边界：

- home memo card 短内容渲染 `<sup>`、`<sub>`、inline code、code block/link。
- draft card 使用同样渲染 source 规则。
- collapsed 长内容仍传 `maxLines`，不要求 line-safe。
- collapsed preview 不构建 inline images，也不启动 image request。
- `collapseReferences` 改变 measurement 与 render source，且 cache 不复用错误 source。

## Risks / Trade-offs

- [Risk] Collapsed long preview 可能不再显示字符串级 `...`。
  Mitigation: 保留展开按钮作为明确 affordance；这是渲染优先的取舍，且用户已接受旧的裁切问题。

- [Risk] 将完整 raw source 交给 collapsed `MemoMarkdown` 可能比 plain text 渲染更重。
  Mitigation: 只恢复现有 renderer 路径，不引入 rich AST；继续禁用 inline images；保留现有 render cache key。

- [Risk] HTML fragment 中存在复杂 block 时，collapsed clipping 仍可能产生视觉截断。
  Mitigation: 这是本次明确接受的旧行为；本变更只保证语义不在渲染前被纯文本化。

- [Risk] 引用折叠 transform 可能改变某些 edge case 的预览文本。
  Mitigation: focused tests 覆盖 quoted lines、mixed quoted/non-quoted Markdown，以及 cache key/source 变化。

- [Risk] widget build 里继续增长内容策略。
  Mitigation: 将 measurement/render source planning 放到 `memo_card_preview.dart` 或同层 helper，避免把共享逻辑隐藏在 screen/widget 文件。
