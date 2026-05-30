import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memos_flutter_app/data/models/collection_reader.dart';
import 'package:memos_flutter_app/features/collections/collection_reader_animation_delegate.dart';
import 'package:memos_flutter_app/features/collections/collection_reader_page_models.dart';
import 'package:memos_flutter_app/features/collections/collection_reader_paged_view.dart';
import 'package:memos_flutter_app/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('paged view builds without ticker provider errors', (
    tester,
  ) async {
    LocaleSettings.setLocale(AppLocale.en);

    const page = ReaderPage(
      memoUid: 'memo-1',
      memoIndex: 0,
      chapterPageIndex: 0,
      contentCharStart: 0,
      contentCharEnd: 11,
      blocks: <ReaderPageBlock>[
        ReaderPageBlock(
          kind: ReaderBlockKind.markdownText,
          id: 'block-1',
          text: 'Hello reader',
          charStart: 0,
          charEnd: 11,
        ),
      ],
      isFirstPage: true,
      isLastPage: true,
      reservedInsets: ReaderPageReservedInsets.zero,
      headerTip: null,
      footerTip: null,
      title: null,
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          locale: AppLocale.en.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const Scaffold(
            body: CollectionReaderPagedView(
              currentPage: page,
              previousPage: null,
              nextPage: null,
              canGoPrevious: false,
              canGoNext: false,
              preferences: CollectionReaderPreferences.defaults,
              turnDirection: ReaderPageTurnDirection.none,
              highlightQuery: null,
              highlightMemoUid: null,
              collectionTitle: 'Collection A',
              currentGlobalPageIndex: 0,
              totalPages: 1,
              viewportSize: Size(800, 600),
              previewImageOnTap: true,
              onShowSearch: _noop,
              onShowToc: _noop,
              onPrevChapter: _noop,
              onNextChapter: _noop,
              onCenterTap: _noop,
              onPrevPage: _noop,
              onNextPage: _noop,
              onUserInteraction: _noop,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Hello reader'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
