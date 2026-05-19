import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_action_sheet.dart';

Future<T?> showPlatformPicker<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showPlatformActionSheet<T>(context: context, builder: builder);
}
