## 为什么

第 1 阶段热点盘点发现，很多功能页面直接导入 `WindowsDesktopPageShell`，这让页面组合和 Windows 外壳强耦合，未来引入私有 macOS 外壳的成本会很高。需要一个桌面外壳宿主边界，让页面依赖桌面外壳接口，而不是 Windows 外壳实现。

## 变更内容

- 为桌面功能页面引入外壳宿主边界。
- 尽量移除功能页面对 `WindowsDesktopPageShell` 的直接依赖。
- 准备一个组合点，未来可以路由到 Windows 外壳或私有 macOS 外壳。

## 能力

### 新增能力
- `desktop-shell-host-boundary`：通过外壳宿主边界而不是直接 Windows 外壳导入来路由桌面页面组合的规则。

### 修改能力
- 无。

## 影响

- 可能受影响的区域：`memos_flutter_app/lib/features/home/desktop/`、直接导入 `WindowsDesktopPageShell` 的功能页面，以及共享页面组合 helper。
