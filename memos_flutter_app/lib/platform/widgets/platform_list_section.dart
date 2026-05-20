import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../platform_target.dart';

class PlatformListSection extends StatelessWidget {
  const PlatformListSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.padding,
    this.desktopBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.showDesktopDividers = true,
  });

  final List<Widget> children;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry desktopBorderRadius;
  final bool showDesktopDividers;

  @override
  Widget build(BuildContext context) {
    final target = resolvePlatformTarget(context);
    if (target == PlatformTarget.iPhone || target == PlatformTarget.iPad) {
      return CupertinoListSection.insetGrouped(
        header: header,
        footer: footer,
        margin: padding,
        children: children,
      );
    }

    final isDesktop =
        target == PlatformTarget.macOS ||
        target == PlatformTarget.windows ||
        target == PlatformTarget.linux;
    if (isDesktop) {
      return Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) _PlatformSectionLabel(child: header!),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.65),
                ),
                borderRadius: desktopBorderRadius,
              ),
              child: ClipRRect(
                borderRadius: desktopBorderRadius,
                child: Material(
                  color: Colors.transparent,
                  child: Column(children: _desktopChildren(context)),
                ),
              ),
            ),
            if (footer != null) _PlatformSectionLabel(child: footer!),
          ],
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) _PlatformSectionLabel(child: header!),
            ...children,
            if (footer != null) _PlatformSectionLabel(child: footer!),
          ],
        ),
      ),
    );
  }

  List<Widget> _desktopChildren(BuildContext context) {
    if (!showDesktopDividers || children.length < 2) return children;

    final dividerColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.55);
    final separated = <Widget>[];
    for (var index = 0; index < children.length; index += 1) {
      if (index > 0) {
        separated.add(Divider(height: 1, thickness: 1, color: dividerColor));
      }
      separated.add(children[index]);
    }
    return separated;
  }
}

class PlatformListSectionRow extends StatelessWidget {
  const PlatformListSectionRow({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    this.onTap,
    this.danger = false,
    this.denseOnDesktop = true,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final bool danger;
  final bool denseOnDesktop;

  @override
  Widget build(BuildContext context) {
    final target = resolvePlatformTarget(context);
    if (target == PlatformTarget.iPhone || target == PlatformTarget.iPad) {
      return CupertinoListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      );
    }

    final isDesktop =
        target == PlatformTarget.macOS ||
        target == PlatformTarget.windows ||
        target == PlatformTarget.linux;
    final compact = isDesktop && denseOnDesktop;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: compact,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      minLeadingWidth: compact ? 24 : null,
      minVerticalPadding: compact ? 8 : null,
      contentPadding:
          contentPadding ??
          (compact
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 0)
              : null),
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      textColor: danger ? colorScheme.error : null,
      iconColor: danger ? colorScheme.error : null,
    );
  }
}

class _PlatformSectionLabel extends StatelessWidget {
  const _PlatformSectionLabel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 6),
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        child: child,
      ),
    );
  }
}
