import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final repoRoot = Directory.current.parent;

  String readRepoFile(String relativePath) {
    return File(
      '${repoRoot.path}${Platform.pathSeparator}$relativePath',
    ).readAsStringSync();
  }

  test('public shell depends on bundle provider seam only', () {
    final appContent = readRepoFile('memos_flutter_app/lib/app.dart');
    final settingsContent = readRepoFile(
      'memos_flutter_app/lib/features/settings/settings_screen.dart',
    );

    expect(
      appContent.contains('private_extension_bundle_provider.dart'),
      isTrue,
    );
    expect(
      settingsContent.contains('private_extension_bundle_provider.dart'),
      isTrue,
    );
    expect(settingsContent.contains('access_boundary/'), isFalse);
    expect(appContent.contains('access_boundary/'), isFalse);
  });

  test('public settings shell does not read commercial state', () {
    final settingsContent = readRepoFile(
      'memos_flutter_app/lib/features/settings/settings_screen.dart',
    );

    const forbiddenTerms = <String>[
      'access_boundary/',
      'AppCapability',
      'AccessDecision',
      'StoreKit',
      'productId',
      'receipt',
      'buyout',
      'familySharing',
      'entitlement',
      'paywall',
    ];

    final violations = <String>[
      for (final term in forbiddenTerms)
        if (settingsContent.contains(term)) term,
    ];

    expect(
      violations,
      isEmpty,
      reason: violations.isEmpty
          ? null
          : 'settings_screen.dart must render private bundle contributions '
                'without commercial branching: ${violations.join(', ')}',
    );
  });

  test('public active bundle remains a no-op implementation', () {
    final activeBundle = readRepoFile(
      'memos_flutter_app/lib/private_hooks/active_private_extension_bundle.dart',
    );

    expect(activeBundle.contains('public-default'), isTrue);
    expect(
      activeBundle.contains('return const <SettingsEntryContribution>[];'),
      isTrue,
    );
  });

  test('legacy root lib duplicates stay removed', () {
    expect(
      File(
        '${repoRoot.path}${Platform.pathSeparator}lib${Platform.pathSeparator}data${Platform.pathSeparator}models${Platform.pathSeparator}shortcut.dart',
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        '${repoRoot.path}${Platform.pathSeparator}lib${Platform.pathSeparator}data${Platform.pathSeparator}models${Platform.pathSeparator}user_setting.dart',
      ).existsSync(),
      isFalse,
    );
  });
}
