## Why

桌面端 memo 查看目前有两套承载模型并存：单击 memo 会在右侧 preview pane 中阅读，快速双击或某些快捷入口仍会 push 旧的全屏 `MemoDetailScreen` route。这个旧 route 在 macOS 透明 titlebar 窗口中还可能与系统 traffic lights 和关闭按钮区域重叠，用户会感觉“查看 memo”从当前桌面 workspace 跳回了旧页面模型。

上一轮 `unify-desktop-memo-editor-surface` 已经把完整编辑收敛到 home-contained desktop editor surface。本 change 选择同样的方向处理“查看”：桌面宽布局保留 preview pane 作为快速阅读，但将完整查看收敛到统一 desktop memo reader surface，支持 centered 和 fullscreen，并明确旧 detail route 只作为移动端、窄布局或无 eligible desktop host 时的 safe fallback。

## What Changes

- 桌面宽布局中，双击 memo、preview pane 的 open/fullscreen action、Enter/open detail 快捷入口 SHALL 通过统一 desktop memo reader intent 打开 read-only reader surface，而不是直接 push 旧 `MemoDetailScreen` route。
- Desktop memo reader surface SHALL 复用现有 memo 阅读渲染能力，例如 `MemoDocumentBody` / `MemoDocumentPrimaryContent` / supplementary sections，而不是复制一套 markdown/detail 渲染逻辑。
- Reader surface SHALL 支持 centered modal 与 fullscreen 两种模式；fullscreen SHALL 使用同一 reader target/state 展开，而不是 push 另一套页面。
- Preview pane SHALL 保持快速阅读/选中/编辑入口职责；它可以提供 open/fullscreen action 委托到 reader intent，但不应成为第二套完整 reader state owner。
- macOS 上的 reader surface 和任何 fallback detail route SHALL 避免与系统标题栏、traffic lights 或应用 desktop shell chrome 重叠。
- 移动端、tablet bottom navigation、非桌面平台、桌面窄窗口 SHALL 保持现有 detail/navigation 体验，除非需要修复 titlebar/safe-area overlap。
- 不修改 Memos server API、request/response models、route adapters 或 `memos_flutter_app/lib/data/api`。

## Capabilities

### New Capabilities

- `desktop-memo-reader-surface`: 定义桌面端 memo 查看/阅读的统一 intent、preview pane 边界、centered/fullscreen reader surface、fallback detail route、gesture/keyboard 行为和 desktop chrome 安全要求。

### Modified Capabilities

- 无。

## Impact

- 预计涉及 `memos_flutter_app/lib/features/memos/memos_list_screen.dart`、`memos_flutter_app/lib/features/memos/widgets/memos_list_desktop_preview_pane.dart`、`memos_flutter_app/lib/features/memos/memo_detail_screen.dart`、`memos_flutter_app/lib/features/memos/memo_detail_view.dart`、可能新增 feature-local reader intent/presenter/surface helper，以及相关 widget tests/architecture guardrails。
- 不应改变 memo 内容解析、附件渲染、task checkbox toggle、engagement、关联 memo、版本历史、提醒、收藏等业务能力的 API 或数据模型。
- 当前架构阶段：`evolve_modularity`。
- 触及 modularity checklist：item 6（feature-to-feature collaboration 应通过 intent/presenter seam 而不是散落 route push）、item 7（查看/编辑入口 owner 需要清晰）、item 8（需要 guardrail/test 防止旧 route 回流）、item 10（触及 memos/home/navigation coupling hotspot 后结构应不变差）。
- scoped modularity improvement：实现时应把 desktop reader opening policy 集中到 focused intent/route delegate/presenter seam，减少 `MemosListScreen`、preview pane、card widgets 中散落的 `Navigator.push(MemoDetailScreen(...))` 分支。
