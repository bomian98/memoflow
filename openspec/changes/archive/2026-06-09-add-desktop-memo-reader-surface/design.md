## Context

当前代码中，桌面查看 memo 的行为分裂在几个入口：

- `MemosListScreen` 中单击 memo 在 desktop preview layout 下会调用 `_handleDesktopPreviewTap()`，打开右侧 preview pane。
- 同一 memo card 的 double tap 在 preview layout 下仍会调用 `_openMemoDetailRoute()`，push `MemoDetailScreen`。
- Enter/open detail 快捷入口在 selected memo 上也会 push `MemoDetailScreen`。
- `MemosListDesktopPreviewPane` 已经复用 `MemoDocumentBody` / `MemoDocumentPrimaryContent(readOnly: true)` 渲染 memo 内容，说明查看渲染本身并不需要复制。
- `MemoDetailView` 使用普通 `Scaffold` / `AppBar` / `SafeArea`，没有显式 opt in `DesktopWindowChromeSafeArea` 或 `PlatformPage(desktopWindowChromeSafeArea: true)`，在 macOS 透明 titlebar 中可能和 traffic lights 重叠。

本 change 不实现代码，只固定目标模型和边界，避免 implementation 误把 preview pane、旧 detail route、reader modal 和 editor modal 继续混在一起。

## Goals / Non-Goals

**Goals:**

- 桌面宽布局下，完整 memo 查看使用一个 unified desktop reader intent。
- 保留 preview pane 作为快速阅读/选择 surface，但双击、Enter、显式 open/fullscreen 等完整查看入口进入统一 reader surface。
- Reader surface 支持 centered modal 与 fullscreen，两者共享同一个 selected memo target、scroll/restoration state 和 reader session 语义。
- Reader surface 复用现有 memo document 渲染组件，不重写 markdown/attachment/detail rendering。
- macOS reader surface 和旧 fallback detail route 都不与 native titlebar / traffic lights 重叠。
- 移动端、tablet bottom navigation、非桌面平台、desktop narrow fallback 保持现有导航体验。

**Non-Goals:**

- 不重写 `MemoDocumentBody`、`MemoDocumentPrimaryContent`、attachment gallery、audio playback、memo relations、engagement、task checkbox、memo version/history、reminder、collection actions 的业务逻辑。
- 不改变 memo API、数据库 schema、server compatibility、sync protocol 或 route adapters。
- 不删除 preview pane。
- 不删除所有 `MemoDetailScreen` 用法；它仍可作为 mobile/narrow/fallback reader page，但 desktop wide 默认完整查看不应依赖它的 route push。
- 不引入订阅、付费、entitlement、StoreKit、private overlay 或商业逻辑。

## Decisions

### 1. 用 DesktopMemoReader intent 表达“我要完整查看”

后续实现应引入或收敛到一个 focused opening seam，语义类似：

```text
DesktopMemoReaderIntent
  └─ open(existing memo / memo uid / preview session data)
```

入口包括：

```text
Memo card double tap
Preview pane open/fullscreen action
Keyboard Enter / open detail shortcut
Explicit "open/read" action if present
```

这些入口不应各自决定 push page、show dialog 或 open modal，而应委托到 reader intent/presenter。

### 2. Preview pane 是快速阅读，不是完整查看 state owner

右侧 preview pane 保持 lightweight workspace companion：

```text
Desktop home shell
  ├─ primary memo list
  ├─ preview pane
  │    ├─ read-only quick reader
  │    ├─ edit action -> DesktopMemoEditorIntent
  │    └─ open/fullscreen action -> DesktopMemoReaderIntent
  └─ modalSurface
       └─ desktop reader or editor surface
```

preview pane 可以把当前 `selectedMemo` / prepared `DesktopMemoPreviewSession` 交给 reader intent，但不应额外拥有一套独立 fullscreen reader route policy。

### 3. Reader surface 使用 desktop shell modal slot

桌面宽布局中的完整 reader 应显示在当前 desktop home shell 内，优先复用现有 `DesktopDestinationShell` / `DesktopShellHost` 的 `modalSurface` slot。

```text
centered reader
  ├─ fixed readable max width
  ├─ read-only document body
  ├─ minimal header: close, fullscreen, edit, more actions
  └─ background list/preview not interactive
```

这样 reader 不绕过 macOS/window chrome safe-area 规则，也与刚统一的 editor surface 保持一致承载模型。

### 4. Fullscreen 是 reader surface mode，不是 route push

fullscreen reader 不应通过 `Navigator.push(MemoDetailScreen(...))` 实现。它应切换 reader surface mode：

