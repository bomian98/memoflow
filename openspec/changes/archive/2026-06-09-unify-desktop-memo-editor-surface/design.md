## Context

当前代码已经具备统一编辑 surface 的基础：

- `MemoEditorScreen` 已支持 `MemoEditorPresentation.page`、`embeddedPane`、`desktopModal`、`desktopFullscreen`。
- `desktopHomePaneStateProvider` 已有 `DesktopHomeEditorSurfaceMode.hidden`、`centered`、`fullscreen`，并能表达 `DesktopHomeComposeNewMemo` 与 `DesktopHomeComposeEditMemo`。
- `MemosListScreen` 已能在 desktop shell 中渲染 `desktopEditorModalSurface`，并通过 `onToggleFullscreen` 在 centered/fullscreen 间切换。

分裂点主要在入口策略：

- `resolveMemosListDesktopPresentation` 当前仅让 Windows 使用 `desktopSurface`，macOS 仍走 `sheet/page` 模型。
- `MemoDetailScreen` 没有 host callback 时会直接 push `MemoEditorScreen(existing: memo)`。
- macOS app menu 的 `New Memo` 会在 root `app.dart` 中直接 push `MemoEditorScreen()`。
- Draft Box、列表 double tap、preview pane edit、action menu edit、keyboard edit 等入口不完全共享同一个 desktop presenter。

本 change 不实现代码，只把目标规则固定下来，避免后续实现时扩大到移动端重构或误删 desktop inline compose。

## Goals / Non-Goals

**Goals:**

- 桌面宽布局下，编辑已有笔记的所有明确编辑入口使用同一 desktop editor surface。
- 桌面宽布局下，显式新建笔记入口可使用同一 desktop editor surface 的 new draft target。
- 统一 editor 支持 centered modal 与 fullscreen，同一个 editor state 在两种模式间切换。
- macOS editor surface 不与系统标题栏或 traffic light 区域重叠。
- 保留手机端加号、移动端编辑、tablet bottom navigation、桌面窄布局的现有体验。
- 保留桌面 inline compose 作为快速记录能力，不把它误定义为完整编辑器。

**Non-Goals:**

- 不重写 `MemoEditorScreen` 的编辑器业务逻辑、附件上传、tag autocomplete、关联 memo、草稿保存或 sync 行为。
- 不改变 memo API、数据库 schema、server compatibility 或同步协议。
- 不移除 preview pane、detail page 或 inline compose。
- 不引入订阅、付费、entitlement、StoreKit、private overlay 或商业逻辑。
- 不解决所有桌面 route/chrome 问题，只处理 memo editor 入口一致性和标题栏重叠风险。

## Decisions

### 1. 用 DesktopMemoEditor intent 表达“我要完整编辑”

后续实现应引入或收敛到一个 focused opening seam，语义类似：

```text
DesktopMemoEditorIntent
  ├─ edit(existing memo / edit draft)
  └─ create(initial text / attachments / create draft)
```

该 seam 可以落在 `MemosListRouteDelegate`、`MemosListScreen` focused helper，或一个 feature-local presenter 中。重点不是类名，而是让各入口不再各自决定 push page、show dialog 或打开 desktop surface。

### 2. 桌面宽布局使用 home-contained centered modal

桌面宽布局中的完整编辑器应显示在当前 home desktop shell 内：

```text
Desktop home shell
  ├─ primary memo workspace
  ├─ optional preview pane
  └─ modalSurface
       └─ MemoEditorScreen(presentation: desktopModal)
```

优先使用现有 `DesktopDestinationShell` / desktop shell modal slot，这样 editor 位于应用工作区内，不绕过 macOS/window chrome safe-area 规则。

### 3. Fullscreen 是同一个 editor state 的 surface mode

fullscreen 不应通过 `Navigator.push` 或重建另一套编辑页面实现。它应切换 `DesktopHomeEditorSurfaceMode.centered <-> fullscreen` 或等价 state，让同一个 `MemoEditorScreen` state、文本、附件、关联 memo、草稿恢复逻辑继续存在。

用户期望：

```text
centered modal
  └─ click maximize
      -> fullscreen editor
          └─ Esc / restore
              -> centered modal
```

fullscreen 可保留极简 header/save/close controls，但视觉重点应是笔记内容，不应显示列表、preview pane 或无关导航 chrome。

