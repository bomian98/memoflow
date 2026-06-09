## Why

桌面端笔记编辑目前由多个入口进入不同承载模型：部分入口打开独立 `MemoEditorScreen` route，部分入口走桌面 compose surface，右侧 preview pane 和详情页再各自转到编辑。macOS 上独立编辑页面还可能和系统标题栏区域重叠，用户会感觉同一个“编辑笔记”能力被拆成了多个页面模型。

这个 change 旨在把桌面端编辑/新建笔记的完整编辑器收敛到一个统一的 desktop memo editor intent：桌面宽布局使用 home 内居中 modal，可切换 fullscreen；移动端和窄布局继续保留现有 sheet/page 体验；桌面内联输入继续作为快速记录能力存在。

## What Changes

- 桌面宽布局中，编辑已有笔记的入口 SHALL 通过同一个 desktop memo editor intent 打开统一的居中 modal surface，不再因入口不同打开不同编辑页面。
- 桌面宽布局中，显式新建笔记入口 SHOULD 复用同一 desktop memo editor intent 的 new draft target；保留 desktop inline compose 作为快速记录入口，不强制替换为 modal。
- 统一编辑 surface SHALL 支持 centered 与 fullscreen 两种模式；fullscreen SHALL 使用同一个 editor state 展开，而不是 push 另一套页面。
- macOS 上的 desktop editor surface SHALL 避免与系统标题栏、traffic light 区域或应用 desktop shell chrome 重叠。
- 右侧 preview pane SHALL 保持阅读/预览职责；当用户触发编辑时，SHALL 委托到统一 desktop editor intent。
- 手机端、tablet bottom navigation、非桌面平台、桌面窄窗口 SHALL 保持现有写作/编辑体验，除非现有 fallback 也出现标题栏或安全区域问题。
- 不修改 Memos server API、request/response models、route adapters 或 `memos_flutter_app/lib/data/api`。

## Capabilities

### New Capabilities

- `desktop-memo-editor-surface`: 定义桌面端笔记编辑/新建完整编辑器的统一入口、承载模型、preview/inline compose 边界、移动端保留规则和桌面 chrome 安全要求。

### Modified Capabilities

- 无。

## Impact

- 主要影响桌面端 memo editing/navigation 规则，后续实现预计涉及 `memos_flutter_app/lib/features/memos/memos_list_screen.dart`、`memos_flutter_app/lib/features/memos/memos_list_desktop_presentation.dart`、`memos_flutter_app/lib/features/memos/memo_editor_screen.dart`、`memos_flutter_app/lib/features/memos/memo_detail_screen.dart`、`memos_flutter_app/lib/features/memos/draft_box_navigation_screen.dart`、`memos_flutter_app/lib/app.dart` 的 macOS menu command fallback，以及相关 desktop shell/navigation tests。
- 不应影响移动端 `NoteInputSheet` 的主体验，也不应移除 desktop inline compose quick capture。
- 当前架构阶段：`evolve_modularity`。
- 触及 modularity checklist：item 6（入口协作应通过 intent/navigation seam，而不是各 screen 直接 push 不同 route）、item 7（编辑写入路径需要清晰 owner）、item 8（需要 focused tests/guardrails 保护入口一致性）、item 10（触及 memos/home/navigation coupling hotspot 后结构应不变差）。
- scoped modularity improvement：实现时应把桌面编辑/新建 intent 决策集中到 focused presenter/helper 或现有 route delegate seam，减少 `MemosListScreen`、`MemoDetailScreen`、`app.dart` 中散落的 `Navigator.push(MemoEditorScreen(...))` 分支。
