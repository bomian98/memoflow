import 'package:flutter/foundation.dart';

const double kMemoFlowDesktopSidePaneBreakpoint = 1100;
const double kMemoFlowDesktopDrawerWidth = 320;
const double kMemoFlowDesktopContentMaxWidth = 980;
const double kMemoFlowDesktopMemoCardMaxWidth = 760;
const double kMemoFlowDesktopPreviewPaneBreakpoint = 1440;
const double kMemoFlowDesktopPreviewPaneWidth = 460;
const double kMemoFlowDesktopPreviewListMinWidth = 560;
const double kMemoFlowInlineComposeBreakpoint = 760;
const double kWindowsDesktopNarrowBreakpoint = 960;
const double kWindowsDesktopExpandedBreakpoint = 1200;
const double kWindowsDesktopWideBreakpoint = 1360;
const double kDesktopMemoListExpandedBreakpoint =
    kWindowsDesktopExpandedBreakpoint;
const double kDesktopMemoListWideBreakpoint = kWindowsDesktopWideBreakpoint;
const double kWindowsDesktopSidebarWidth = 280;
const double kWindowsDesktopRailWidth = 72;
const double kWindowsDesktopSecondaryPaneDefaultWidth = 420;
const double kWindowsDesktopSecondaryPaneMinWidth = 360;
const double kWindowsDesktopSecondaryPaneMaxWidth = 560;

enum WindowsDesktopLayoutTier { narrow, compact, expanded, wide }

enum DesktopMemoListLayoutTier { narrow, compact, expanded, wide }

enum WindowsDesktopNavMode { overlay, rail, expanded }

class DesktopMemoListLayoutSpec {
  const DesktopMemoListLayoutSpec({
    required this.tier,
    required this.supportsPreviewPane,
    required this.defaultMemoClickOpensPreview,
  });

  final DesktopMemoListLayoutTier tier;
  final bool supportsPreviewPane;
  final bool defaultMemoClickOpensPreview;
}

class WindowsDesktopLayoutSpec {
  const WindowsDesktopLayoutSpec({
    required this.tier,
    required this.navMode,
    required this.supportsSecondaryPane,
    required this.defaultSecondaryPaneVisible,
    required this.defaultSecondaryPaneWidth,
  });

  final WindowsDesktopLayoutTier tier;
  final WindowsDesktopNavMode navMode;
  final bool supportsSecondaryPane;
  final bool defaultSecondaryPaneVisible;
  final double defaultSecondaryPaneWidth;
}

bool isDesktopTargetPlatform([TargetPlatform? platform]) {
  final value = platform ?? defaultTargetPlatform;
  return value == TargetPlatform.windows ||
      value == TargetPlatform.macOS ||
      value == TargetPlatform.linux;
}

bool isAlignedDesktopMemoPreviewPlatform([TargetPlatform? platform]) {
  final value = platform ?? defaultTargetPlatform;
  return value == TargetPlatform.windows || value == TargetPlatform.macOS;
}

DesktopMemoListLayoutSpec resolveDesktopMemoListLayout(
  double width, {
  TargetPlatform? platform,
}) {
  if (!isAlignedDesktopMemoPreviewPlatform(platform)) {
    return const DesktopMemoListLayoutSpec(
      tier: DesktopMemoListLayoutTier.narrow,
      supportsPreviewPane: false,
      defaultMemoClickOpensPreview: false,
    );
  }

  if (width < kWindowsDesktopNarrowBreakpoint) {
    return const DesktopMemoListLayoutSpec(
      tier: DesktopMemoListLayoutTier.narrow,
      supportsPreviewPane: false,
      defaultMemoClickOpensPreview: false,
    );
  }

  if (width < kDesktopMemoListExpandedBreakpoint) {
    return const DesktopMemoListLayoutSpec(
      tier: DesktopMemoListLayoutTier.compact,
      supportsPreviewPane: false,
      defaultMemoClickOpensPreview: false,
    );
  }

  if (width < kDesktopMemoListWideBreakpoint) {
    return const DesktopMemoListLayoutSpec(
      tier: DesktopMemoListLayoutTier.expanded,
      supportsPreviewPane: true,
      defaultMemoClickOpensPreview: false,
    );
  }

  return const DesktopMemoListLayoutSpec(
    tier: DesktopMemoListLayoutTier.wide,
    supportsPreviewPane: true,
    defaultMemoClickOpensPreview: true,
  );
}

