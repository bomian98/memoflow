## 1. Scope and UX Rules

- [x] 1.1 确认第一阶段是否包含所有桌面新建入口，或仅包含 macOS menu New Memo 与 desktop toolbar create action。
- [x] 1.2 确认 fullscreen editor 的 chrome 细节：保留哪些 visible controls、哪些只能通过快捷键触发。
- [x] 1.3 确认列表 double tap 在 desktop preview layout 中的产品语义：open detail/read 或 edit；无论选择哪种，都不得打开独立编辑 route。

## 2. Desktop Editor Intent Seam

- [x] 2.1 定义 focused desktop memo editor opening seam，支持 edit existing memo、restore edit draft、create new memo、restore create draft、initial text/attachments。
- [x] 2.2 将 `MemosListScreen` 内的 desktop compose opening 分支收敛到该 seam，避免同一入口分别使用 page、dialog、modal surface。
- [x] 2.3 将 `MemoDetailScreen` 的编辑回调路径接入该 seam；没有 host callback 的 fallback 仍需遵守当前平台规则。
- [x] 2.4 将 preview pane edit button、memo card action menu edit、keyboard edit shortcut、edit draft restoration 接入同一 edit intent。

## 3. Desktop New Memo Consistency

- [x] 3.1 将 desktop wide layout 的显式 create memo actions 接入同一 create intent，同时保留 inline compose quick capture。
- [x] 3.2 将 macOS app menu `New Memo` 改为优先委托当前 desktop home editor surface；没有可用 home 时使用不会与标题栏重叠的 fallback。
- [x] 3.3 确认 create modal 与 inline compose draft 不互相清空、不错误复用无关 draft。

## 4. Surface Behavior

- [x] 4.1 桌面宽布局使用 home-contained centered modal surface 渲染 `MemoEditorScreen(presentation: desktopModal)`。
- [x] 4.2 fullscreen 切换使用同一 editor state 和同一 intent target，不通过 push 新 route 实现。
- [x] 4.3 macOS 上确保 centered/fullscreen editor 不与 titlebar、traffic lights 或 desktop shell chrome 重叠。
- [x] 4.4 保存、关闭、丢弃、加入草稿箱后刷新 preview/detail/list 相关状态，并不误清 unrelated inline compose draft。

## 5. Platform Fallbacks

- [x] 5.1 手机端加号继续使用现有 `NoteInputSheet` 或既有移动端写作体验。
- [x] 5.2 手机端编辑已有 memo 继续使用现有移动端 page/sheet 体验。
- [x] 5.3 tablet bottom navigation、非桌面平台和 desktop narrow fallback 保持既有行为，除非需要修复 titlebar/safe-area overlap。

## 6. Tests and Guardrails

- [x] 6.1 增加 focused tests：desktop preview pane edit、memo card edit、detail edit、keyboard edit 打开同一 desktop modal surface。
- [x] 6.2 增加 focused tests：desktop create action 和 macOS menu New Memo 使用同一 desktop editor presentation 或 safe fallback。
- [x] 6.3 增加 focused tests：fullscreen toggle 保留 editor text、attachments、metadata state，并可恢复 centered modal。
- [x] 6.4 增加 fallback tests：mobile add button 和 mobile edit behavior 不变。
- [x] 6.5 增加 tests：desktop inline compose draft 在 desktop modal open/close 过程中不被无关清空。
- [x] 6.6 增加或收紧 architecture guardrail，防止 editor opening policy 散落到 lower layers 或新增 `state/application/core -> features` reverse dependencies。

## 7. Verification

- [x] 7.1 运行相关 focused widget/unit tests。
- [x] 7.2 运行相关 architecture guardrails。
- [x] 7.3 在 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 7.4 在 `memos_flutter_app` 运行 `flutter test`；如果完整测试不可行，记录 scoped verification 和剩余风险。
