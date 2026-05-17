import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'memo engagement loading and mutations stay in the state seam',
    () async {
      final stateFile = File('lib/state/memos/memo_engagement_provider.dart');
      final stateContents = await stateFile.readAsString();

      const requiredStatePatterns = <String>{
        'listMemoReactions(',
        'listMemoComments(',
        'upsertMemoReaction(',
        'deleteMemoReaction(',
        'createMemoComment(',
      };

      final missing = requiredStatePatterns
          .where((pattern) => !stateContents.contains(pattern))
          .toList(growable: false);

      expect(
        missing,
        isEmpty,
        reason: missing.isEmpty
            ? null
            : 'Memo engagement API ownership should stay in '
                  'memo_engagement_provider.dart:\n${missing.join('\n')}',
      );

      final featureFiles = <File>[
        File('lib/features/memos/memo_detail_screen.dart'),
        File('lib/features/memos/widgets/memos_list_memo_card.dart'),
        File('lib/features/memos/widgets/memo_engagement_surface.dart'),
      ];
      final violations = <String>[];
      for (final file in featureFiles) {
        final contents = await file.readAsString();
        for (final pattern in requiredStatePatterns) {
          if (contents.contains(pattern)) {
            violations.add('${file.path}: $pattern');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: violations.isEmpty
            ? null
            : 'Feature files must consume memoEngagementControllerProvider '
                  'instead of owning engagement API calls:\n'
                  '${violations.join('\n')}',
      );
    },
  );
}
