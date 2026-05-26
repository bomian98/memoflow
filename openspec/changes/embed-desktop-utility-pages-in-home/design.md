## Context

桌面主页当前以 `MemosListScreen` 作为主要 shell：侧边栏、inline compose、memo list、desktop preview pane 和 Windows/macOS titlebar 都在这一层组合。同步队列和消息通知已经存在完整页面实现，但它们作为独立 route 打开时，会重新拥有顶层标题栏与返回语义。

用户希望只修改桌面端：从侧边栏/标题栏入口打开同步队列和消息通知时，把它们显示在主页笔记列，类似替换 inline input 和 memo list；同时侧边栏选中状态清空。

## Goals / Non-Goals

**Goals:**

- 桌面端 `SyncQueueScreen` 和 `NotificationsScreen` 可作为主页主内容列 embedded utility view 显示。
- embedded utility view 不渲染顶层 `AppBar`，不拥有 window chrome safe-area。
- embedded utility view 的局部内容标题左侧提供返回按钮，用于清除当前 utility view 并回到主页笔记列。
- 侧边栏显示 embedded utility view 时 `selected` 为 `null`，并清除 tag selection。
- 移动端和 tablet bottom navigation 保持现有行为。
- 保留 standalone route，避免影响 macOS menu 或其他入口的兼容性。

**Non-Goals:**

- 不重新设计设置页。
- 不改变同步队列、通知的数据模型、API、动作语义或列表项行为。
- 不一次性迁移所有可能的 desktop secondary pages。
- 不改商业化/private overlay 逻辑。

## Decisions

### 1. 在主页 shell 维护 desktop utility view state

推荐在 `MemosListScreen` 内维护一个小的桌面专用状态，例如：

```text
_DesktopHomeUtilityView.none
_DesktopHomeUtilityView.syncQueue
_DesktopHomeUtilityView.notifications
```

当状态非 `none` 时，`MemosListScreenBody` 接收 `desktopPrimaryContentOverride` 或等价参数，用 embedded utility body 替换原 memo list body。

```text
MemosListScreen
  ├─ DesktopShellHost / PlatformPage titlebar remains owner
  ├─ AppDrawer(selected: null, selectedTagPath: null)
  └─ primary content
     ├─ memos list when none
     ├─ SyncQueue embedded body
     └─ Notifications embedded body
```

### 2. Feature roots 暴露 embedded body，而不是把完整页面塞进主页

`SyncQueueScreen` / `NotificationsScreen` 应拆出可复用的 content widget 或 presentation mode：

```text
standalone route
  -> PlatformPage / DesktopShellHost / Scaffold
  -> title / back / actions
  -> body

desktop embedded
  -> no top-level AppBar
  -> local Back affordance wired to the home shell
  -> local content header/actions if needed
  -> body
```

这样主页 shell 继续拥有 window chrome，feature page 只表达业务内容和局部操作。

### 3. 桌面入口优先切换内嵌视图

在 `MemosListRouteDelegate` 或 `MemosListScreen` 组合层提供回调，让桌面主页里的：

- drawer quick action `sync_queue`
- drawer quick action `notifications`
- Windows/macOS titlebar notification action
- sync error retry “打开同步队列”

优先切换到 embedded utility view。非桌面端、非主页场景继续使用原 route。

### 4. 侧边栏选中状态清空

当 embedded utility view 显示时：

- `AppDrawer.selected` SHOULD be `null`
- `selectedTagPath` SHOULD be `null`
- 回到 memos 或 tag 时清除 utility view

这表达“同步队列/消息通知是临时工作区视图，不属于主 destination 选中态”。

### 5. 内嵌返回只清空主页 utility 状态

同步队列和消息通知在 `desktopEmbedded` 模式下接收主页 shell 传入的返回回调。局部返回按钮不执行 route pop，也不关闭窗口；它只清除 `_DesktopHomeUtilityView`，让主内容列恢复为 inline compose + memo list。

### 6. 所有桌面抽屉入口共享主页 utility 目的地

桌面端从探索、统计、标签、资源、回收站、设置等其他抽屉页面点击同步队列或消息通知时，不应打开 standalone utility route。入口应先回到 `MemosListScreen` 主页 shell，并通过 `initialDesktopUtilityView` 打开对应 utility view。

这条规则避免“只有全部笔记页是内嵌体验，其他页面仍是旧二级页体验”的分叉。移动端和 `embeddedBottomNav` 仍通过 `HomeEmbeddedNavigationHost` 保持原有行为。

## Risks / Trade-offs

- [Risk] 把完整页面嵌入主页会形成 nested shell。  
  Mitigation：只嵌入 body/content widget，不嵌入 standalone `PlatformPage` / `DesktopShellHost`。

- [Risk] 桌面和移动入口行为分叉导致测试遗漏。  
  Mitigation：新增 focused tests 覆盖桌面入口切换为 embedded view，移动/standalone 行为保持 route。

- [Risk] `MemosListScreen` 已较重，继续加入状态会增加复杂度。  
  Mitigation：状态只负责 composition，不搬运同步/通知业务逻辑；同时补 guardrail 防止 utility body 拥有顶层 chrome。

## Modularity Notes

本 change 触及 `features/memos` 与 `features/sync` / `features/notifications` 的 feature-to-feature 协作，属于现有耦合热点。为满足 `evolve_modularity` 要求：

- 把共享的“embedded vs standalone chrome ownership”收敛为显式 presentation/body seam，而不是让 `MemosListScreen` 复制同步或通知业务逻辑。
- 增加 source/widget guardrail，防止桌面 utility embedding 重新嵌入完整 page shell 或页面级 `AppBar`。