WindowsDesktopLayoutSpec resolveWindowsDesktopLayout(
  double width, {
  TargetPlatform? platform,
}) {
  final resolvedPlatform = platform ?? defaultTargetPlatform;
  if (resolvedPlatform != TargetPlatform.windows) {
    return const WindowsDesktopLayoutSpec(
      tier: WindowsDesktopLayoutTier.narrow,
      navMode: WindowsDesktopNavMode.overlay,
      supportsSecondaryPane: false,
      defaultSecondaryPaneVisible: false,
      defaultSecondaryPaneWidth: kWindowsDesktopSecondaryPaneDefaultWidth,
    );
  }

  if (width < kWindowsDesktopNarrowBreakpoint) {
    return const WindowsDesktopLayoutSpec(
      tier: WindowsDesktopLayoutTier.narrow,
      navMode: WindowsDesktopNavMode.overlay,
      supportsSecondaryPane: false,
      defaultSecondaryPaneVisible: false,
      defaultSecondaryPaneWidth: kWindowsDesktopSecondaryPaneDefaultWidth,
    );
  }

  if (width < kWindowsDesktopExpandedBreakpoint) {
    return const WindowsDesktopLayoutSpec(
      tier: WindowsDesktopLayoutTier.compact,
      navMode: WindowsDesktopNavMode.rail,
      supportsSecondaryPane: false,
      defaultSecondaryPaneVisible: false,
      defaultSecondaryPaneWidth: kWindowsDesktopSecondaryPaneDefaultWidth,
    );
  }

  if (width < kWindowsDesktopWideBreakpoint) {
    return const WindowsDesktopLayoutSpec(
      tier: WindowsDesktopLayoutTier.expanded,
      navMode: WindowsDesktopNavMode.expanded,
      supportsSecondaryPane: true,
      defaultSecondaryPaneVisible: false,
      defaultSecondaryPaneWidth: kWindowsDesktopSecondaryPaneDefaultWidth,
    );
  }

  return const WindowsDesktopLayoutSpec(
    tier: WindowsDesktopLayoutTier.wide,
    navMode: WindowsDesktopNavMode.expanded,
    supportsSecondaryPane: true,
    defaultSecondaryPaneVisible: true,
    defaultSecondaryPaneWidth: kWindowsDesktopSecondaryPaneDefaultWidth,
  );
}

bool shouldUseWindowsOverlayNav(double width, {TargetPlatform? platform}) {
  final resolvedPlatform = platform ?? defaultTargetPlatform;
  if (resolvedPlatform != TargetPlatform.windows) return false;
  return resolveWindowsDesktopLayout(width, platform: platform).navMode ==
      WindowsDesktopNavMode.overlay;
}

bool shouldUseWindowsRailNav(double width, {TargetPlatform? platform}) {
  final resolvedPlatform = platform ?? defaultTargetPlatform;
  if (resolvedPlatform != TargetPlatform.windows) return false;
  return resolveWindowsDesktopLayout(width, platform: platform).navMode ==
      WindowsDesktopNavMode.rail;
}

bool shouldUseWindowsExpandedSidebar(double width, {TargetPlatform? platform}) {
  final resolvedPlatform = platform ?? defaultTargetPlatform;
  if (resolvedPlatform != TargetPlatform.windows) return false;
  return resolveWindowsDesktopLayout(width, platform: platform).navMode ==
      WindowsDesktopNavMode.expanded;
}

bool shouldUseWindowsSecondaryPane(double width, {TargetPlatform? platform}) {
  final resolvedPlatform = platform ?? defaultTargetPlatform;
  if (resolvedPlatform != TargetPlatform.windows) return false;
  return resolveWindowsDesktopLayout(
    width,
    platform: platform,
  ).supportsSecondaryPane;
}

bool shouldUseDesktopSidePaneLayout(
  double width, {
  double breakpoint = kMemoFlowDesktopSidePaneBreakpoint,
}) {
  return isDesktopTargetPlatform() && width >= breakpoint;
}

bool shouldUseDesktopPreviewPaneLayout(
  double width, {
  double breakpoint = kMemoFlowDesktopPreviewPaneBreakpoint,
  TargetPlatform? platform,
}) {
  return isDesktopTargetPlatform(platform) && width >= breakpoint;
}

bool shouldUseInlineComposeLayout(
  double width, {
  double breakpoint = kMemoFlowInlineComposeBreakpoint,
}) {
  // Enable for desktop and wide tablet-like layouts.
  return width >= breakpoint;
}
