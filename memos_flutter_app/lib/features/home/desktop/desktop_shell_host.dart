import 'package:flutter/material.dart';

import '../../../core/platform_layout.dart';
import '../app_drawer.dart';
import 'windows_desktop_page_shell.dart';
export 'windows_desktop_workspace_shell.dart'
    show
        WindowsDesktopModalSurfaceMotionSpec,
        WindowsDesktopSecondaryPaneMotionSpec,
        WindowsDesktopSecondaryPanePresentation;

typedef DesktopShellNavigationBuilder =
    Widget Function(AppDrawerViewMode viewMode, bool embedded);

class DesktopShellHost extends StatelessWidget {
  const DesktopShellHost({
    super.key,
    required this.navigationBuilder,
    required this.leadingTitle,
    required this.body,
    this.commandBar,
    this.center,
    this.trailing,
    this.secondaryPane,
    this.secondaryPaneVisible = false,
    this.secondaryPaneWidth = kWindowsDesktopSecondaryPaneDefaultWidth,
    this.secondaryPanePresentation =
        WindowsDesktopSecondaryPanePresentation.inline,
    this.secondaryPaneMotionSpec,
    this.onSecondaryPaneWidthChanged,
    this.modalSurface,
    this.modalSurfaceVisible = false,
    this.modalBarrierColor = const Color(0x66000000),
    this.modalBarrierBlurSigma = 14,
    this.modalSurfaceMotionSpec,
    this.backgroundColor,
    this.showWindowControls = true,
  });

  final DesktopShellNavigationBuilder navigationBuilder;
  final Widget leadingTitle;
  final Widget body;
  final Widget? commandBar;
  final Widget? center;
  final Widget? trailing;
  final Widget? secondaryPane;
  final bool secondaryPaneVisible;
  final double secondaryPaneWidth;
  final WindowsDesktopSecondaryPanePresentation secondaryPanePresentation;
  final WindowsDesktopSecondaryPaneMotionSpec? secondaryPaneMotionSpec;
  final ValueChanged<double>? onSecondaryPaneWidthChanged;
  final Widget? modalSurface;
  final bool modalSurfaceVisible;
  final Color modalBarrierColor;
  final double modalBarrierBlurSigma;
  final WindowsDesktopModalSurfaceMotionSpec? modalSurfaceMotionSpec;
  final Color? backgroundColor;
  final bool showWindowControls;

  @override
  Widget build(BuildContext context) {
    return WindowsDesktopPageShell(
      navigationBuilder: navigationBuilder,
      leadingTitle: leadingTitle,
      body: body,
      commandBar: commandBar,
      center: center,
      trailing: trailing,
      secondaryPane: secondaryPane,
      secondaryPaneVisible: secondaryPaneVisible,
      secondaryPaneWidth: secondaryPaneWidth,
      secondaryPanePresentation: secondaryPanePresentation,
      secondaryPaneMotionSpec: secondaryPaneMotionSpec,
      onSecondaryPaneWidthChanged: onSecondaryPaneWidthChanged,
      modalSurface: modalSurface,
      modalSurfaceVisible: modalSurfaceVisible,
      modalBarrierColor: modalBarrierColor,
      modalBarrierBlurSigma: modalBarrierBlurSigma,
      modalSurfaceMotionSpec: modalSurfaceMotionSpec,
      backgroundColor: backgroundColor,
      showWindowControls: showWindowControls,
    );
  }
}
