import 'package:flutter_test/flutter_test.dart';
import 'package:memos_flutter_app/i18n/strings.g.dart';

void main() {
  test('engagement preference copy mentions home cards and memo details', () {
    expect(
      AppLocale.en
          .build()
          .strings
          .settings
          .preferences
          .showEngagementInAllMemoDetails,
      'Show likes and comments on home cards and memo details',
    );
    expect(
      AppLocale.de
          .build()
          .strings
          .settings
          .preferences
          .showEngagementInAllMemoDetails,
      contains('Startkarten'),
    );
    expect(
      AppLocale.ja
          .build()
          .strings
          .settings
          .preferences
          .showEngagementInAllMemoDetails,
      contains('ホームカード'),
    );
    expect(
      AppLocale.ko
          .build()
          .strings
          .settings
          .preferences
          .showEngagementInAllMemoDetails,
      contains('홈 카드'),
    );
    expect(
      AppLocale.ptBr
          .build()
          .strings
          .settings
          .preferences
          .showEngagementInAllMemoDetails,
      contains('cartões'),
    );
    expect(
      AppLocale.zhHans
          .build()
          .strings
          .settings
          .preferences
          .showEngagementInAllMemoDetails,
      contains('首页卡片'),
    );
    expect(
      AppLocale.zhHantTw
          .build()
          .strings
          .settings
          .preferences
          .showEngagementInAllMemoDetails,
      contains('首頁卡片'),
    );
  });
}
