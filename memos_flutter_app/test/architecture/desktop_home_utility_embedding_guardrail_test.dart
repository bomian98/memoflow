import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('desktop utility views embed content without owning page chrome', () async {
    final homeHost = await File(
      'lib/features/home/home_navigation_host.dart',
    ).readAsString();
    final memosList = await File(
      'lib/features/memos/memos_list_screen.dart',
    ).readAsString();
    final destinationBuilder = await File(
      'lib/features/home/app_drawer_destination_builder.dart',
    ).readAsString();
    final memosBody = await File(
      'lib/features/memos/widgets/memos_list_screen_body.dart',
    ).readAsString();
    final syncQueue = await File(
      'lib/features/sync/sync_queue_screen.dart',
    ).readAsString();
    final notifications = await File(
      'lib/features/notifications/notifications_screen.dart',
    ).readAsString();
    final stats = await File(
      'lib/features/stats/stats_screen.dart',
    ).readAsString();
    final secondaryDrawerPages = <String>[
      'lib/features/about/about_screen.dart',
      'lib/features/collections/collections_screen.dart',
      'lib/features/explore/explore_screen.dart',
      'lib/features/memos/draft_box_navigation_screen.dart',
      'lib/features/memos/recycle_bin_screen.dart',
      'lib/features/resources/resources_screen.dart',
      'lib/features/review/ai_summary_screen.dart',
      'lib/features/review/daily_review_screen.dart',
      'lib/features/settings/settings_screen.dart',
      'lib/features/tags/tags_screen.dart',
    ];

    expect(homeHost.contains('desktopEmbedded'), isTrue);
    expect(memosList.contains('DesktopHomeUtilityView'), isTrue);
    expect(memosList.contains('initialDesktopUtilityView'), isTrue);
    expect(memosList.contains('desktopPrimaryContentOverride'), isTrue);
    expect(memosList.contains('onDesktopEmbeddedBack'), isTrue);
    expect(
      destinationBuilder.contains('openDesktopHomeUtilityDestination'),
      isTrue,
    );
    expect(
      destinationBuilder.contains('openNotificationsDrawerDestination'),
      isTrue,
    );
    expect(
      destinationBuilder.contains('DesktopHomeUtilityView.syncQueue'),
      isTrue,
    );
    expect(
      destinationBuilder.contains('DesktopHomeUtilityView.notifications'),
      isTrue,
    );
    expect(
      destinationBuilder.contains('DesktopHomeUtilityView.draftBox'),
      isTrue,
    );
    expect(
      memosList.contains(
        'DesktopHomeUtilityView.draftBox => AppDrawerDestination.draftBox',
      ),
      isTrue,
      reason: 'Draft Box utility should keep the sidebar destination selected.',
    );
    expect(memosList.contains('DesktopHomeUtilityView.draftBox'), isTrue);
    expect(
      memosList.contains('DesktopHomeUtilityView.draftBox => DraftBoxScreen'),
      isTrue,
      reason:
          'Draft Box should render through the Home primary content override.',
    );
    expect(memosBody.contains('desktopPrimaryContentOverride'), isTrue);

    for (final source in <String>[syncQueue, notifications]) {
      expect(source.contains('HomeScreenPresentation.desktopEmbedded'), isTrue);
      expect(source.contains('DesktopEmbeddedUtilitySurface'), isTrue);
      expect(source.contains('onDesktopEmbeddedBack'), isTrue);
      expect(source.contains('backTooltip'), isTrue);
    }

    for (final path in secondaryDrawerPages) {
      final source = await File(path).readAsString();
      expect(
        source.contains('openNotificationsDrawerDestination'),
        isTrue,
        reason: '$path should use shared desktop utility navigation.',
      );
      expect(
        source.contains(
          'closeDrawerThenPushReplacement(context, const NotificationsScreen())',
        ),
        isFalse,
        reason: '$path should not open standalone notifications directly.',
      );
    }
    expect(stats.contains('openDesktopHomeUtilityDestination'), isTrue);
    expect(stats.contains('DesktopHomeUtilityView.syncQueue'), isTrue);
  });
}
