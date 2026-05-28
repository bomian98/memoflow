## MODIFIED Requirements

### Requirement: 桌面功能页面 SHALL 通过外壳宿主组合
项目 SHALL 让桌面功能页面通过桌面外壳宿主边界完成组合，而不是直接导入 Windows 外壳实现，也不得在已迁移的顶层 drawer destination 页面中自行分叉 Windows/macOS shell 树。

#### Scenario: 功能页面需要桌面外壳包装
- **WHEN** 某个功能页面在桌面端需要标题栏、导航、命令栏或页面外壳
- **THEN** 该页面必须依赖桌面外壳宿主边界，而不是直接依赖 `WindowsDesktopPageShell`

#### Scenario: 顶层 destination 使用统一 shell seam
- **WHEN** 某个已迁移的顶层 drawer destination 页面在 Windows 或 macOS 桌面端渲染
- **THEN** 该页面 SHALL 通过 `DesktopShellHost`、`DesktopDestinationShell` 或等价统一 shell seam 表达 destination、title、actions、body 和 navigation context
- **AND** 该页面 SHALL NOT locally branch between `DesktopShellHost` and `Scaffold` for Windows/macOS top-level shell selection

### Requirement: 桌面外壳宿主 SHALL own titlebar navigation-context policy
桌面外壳宿主 SHALL 根据平台、navigation mode 和页面层级决定 titlebar leading title、top-level title、leading control 和 dismissal control 是否渲染，而不是要求功能页面自行判断窗口控件、安全区、侧边栏状态或返回/关闭控件位置。

#### Scenario: 功能页面提供语义 title
- **WHEN** 功能页面向 `DesktopShellHost` 或等价桌面外壳提供 `leadingTitle`、`center`、`trailing`、command bar 或 body slot
- **THEN** 功能页面 SHALL 只表达语义内容，title visibility 和 chrome-safe placement MUST 由桌面外壳宿主处理

#### Scenario: 顶层 title 不包含 dismissal control
- **WHEN** 顶层 drawer destination 页面向 desktop shell 提供 title 或 leading title
- **THEN** title widget MUST NOT contain page-local back, close, done, or route-dismissal controls
- **AND** any valid top-level dismissal behavior MUST be expressed through an explicit shell semantic input

#### Scenario: 展开侧边栏隐藏重复顶级 title
- **WHEN** 桌面外壳宿主在 macOS expanded sidebar 模式下渲染顶级 drawer destination
- **THEN** 桌面外壳宿主 SHALL omit titlebar leading title when the same destination label and selected state are already visible in the sidebar

#### Scenario: 展开侧边栏保留稳定 toolbar spacer
- **WHEN** 桌面外壳宿主在 macOS expanded sidebar 模式下隐藏顶级 drawer destination 的重复 title 或 leading control
- **THEN** 桌面外壳宿主 SHALL preserve a consistent titlebar or toolbar spacer height so the sidebar and body start position remain stable across top-level destination switches

#### Scenario: 隐藏 chrome 的 spacer 不引入页面级分割线
- **WHEN** 桌面外壳宿主在 macOS expanded sidebar 模式下只保留顶级页面的稳定 titlebar 或 toolbar spacer
- **THEN** 该 spacer SHALL NOT render page-specific bottom dividers or separators unless visible toolbar content explicitly requires the boundary

#### Scenario: 非展开导航保留必要 title
- **WHEN** 桌面外壳宿主在 rail、overlay、narrow 或 navigation labels 不持久可见的模式下渲染顶级 destination
- **THEN** 桌面外壳宿主 SHALL allow a current page title to render in a window-chrome-safe titlebar or toolbar region

### Requirement: 桌面外壳宿主 policy SHALL be guarded against feature-page drift
桌面外壳宿主 SHALL include focused verification or guardrails so future feature pages do not reintroduce page-local titlebar padding, duplicated macOS top-leading titles, page-local Windows/macOS shell branching, or title-embedded dismissal controls.

#### Scenario: 新桌面顶级页面接入外壳
- **WHEN** a new top-level drawer destination is added to a desktop shell
- **THEN** verification SHALL ensure it follows the centralized titlebar navigation-context policy instead of adding macOS-specific titlebar padding in the feature page

#### Scenario: 已迁移页面不回退到平台分支
- **WHEN** a migrated top-level drawer destination is changed
- **THEN** guardrails SHALL fail if the page reintroduces `isWindowsDesktop ? DesktopShellHost(...) : Scaffold(...)` or equivalent page-local shell split without an explicit documented exception

#### Scenario: shell policy changes
- **WHEN** title visibility, navigation mode routing, or desktop window chrome policy changes
- **THEN** focused tests or guardrails SHALL cover macOS expanded sidebar suppression, secondary-route native close dispatch, and at least one title-visible fallback mode
