import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memos_flutter_app/data/models/home_navigation_preferences.dart';
import 'package:memos_flutter_app/features/home/home_navigation_host.dart';
import 'package:memos_flutter_app/features/home/home_root_destination_registry.dart';
import 'package:memos_flutter_app/features/memos/draft_box_navigation_screen.dart';
import 'package:memos_flutter_app/features/memos/memos_list_screen.dart';
import 'package:memos_flutter_app/features/home/app_drawer.dart';

void main() {
  testWidgets('memos root screen enables resizable home inline compose', (
    tester,
  ) async {
    Widget? built;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            built = buildHomeRootScreen(
              context: context,
              destination: HomeRootDestination.memos,
              presentation: HomeScreenPresentation.standalone,
              navigationHost: null,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(built, isA<MemosListScreen>());
    expect(
      (built! as MemosListScreen).enableDesktopResizableHomeInlineCompose,
      isTrue,
    );
  });

  testWidgets(
    'embedded memos root keeps resizable home inline compose disabled',
    (tester) async {
      Widget? built;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              built = buildHomeRootScreen(
                context: context,
                destination: HomeRootDestination.memos,
                presentation: HomeScreenPresentation.embeddedBottomNav,
                navigationHost: null,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(built, isA<MemosListScreen>());
      expect(
        (built! as MemosListScreen).enableDesktopResizableHomeInlineCompose,
        isFalse,
      );
    },
  );

  testWidgets('draft box root has registry metadata and screen builder', (
    tester,
  ) async {
    Widget? built;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            built = buildHomeRootScreen(
              context: context,
              destination: HomeRootDestination.draftBox,
              presentation: HomeScreenPresentation.embeddedBottomNav,
              navigationHost: null,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final definition = homeRootDestinationDefinition(
      HomeRootDestination.draftBox,
    );
    expect(definition, isNotNull);
    expect(definition!.drawerDestination, AppDrawerDestination.draftBox);
    expect(definition.icon, Icons.inventory_2_outlined);
    expect(built, isA<DraftBoxNavigationScreen>());
  });
}
