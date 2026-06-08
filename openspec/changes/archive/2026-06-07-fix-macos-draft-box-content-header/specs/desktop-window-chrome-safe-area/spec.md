## ADDED Requirements

### Requirement: Desktop navigation Draft Box SHALL NOT own window chrome geometry
桌面导航型草稿箱 SHALL NOT calculate or reserve native window-control geometry itself. When opened from Home navigation, Draft Box SHALL be embedded in Home primary content so the existing Home desktop shell remains the sole owner of window chrome, drag regions, native traffic-light/caption-control avoidance, titlebar / command bar layout, and global actions.

#### Scenario: Home shell owns desktop window chrome
- **WHEN** Draft Box is opened from sidebar, Home root destination, or macOS menu on desktop
- **THEN** the existing Home desktop shell SHALL continue to own window chrome and global titlebar / command bar layout
- **AND** Draft Box SHALL render only as primary content
- **AND** Draft Box SHALL NOT introduce feature-local traffic-light, caption-control, or titlebar leading padding constants

#### Scenario: Embedded Draft Box does not create a desktop destination shell
- **WHEN** `DraftBoxScreen` is rendered with `HomeScreenPresentation.desktopEmbedded`
- **THEN** it SHALL use the embedded utility surface provided by Home
- **AND** it SHALL NOT create `DesktopDestinationShell`, `AppleMacosPageShell`, or `WindowsDesktopPageShell`
- **AND** it SHALL NOT duplicate window chrome safe-area behavior

#### Scenario: Selector chrome remains separate from Home navigation
- **WHEN** `DraftBoxScreen.show()` opens a desktop selector route without sidebar/Home utility context
- **THEN** selector-specific Back/title UI MAY render in route content
- **AND** any desktop chrome avoidance SHALL use shared shell/platform seams rather than Draft Box-local magic geometry

#### Scenario: Mobile Draft Box chrome remains unchanged
- **WHEN** Draft Box renders on mobile or web outside the desktop Home shell contract
- **THEN** it SHALL preserve that platform's existing AppBar or route chrome behavior
- **AND** it SHALL NOT apply macOS-only or Windows-only desktop window-control geometry
