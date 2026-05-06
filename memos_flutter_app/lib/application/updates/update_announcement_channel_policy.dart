import 'package:flutter/foundation.dart';

import '../../core/app_channel.dart';

bool shouldFetchStartupUpdateAnnouncementsForCurrentBuild() {
  return shouldFetchStartupUpdateAnnouncements(
    channel: currentAppChannel,
    targetPlatform: defaultTargetPlatform,
    isWeb: kIsWeb,
  );
}

@visibleForTesting
bool shouldFetchStartupUpdateAnnouncements({
  required AppChannel channel,
  required TargetPlatform targetPlatform,
  bool isWeb = false,
}) {
  if (isWeb) return true;
  return !(targetPlatform == TargetPlatform.android &&
      channel == AppChannel.play);
}