### 4. Preview pane 保持 read-only，编辑委托到 intent

右侧 preview pane 的职责是阅读、选中和快速操作。它不应成为第二套编辑器。

```text
PreviewPane(Edit button)
  -> DesktopMemoEditorIntent.edit(selectedMemo)
  -> same desktop modal/fullscreen surface
```

列表 double tap 行为需要产品上明确：如果当前策略把 double tap 解释为 edit，它 SHALL 打开同一 editor intent；如果解释为 open detail/read，则 detail 内的 edit 仍 SHALL 委托回同一 editor intent。它 SHALL NOT 打开第三种编辑 route。

### 5. Desktop inline compose 保留 quick capture 语义

desktop inline compose 是快速记录，不是完整编辑器。统一完整 editor 不应删除 inline compose，也不应让 inline compose 负责编辑已有 memo。

建议边界：

```text
Inline compose
  = 快速新建、轻量记录、不中断列表浏览

Desktop editor modal
  = 完整新建/编辑、附件/关联/metadata/fullscreen
```

当 desktop modal 打开或关闭时，不应无故清空 inline compose draft state。若某个入口明确从 create draft 恢复到 modal，应只消费目标 draft，不影响无关 inline compose draft。

### 6. 移动端和窄布局保留现有体验

统一规则只要求 desktop wide layout 的完整 editor 一致。移动端点击加号继续使用现有 `NoteInputSheet.show` 或已有 page/sheet behavior；移动端编辑已有 memo 也不因本 change 被强制改成 desktop modal。

桌面窄窗口可继续使用现有 dialog/fullscreen fallback，前提是不产生 macOS titlebar overlap。若 fallback 仍有 overlap，应优先复用 desktop surface chrome/safe-area 规则，而不是改动移动端体验。

### 7. macOS app menu 需要 desktop-aware fallback

macOS menu command 发生在 root `app.dart` 层，可能不在当前 `MemosListScreen` 实例内部。后续实现可借鉴现有 `MemosListScreen.openDraftBoxInCurrentDesktopHome()` 模式：

```text
macOS New Memo
  -> try current desktop home editor intent
  -> if no eligible home exists, open a fallback that uses the same editor presentation rules
```

兜底不应直接回到会与标题栏重叠的裸 `MemoEditorScreen(page)`。

### 8. Modularity improvement

实现时应减少以下分支继续扩散：

```text
Navigator.push(MemoEditorScreen(...))
showDialog(MemoEditorScreen(...))
desktopHomePaneState.showCompose...
```

理想依赖方向：

```text
features/memos UI entry
  -> memo editor intent / route delegate / presenter seam
  -> desktop shell modal state or mobile fallback

app.dart macOS command
  -> desktop-aware memo editor opening seam / current home bridge
```

应避免：

```text
state/application/core -> features
core knows MemoEditorScreen
AppDrawer or preview pane directly owns editor route policy
```

## Risks / Trade-offs

- [Root menu command ownership] `app.dart` 不在 home screen 内，直接打开 home-contained modal 需要 current home bridge 或 fallback。缓解：沿用现有 current desktop home 静态实例模式作为过渡，或抽出更明确的 application-level desktop intent seam。
- [Inline compose draft collision] 新建 modal 与 inline compose 都能创建 memo，可能同时存在 draft。缓解：保留二者语义边界，不自动迁移或清空无关 draft。
- [Fullscreen controls] “全屏只有笔记内容”如果过于纯粹，会降低保存/关闭/附件能力可发现性。缓解：使用极简 chrome，内容为视觉主体，但保留必要 controls 和快捷键。
- [Tests may depend on old route pushes] 现有 widget tests 可能断言 `Navigator.push`。缓解：更新为断言 editor intent/surface visible，移动端 fallback tests 保持 old behavior。
- [Coupling hotspot] `MemosListScreen` 已经承担较多 desktop state。缓解：新增 focused helper/presenter，并用 architecture guardrail 防止低层依赖 features。

## Open Questions

- 桌面加号是否第一阶段就改为 modal，还是只把 macOS menu New Memo 和完整编辑入口纳入统一 surface？
- fullscreen 是否保留顶部标题 “编辑笔记/新建笔记”，还是只显示极简 close/restore/save controls？
- 桌面 narrow fallback 是保留 `showDialog`，还是统一复用同一个 shell modal slot 并使用 fullscreen mode？
