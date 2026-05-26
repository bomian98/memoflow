## 二级页面范围记录

本记录用于支撑 `fix-desktop-settings-nested-navigation` 的实现验收和后续整改。当前架构阶段仍为 `evolve_modularity`，本 change 通过复用 `PlatformPage`、`DesktopTitlebarNavigationPolicy`、`window_chrome_safe_area` 和设置窗口右侧 nested navigator 来收敛二级页 chrome 行为，不引入新的 `core/platform -> features` 反向依赖。

## 本批纳入范围

### Settings

- 设置独立窗口的右侧内容区：改为独立 nested navigator，设置二级页不再覆盖整个窗口 titlebar 区域。
- `PreferencesSettingsScreen`、`ComponentsSettingsScreen` 等设置首页直接入口：保留作为设置窗口右侧 root pane，root pane 不显示返回按钮。
- `ComponentsSettingsScreen` 子页面：提醒、图床、图片压缩、位置、模板、WebDAV 等通过右侧 nested navigator 打开，桌面端显示 `Back + Page Title`。
- AI/provider/proxy/model、导入导出、实验室、快捷键、账号安全等设置内 full-page 子路由：通过共享二级页返回策略恢复桌面端返回控件；未逐页重写视觉。

### Share

- `ShareClipScreen` 作为 full-page share preview：保留显式 `Cancel` 行为，桌面端依赖共享 `PlatformPage`/route policy 显示平台返回语义。
- `ShareClipScreen` 内打开的视频预览等 full-page 子路由：继续通过 `buildPlatformPageRoute` 和共享 route policy 获取返回语义。

### 其他 full-page 二级页

- memo detail/editor、attachment/image preview、collection、review/AI summary、tags/explore 等已使用 `resolveDesktopRouteDismissalLeading` 或 `PlatformPage` 的页面：本批通过共享 policy 统一恢复 desktop secondary back affordance。

## 明确不纳入本批

- `AlertDialog`、popover、tooltip、bottom sheet、`NoteInputSheet` 等短暂浮层：不属于 full-page secondary page。
- 系统原生窗口按钮本身的重绘：macOS 红色关闭仍是原生窗口关闭，不能作为 App 内返回。
- 大规模页面内容视觉重做：后续 UI 视觉讨论另开 change 处理。

## 后续优先级

1. 高风险：仍手写 App-owned close-vs-back 逻辑、可能丢失未保存内容的 full-page 页面。
2. 中风险：仍手写 titlebar 偏移、但已经使用共享返回控件的页面。
3. 低风险：只使用共享 `PlatformPage`/`resolveDesktopRouteDismissalLeading`，没有窗口控制重叠风险的页面。

未来新增 full-page secondary route SHOULD 默认使用共享 page/chrome seam；如果临时不能迁移，应在 guardrail allowlist 或 change artifact 中说明原因和移除计划。
