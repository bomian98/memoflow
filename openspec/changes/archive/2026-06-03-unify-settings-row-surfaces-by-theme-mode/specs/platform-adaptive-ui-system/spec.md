## ADDED Requirements

### Requirement: Settings row surfaces SHALL use theme-mode tokens
设置页面中的 section、row、cell、value area、divider、border、hover、pressed、selected 和 disabled surface SHALL 根据当前 `Brightness.light` / `Brightness.dark` 从 settings-owned UI tokens、`ThemeData` 或 approved settings/platform seam 解析。设置页面 SHALL 使用这些 tokens 表达 `语言`、`字号`、`行高`、`字体`、`启动动作`、`主题色` 等设置项所在的背景和交互状态。

#### Scenario: Settings row background is centralized
- **WHEN** 设置页面渲染 navigation row、value row、toggle row、action row 或 equivalent settings cell
- **THEN** row/cell background、border、divider 和 interaction state SHALL 使用 settings-owned theme-mode tokens 或 approved settings/platform seam
- **AND** 页面 SHALL NOT 为普通设置行直接硬编码 page-local card/row background、border 或 divider 颜色

#### Scenario: Light and dark setting surfaces are consistent
- **WHEN** 同一个设置 section 和 row 分别在 `Brightness.light` 和 `Brightness.dark` 下渲染
- **THEN** section background、row background、divider、border、hover、pressed、selected 和 disabled 状态 SHALL 来自同一套按模式分支的 settings surface tokens
- **AND** 视觉差异 SHALL 来自 theme-mode token、semantic state 或 platform layout seam，而不是页面局部颜色分叉

#### Scenario: Material button colors remain customizable
- **WHEN** app 渲染 `FilledButton`、`ElevatedButton`、`OutlinedButton`、`TextButton` 或 `PlatformPrimaryAction`
- **THEN** 本 requirement SHALL NOT force those true button colors to a fixed settings row background
- **AND** 普通按钮 SHALL continue to resolve color from the existing app theme, selected theme color, custom theme color, semantic variant, or explicitly approved button seam

#### Scenario: Settings semantic exceptions keep their own visuals
- **WHEN** 设置 UI 渲染 destructive/error action、theme color swatch、custom color preview、status preview、editing preview 或 semantic warning state
- **THEN** 该 UI MAY 使用对应语义颜色或预览颜色
- **AND** settings row surface tokens SHALL NOT 覆盖这些语义/预览色

#### Scenario: System and media surfaces are excluded
- **WHEN** UI 属于媒体预览/播放 overlay、图片查看器控制、系统文件/图片选择器、平台原生 picker、系统窗口控制按钮或 OS-controlled surface
- **THEN** 该 surface MAY 使用上下文专属或系统原生视觉
- **AND** 它 MUST NOT 被 settings row surface 统一要求强制改写

#### Scenario: Settings surface drift is guardrailed
- **WHEN** 新增或修改的非 allowlisted migrated settings file 为普通设置 row/section/cell 引入 page-local background、border、divider、raw palette surface 或绕过 settings tokens 的局部 surface styling
- **THEN** architecture/style verification SHALL fail or require an explicit documented exception
- **AND** allowlist 条目 MUST 说明该 surface 属于 semantic danger/error、theme swatch、color preview、media overlay、system/native surface、window controls 或其他已批准例外
