## 1. 调查与定位

- [x] 1.1 审查草稿箱从 drawer、Home root registry、macOS menu 和 `DraftBoxScreen.show()` 进入时的现有路由差异。
- [x] 1.2 确认用户红框位置对应 `MemosListScreen` 的 Home primary content 区域，而不是独立 `DesktopDestinationShell` 页面。
- [x] 1.3 对照 `DesktopHomeUtilityView.syncQueue` / `notifications` 的既有机制，确认草稿箱桌面导航入口应扩展 Home utility seam。

## 2. 桌面草稿箱嵌入实现

- [x] 2.1 扩展 `DesktopHomeUtilityView`，新增 `draftBox`。
- [x] 2.2 调整 drawer destination 与 Home root registry：桌面端草稿箱入口进入 `MemosListScreen(initialDesktopUtilityView: DesktopHomeUtilityView.draftBox)`，移动端继续使用 `DraftBoxNavigationScreen`。
- [x] 2.3 调整 macOS menu 草稿箱入口，使其打开带 sidebar、全局操作栏和 inline compose 能力的 Home shell，并激活 draft box utility。
- [x] 2.4 调整桌面 Home inline compose toolbar 草稿箱入口，使其保存当前 inline draft 后激活当前 Home 的 `DesktopHomeUtilityView.draftBox`，不 push 独立草稿箱 route。
- [x] 2.5 在 `MemosListScreen` 中通过 `desktopPrimaryContentOverride` 渲染 `DraftBoxScreen(presentation: HomeScreenPresentation.desktopEmbedded)`。
- [x] 2.6 embedded 草稿箱使用 `DesktopEmbeddedUtilitySurface` 承载标题和返回主内容操作，不创建独立 `DesktopDestinationShell`。
- [x] 2.7 保持 `DraftBoxScreen.show()` 的非 Home / mobile 二级 selector 语义，继续可返回 create/edit draft selection。
- [x] 2.8 保持草稿列表、空状态、删除草稿、create draft selection、edit draft opening 行为不变。

## 3. Guardrails 与测试

- [x] 3.1 更新 `memos_flutter_app/test/features/memos/memos_list_screen_test.dart`，覆盖桌面草稿箱显示在 Home primary content 区域，并保留 command bar 与本地库 sidebar。
- [x] 3.1.1 覆盖桌面 Home inline compose toolbar 草稿箱入口，确认点击后仍停留在当前 `MemosListScreen`，草稿箱只替换右侧 primary content。
- [x] 3.2 更新 `memos_flutter_app/test/features/home/home_root_destination_registry_test.dart`，覆盖桌面草稿箱 route 使用 `DesktopHomeUtilityView.draftBox`，移动端仍返回 `DraftBoxNavigationScreen`。
- [x] 3.3 更新 `memos_flutter_app/test/features/memos/draft_box_screen_test.dart`，覆盖 embedded Draft Box 使用 utility surface 且不创建独立 desktop destination shell。
- [x] 3.4 更新 architecture guardrails，防止桌面导航型草稿箱回退到独立 shell 或旧的 content-header 修补方案。

## 4. 验证

- [x] 4.1 在 `memos_flutter_app` 运行 `dart format` 覆盖本次触及 Dart 文件。
- [x] 4.2 运行草稿箱和 Home route focused widget tests。
- [x] 4.3 运行 desktop utility / window chrome architecture guardrail tests。
- [x] 4.4 在 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 4.5 如 focused tests 暴露假仓库或编译问题，按红框主内容区方案做最小修复后重新运行。
