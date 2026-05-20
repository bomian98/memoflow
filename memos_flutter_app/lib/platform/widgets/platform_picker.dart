import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_popover_or_sheet.dart';

Future<T?> showPlatformPicker<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double desktopMaxWidth = 420,
}) {
  return showPlatformPopoverOrSheet<T>(
    context: context,
    builder: builder,
    desktopMaxWidth: desktopMaxWidth,
  );
}
