## Why

当前本地 fallback 标签提取会扫描整篇 memo 的可见 Markdown 正文，导致普通中文正文中的 `#这是测试文本` 被识别为标签。用户期望标签更像首尾标签区，而不是正文中任意 `#` 后文本都参与标签统计、搜索和侧边栏展示。

## What Changes

- **BREAKING**: 将本地从内容提取标签的规则从“扫描所有可见正文”收窄为“只扫描首个和最后一个非空内容行中的标签区”。
- 标签区中的标签行必须主要由一个或多个 `#tag` token 组成；普通正文中夹带 `#...` 的行不得作为标签来源。
- 保留 Markdown-aware 保护：code block、inline code、links、images 等受保护上下文仍不得产生标签。
- 同步编辑器渲染前的标签装饰规则，避免 UI 将正文中的 `#这是测试文本` 显示成可点击标签。
- 增加覆盖本地提取、渲染装饰、memo write path、自助修复的回归测试，明确历史中间正文标签不再被隐式创建。

## Capabilities

### New Capabilities

- 无。

### Modified Capabilities

- `memos-tag-compatibility`: 修改本地 fallback tag extraction 需求，从全正文提取改为严格首尾标签区提取，并定义正文 `#...` 的排除行为。

## Impact

- 主要影响 `memos_flutter_app/lib/core/tags.dart` 中的共享标签提取 seam，以及复用 `extractTags` 的 memo create/edit/import/sync/self-repair 路径。
- 影响 `memos_flutter_app/lib/features/memos/memo_markdown_preprocessor.dart` 的 HTML 标签装饰入口，使展示行为与持久化提取保持一致。
- 需要更新 `memos_flutter_app/test/core/tags_test.dart`、memo persistence/self-repair 相关测试，以及 memo render pipeline contract 测试。
- 不改变远端 Memos API route adapter、request/response model 或版本兼容层；实现阶段若发现必须触碰 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`，需要先取得明确用户批准。
- 架构阶段为 `evolve_modularity`。本 change 主要触碰共享 `core` 标签解析 seam 和 feature 渲染预处理，不应引入 `state -> features`、`application -> features` 或 `core -> higher-layer` 依赖；应通过集中规则和测试让 touched area 保持更清晰。