```text
centered reader
  └─ click fullscreen / keyboard shortcut
      -> fullscreen reader
          └─ Esc / restore / close
              -> centered reader or close, per product rule
```

同一个 memo target、scroll position、resolved content state、audio state（若实现共享可行）应尽量保留。若 audio/player state 因现有 owner 限制无法第一阶段完全共享，应在 implementation notes 中明确剩余风险，并保证不会出现两个同时播放的 reader owners。

### 5. Gesture 和 keyboard 语义收敛

建议桌面宽布局语义：

```text
single click       -> select/open preview pane
double click       -> open desktop reader surface
Enter              -> open desktop reader surface
Cmd/Ctrl+E         -> open desktop editor surface
Esc                -> close reader surface if open; else close preview pane if open
```

这保留“快速查看”和“沉浸查看”的两级阅读，但不再回到旧全屏 page。对于 desktop expanded 但非 wide 的布局，如果 preview pane 支持但默认未打开，double click / Enter 也应走 reader intent；single click 可保留当前 open detail 或 select behavior，除非实现阶段决定统一为 preview-first 并同步更新 tests/spec。

### 6. Fallback detail route 必须 chrome-safe

`MemoDetailScreen` 仍可作为 mobile/narrow/fallback 页面存在，但 macOS desktop fallback 不应重叠 native chrome。可行方向：

- 让 fallback detail page 使用 `PlatformPage(desktopWindowChromeSafeArea: true)`；
- 或在 `MemoDetailView` 中为非 embedded desktop route 添加 shared `DesktopWindowChromeSafeArea`；
- 或让 desktop fallback route 使用 `DesktopDestinationShell` secondary task pattern。

重点是使用 shared seam，不在 memo detail 文件里硬编码 traffic-light padding。

### 7. 与 editor surface 互斥

reader surface 和 editor surface 共享 desktop modal slot，因此同一时刻应有清晰优先级：

```text
open editor while reader open
  -> close or replace reader surface
  -> open editor surface for same memo

open reader while editor open
  -> either ignore, ask to close editor, or keep editor as higher priority
```

第一阶段建议：editor 优先。reader 中点击 edit 应关闭/replace reader，并打开 existing desktop editor intent。

### 8. Modularity improvement

避免继续扩散：

```text
Navigator.push(MemoDetailScreen(...))
showDialog(MemoDetailScreen(...))
preview pane directly owns fullscreen route policy
```

理想依赖方向：

```text
features/memos UI entry
  -> DesktopMemoReaderIntent / route delegate / presenter seam
  -> desktop shell modal state or mobile fallback

reader surface
  -> existing memo document rendering widgets
  -> feature-local action callbacks for edit/more/close
```

应避免：

```text
state/application/core -> features
core knows MemoDetailScreen
lower-layer models know desktop reader UI
```

## Risks / Trade-offs

- [Modal slot ownership] editor 和 reader 都想使用 `DesktopDestinationShell.modalSurface`。缓解：明确 surface target/mode 或 reader/editor priority，避免同时渲染两个 modal owners。
- [State expansion] `desktopHomePaneStateProvider` 已经承担 selection、preview、editor state。直接加入 reader state 可能继续膨胀。缓解：可抽 focused reader state/presenter，或把 modal target 抽成明确 union，而不是散落 bool。
- [Audio/player state] preview pane 和 full reader 都可能播放音频。缓解：reader 打开时暂停 preview pane audio，或把 playback owner 提到 shared coordinator。
- [Tests currently expect `MemoDetailScreen`] 现有 widget tests 可能断言 Enter 或 tap 后出现 `MemoDetailScreen`。缓解：更新 desktop wide tests 为 reader surface visible，保留 mobile/narrow fallback tests。
- [macOS fallback chrome] 如果只改变 double tap，不修 fallback detail route，其他入口仍可能撞 traffic lights。缓解：把 fallback safe-area 作为 requirement 和 test/guardrail。
- [Coupling hotspot] `MemosListScreen` 已很重。缓解：新增 focused helper/presenter，并用 architecture guardrail 防止 route policy 再次散落。

## Open Questions

- Centered reader 默认尺寸应更接近 editor modal，还是更接近文章阅读器，例如 820px readable width？
- Preview pane 是否需要新增显式 open/fullscreen icon，还是仅保留 double click / Enter 进入完整 reader？
- Fullscreen reader 的 Esc 是恢复 centered，还是直接关闭？是否和 editor fullscreen 规则保持一致？
- Reader 中的 edit action 是 replace reader with editor，还是先关闭 reader 再打开 editor？用户是否需要看到 transition？
- 第一阶段是否统一 desktop expanded 的 single click 行为，还是只处理 preview-active/wide layout 的 double click 和 Enter？
