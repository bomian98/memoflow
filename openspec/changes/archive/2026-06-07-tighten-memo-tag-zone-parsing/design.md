## Context

当前 `extractTags` 已经改为 Markdown-aware 提取，能够跳过 code、link、image 等受保护上下文，但它仍会扫描所有可见正文行。这样会把 `测试文本 #这是测试文本`、`今天记录 #生活` 这类普通正文片段识别为本地标签，进而影响 `memos.tags`、`memo_tags`、搜索、统计、侧边栏和自助修复。

参考 Memos 后端允许中文 `#测试` 作为合法 tag，因此本 change 不是单纯对齐后端 tag grammar，而是为 Memoflow 的本地 fallback extraction 引入更严格的“首尾标签区”策略。远端返回的非空 `Memo.tags` 仍应作为权威输入保留。

架构阶段为 `evolve_modularity`。本 change 会触碰共享 `core/tags.dart` 和 memo 渲染预处理，不应扩大既有 `state -> features`、`application -> features` 或 `core -> higher-layer` 依赖；相反应把标签区判定继续集中在 lower-layer seam。

## Goals / Non-Goals

**Goals:**

- 将本地内容 fallback extraction 收窄为只读取首个和最后一个非空内容行中的严格标签区。
- 防止普通正文中的 `#这是测试文本` 被创建为本地标签。
- 保持 code block、inline code、link、image 等受保护 Markdown 上下文不产出标签。
- 让 memo HTML 标签装饰和持久化提取使用同一套标签区语义。
- 通过聚焦测试覆盖 create/edit/import/sync fallback、自助修复和渲染装饰的行为变化。

**Non-Goals:**

- 不修改 Memos 后端 tag grammar，也不改变非空后端 `Memo.tags` payload 的解析和保存。
- 不新增数据库 schema migration。
- 不自动重算全部历史 memo 标签；历史数据清理仍通过显式 self-repair 入口完成。
- 不触碰 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`，除非实现阶段另行取得用户明确批准。

## Decisions

### Decision 1: 使用严格 tag-zone line，而不是继续全文扫描

本地 fallback extraction 只考虑首个和最后一个非空内容行。候选行在 trim 后必须以一个或多个 `#tag` token 开头，token 之间只能有空白分隔；遇到第一个普通文本 token 后停止解析，后续正文中的 `#...` 不再算 tag。

```text
允许：
#生活 #openwrt
正文正文正文
#路由器/编译
#测试文本 测试文本

拒绝：
测试文本 #这是测试文本
今天记录一下 #生活
make menuconfig #进入openwrt目录
Tags: #work
```

理由：单纯“只扫描首尾行”无法解决单行正文 `测试文本 #这是测试文本`，因为该行同时是首行和尾行。必须同时要求 tag 从首尾行的行首开始，才能区分“标签区前缀”和“正文中夹带 hash”。允许前缀后接说明文字可以支持 `#测试文本 测试文本` 这类常见写法，同时不恢复全文扫描。

备选方案：继续支持全文正文标签但增加中文启发式排除。该方案规则含糊，容易误伤合法中文标签，也难以在 UI、search、repair 中保持一致。

### Decision 2: 把标签区判定集中到 `core/tags.dart`

严格标签区解析应作为共享 lower-layer seam 暴露给所有需要 tag extraction 的路径。memo create/edit/import/sync fallback、自助修复和统计重建继续通过共享 helper，而不是在各个 write path 中各自判断“首尾行”。

依赖方向保持：

```text
features/state/application/data
          │
          ▼
      core/tags.dart
```

不得引入：

```text
core/tags.dart ──▶ features/*
state/*       ──▶ features/*   （本 change 不新增）
application/* ──▶ features/*   （本 change 不新增）
```

### Decision 3: 展示装饰必须跟随同一语义

`decorateMemoTagsForHtml` 当前只装饰首尾内容行，但未要求整行是标签区。实现阶段应让它复用或等价调用 shared tag-zone 判定，确保 `测试文本 #这是测试文本` 不被渲染为 clickable tag。

备选方案：只修持久化提取，不修渲染。该方案会造成“数据库没有 tag，但 UI 看起来像 tag”的不一致，用户仍会认为误识别未修复。

### Decision 4: 后端 payload 优先级不变

当远端 API 返回非空 `tags` 数组时，本地应继续保存这些 tag，即使它们没有出现在首尾标签区。严格标签区只约束“从 content fallback 提取”的本地规则。

理由：远端 `Memo.tags` 是后端已经解析出的结构化数据；本地不应因为更严格的 fallback 策略丢弃远端权威标签。

## Risks / Trade-offs

- **[Risk] 正文中间标签工作流被破坏** → **Mitigation**: 在 proposal/spec/tasks 中标注 **BREAKING**，测试明确旧行为变化；需要发布说明提示用户将标签放到首尾标签区。
- **[Risk] 历史误识别标签仍留在本地缓存** → **Mitigation**: 不做静默 destructive migration；通过显式 self-repair 使用新规则重建标签。
- **[Risk] 与 Memos 后端中文 tag 行为出现差异** → **Mitigation**: 明确差异只存在于本地 fallback extraction；远端非空 `Memo.tags` 仍保持兼容。
- **[Risk] 标签装饰和持久化再次分叉** → **Mitigation**: 实现时增加 contract test，要求 HTML 装饰和 `extractTags` 对同一输入给出一致 tag-zone 结果。
- **[Risk] `#测试。` 等带标点标签区语义不清** → **Mitigation**: tag token 仍必须有空白或行尾边界；标点紧贴 tag 的情况不作为合法 tag prefix，后续如需允许尾随标点再单独提案。
