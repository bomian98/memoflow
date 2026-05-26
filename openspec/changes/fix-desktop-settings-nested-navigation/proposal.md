## Why

桌面端设置窗口里，`ComponentsSettingsScreen` 下的二级设置页暴露出两个相关问题：

- 二级页标题可能进入系统窗口控制区，和关闭、最小化等 titlebar 控件重叠。
- 当前处于二级页时，系统红色关闭按钮会关闭整个设置窗口；这符合 macOS，但页面内缺少统一的“返回 + 二级页标题”规则，导致用户容易把系统关闭和页面返回混在一起。

进一步讨论后确认，这不是 `ComponentsSettingsScreen` 的单点问题，而是软件内所有 full-page 二级页面的导航和页面 chrome 规则需要统一，包括设置二级页、分享相关页面，以及其他从一级页面进入的完整页面。

## Scope

本 change 先写规则，不做实现。

覆盖范围：

- 所有 full-page 二级页面，而不只是设置页。
- 设置二级页，例如 `ComponentsSettingsScreen` 下的图床、提醒、WebDAV、模板等详情页。
- 分享相关页面，例如系统分享入口、第三方分享捕获、分享编辑/确认等以完整页面呈现的流程。
- 桌面端优先，phone/tablet 也应遵守“二级页有明确返回语义”的平台适配原则。

暂不覆盖：

- `AlertDialog`、popover、tooltip、bottom sheet 等短暂浮层。
- 系统原生窗口按钮本身的样式重绘。
- 大规模重新设计页面内容区视觉；本 change 聚焦二级页面导航、titlebar 避让和关闭/返回语义。

## Confirmed Direction

- macOS 系统红色关闭按钮仍然关闭窗口，不承担返回上一级职责。
- macOS 页面内不允许出现 App 自绘的右上角 `X` 作为页面关闭控件。
- 二级页面必须有明确的 App 内返回方式。
- 桌面端二级页面标题格式采用“返回 + 二级页标题”。
- 二级页面标题和返回区域不能和 macOS traffic lights 或 Windows/Linux 系统窗口控制区重叠。
- 关闭桌面设置窗口后再次打开，应回到设置首页，而不是恢复到上次停留的二级页。
