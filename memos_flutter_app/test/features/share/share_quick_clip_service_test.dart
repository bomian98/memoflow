import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memos_flutter_app/application/sync/sync_request.dart';
import 'package:memos_flutter_app/data/api/memos_api.dart';
import 'package:memos_flutter_app/data/db/app_database.dart';
import 'package:memos_flutter_app/data/models/user_setting.dart';
import 'package:memos_flutter_app/features/share/share_capture_engine.dart';
import 'package:memos_flutter_app/features/share/share_clip_models.dart';
import 'package:memos_flutter_app/features/share/share_handler.dart';
import 'package:memos_flutter_app/features/share/share_quick_clip_models.dart';
import 'package:memos_flutter_app/features/share/share_quick_clip_service.dart';
import 'package:memos_flutter_app/features/share/share_inline_image_download_service.dart';
import 'package:memos_flutter_app/features/share/share_video_attachment_preparer.dart';
import 'package:memos_flutter_app/features/share/share_video_download_service.dart';
import 'package:memos_flutter_app/state/memos/app_bootstrap_adapter_provider.dart';
import 'package:memos_flutter_app/state/system/database_provider.dart';

import '../../test_support.dart';

void main() {
  late TestSupport support;

  setUpAll(() async {
    support = await initializeTestSupport();
  });

  tearDownAll(() async {
    await support.dispose();
  });

  group('ShareQuickClipService', () {
    test(
      'title-and-link-only completes without waiting for background sync',
      () async {
        final testDb = await _createDatabase('share_quick_clip_link_only');
        final db = testDb.database;
        addTearDown(() async {
          await db.close();
          await deleteTestDatabase(testDb.dbName);
        });

        final syncCompleter = Completer<void>();
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWith((_) => db)],
        );
        addTearDown(container.dispose);

        final service = ShareQuickClipService(
          ref: _FakeWidgetRef(container),
          bootstrapAdapter: _FakeAppBootstrapAdapter(
            userSetting: const UserGeneralSetting(memoVisibility: 'PUBLIC'),
            requestSyncHandler: (ref, request) => syncCompleter.future,
          ),
        );

        await service
            .start(
              payload: const SharePayload(
                type: SharePayloadType.text,
                text: 'https://example.com/articles/1',
                title: 'Example article',
              ),
              submission: const ShareQuickClipSubmission(
                tags: <String>['#clip', 'reading'],
                textOnly: false,
                titleAndLinkOnly: true,
              ),
              locale: const Locale('en'),
            )
            .timeout(
              const Duration(milliseconds: 300),
              onTimeout: () => fail('start() should not wait for requestSync'),
            );

        final memos = await db.listMemos(limit: 10);
        expect(memos, hasLength(1));
        expect(memos.single['content'] as String, contains('Example article'));
        expect(await db.countOutboxPending(), 1);
      },
    );

    test('title-and-link-only ignores sync errors after local save', () async {
      final testDb = await _createDatabase('share_quick_clip_sync_error');
      final db = testDb.database;
      addTearDown(() async {
        await db.close();
        await deleteTestDatabase(testDb.dbName);
      });

      final bootstrapAdapter = _FakeAppBootstrapAdapter(
        userSetting: const UserGeneralSetting(memoVisibility: 'PUBLIC'),
        requestSyncHandler: (ref, request) async {
          throw StateError('offline');
        },
      );
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWith((_) => db)],
      );
      addTearDown(container.dispose);

      final service = ShareQuickClipService(
        ref: _FakeWidgetRef(container),
        bootstrapAdapter: bootstrapAdapter,
      );

      await service.start(
        payload: const SharePayload(
          type: SharePayloadType.text,
          text: 'https://example.com/articles/2',
          title: 'Offline article',
        ),
        submission: const ShareQuickClipSubmission(
          tags: <String>['#offline'],
          textOnly: false,
          titleAndLinkOnly: true,
        ),
        locale: const Locale('en'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final memos = await db.listMemos(limit: 10);
      expect(memos, hasLength(1));
      expect(memos.single['content'] as String, contains('Offline article'));
      expect(await db.countOutboxPending(), 1);
      expect(bootstrapAdapter.requestSyncCallCount, 1);
    });

    test(
      'full quick clip returns after placeholder save and continues capture in background',
      () async {
        final testDb = await _createDatabase(
          'share_quick_clip_background_capture',
        );
        final db = testDb.database;
        addTearDown(() async {
          await db.close();
          await deleteTestDatabase(testDb.dbName);
        });

        final engine = _CompleterShareCaptureEngine(
          ShareCaptureResult.success(
            finalUrl: Uri.parse('https://example.com/articles/final'),
            articleTitle: 'Captured Title',
            excerpt: 'Captured excerpt',
            textContent: 'Captured body',
            pageKind: SharePageKind.article,
          ),
        );
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWith((_) => db)],
        );
        addTearDown(container.dispose);

        final service = ShareQuickClipService(
          ref: _FakeWidgetRef(container),
          bootstrapAdapter: _FakeAppBootstrapAdapter(
            userSetting: const UserGeneralSetting(memoVisibility: 'PUBLIC'),
            requestSyncHandler: (ref, request) async {
              throw StateError('sync unavailable');
            },
          ),
          engine: engine,
        );

        await service
            .start(
              payload: const SharePayload(
                type: SharePayloadType.text,
                text: 'https://example.com/articles/final',
                title: 'Example article',
              ),
              submission: const ShareQuickClipSubmission(
                tags: <String>['#clip'],
                textOnly: false,
                titleAndLinkOnly: false,
              ),
              locale: const Locale('en'),
            )
            .timeout(
              const Duration(milliseconds: 300),
              onTimeout: () =>
                  fail('start() should return after placeholder save'),
            );

        final placeholderMemos = await db.listMemos(limit: 10);
        expect(placeholderMemos, hasLength(1));
        expect(
          placeholderMemos.single['content'] as String,
          contains('Clipping...'),
        );
        expect(await db.countOutboxPending(), 1);

        engine.complete();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final updatedMemos = await db.listMemos(limit: 10);
        expect(updatedMemos, hasLength(1));
        expect(
          updatedMemos.single['content'] as String,
          contains('Captured Title'),
        );
      },
    );

    test(
      'full Xiaohongshu video quick clip appends video attachment',
      () async {
        final testDb = await _createDatabase('share_quick_clip_xhs_video');
        final db = testDb.database;
        addTearDown(() async {
          await db.close();
          await deleteTestDatabase(testDb.dbName);
        });
        final videoFile = await support.createTempDir('share_quick_clip_video');
        final sourceFile = File('${videoFile.path}/clip.mp4');
        await sourceFile.writeAsString('video-bytes');
        final engine = _CompleterShareCaptureEngine(
          ShareCaptureResult.success(
            finalUrl: Uri.parse('https://www.xiaohongshu.com/explore/video-1'),
            articleTitle: 'XHS Video',
            textContent: 'Captured video body',
            pageKind: SharePageKind.video,
            siteParserTag: 'xiaohongshu',
            videoCandidates: const [
              ShareVideoCandidate(
                id: 'h264',
                url: 'https://sns-video.xhscdn.com/h264.mp4',
                source: ShareVideoSource.parser,
                isDirectDownloadable: true,
                priority: 160,
                parserTag: 'xiaohongshu',
              ),
            ],
          ),
        );
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWith((_) => db)],
        );
        addTearDown(container.dispose);
        final preparer = _FakeVideoAttachmentPreparer(sourceFile);
        final bootstrapAdapter = _FakeAppBootstrapAdapter(
          userSetting: const UserGeneralSetting(memoVisibility: 'PUBLIC'),
          requestSyncHandler: (ref, request) async {},
        );
        final service = ShareQuickClipService(
          ref: _FakeWidgetRef(container),
          bootstrapAdapter: bootstrapAdapter,
          engine: engine,
          videoAttachmentPreparer: preparer,
        );

        await service.start(
          payload: const SharePayload(
            type: SharePayloadType.text,
            text: 'https://www.xiaohongshu.com/explore/video-1',
            title: 'XHS Video',
          ),
          submission: const ShareQuickClipSubmission(
            tags: <String>[],
            textOnly: false,
            titleAndLinkOnly: false,
          ),
          locale: const Locale('en'),
        );
        engine.complete();
        await _waitFor(() async {
          final memos = await db.listMemos(limit: 10);
          if (memos.isEmpty) return false;
          return (memos.single['attachments_json'] as String).contains(
            'video/mp4',
          );
        });
        await _waitFor(() async => bootstrapAdapter.requestSyncCallCount >= 1);

        expect(preparer.callCount, 1);
        final memos = await db.listMemos(limit: 10);
        expect(memos, hasLength(1));
        expect(memos.single['content'] as String, contains('XHS Video'));
        expect(
          memos.single['attachments_json'] as String,
          contains('clip.mp4'),
        );
      },
    );

    test(
      'full Xiaohongshu video quick clip keeps memo when video append fails',
      () async {
        final testDb = await _createDatabase(
          'share_quick_clip_xhs_video_append_failure',
        );
        final db = testDb.database;
        addTearDown(() async {
          await db.close();
          await deleteTestDatabase(testDb.dbName);
        });
        final engine = _CompleterShareCaptureEngine(
          ShareCaptureResult.success(
            finalUrl: Uri.parse('https://www.xiaohongshu.com/explore/video-3'),
            articleTitle: 'XHS Video Failure',
            textContent: 'Captured video body survives',
            pageKind: SharePageKind.video,
            siteParserTag: 'xiaohongshu',
            videoCandidates: const [
              ShareVideoCandidate(
                id: 'h264',
                url: 'https://sns-video.xhscdn.com/h264.mp4',
                source: ShareVideoSource.parser,
                isDirectDownloadable: true,
                priority: 160,
                parserTag: 'xiaohongshu',
              ),
            ],
          ),
        );
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWith((_) => db)],
        );
        addTearDown(container.dispose);
        final preparer = _ThrowingVideoAttachmentPreparer();
        final bootstrapAdapter = _FakeAppBootstrapAdapter(
          userSetting: const UserGeneralSetting(memoVisibility: 'PUBLIC'),
          requestSyncHandler: (ref, request) async {},
        );
        final service = ShareQuickClipService(
          ref: _FakeWidgetRef(container),
          bootstrapAdapter: bootstrapAdapter,
          engine: engine,
          videoAttachmentPreparer: preparer,
        );

        await service.start(
          payload: const SharePayload(
            type: SharePayloadType.text,
            text: 'https://www.xiaohongshu.com/explore/video-3',
            title: 'XHS Video Failure',
          ),
          submission: const ShareQuickClipSubmission(
            tags: <String>[],
            textOnly: false,
            titleAndLinkOnly: false,
          ),
          locale: const Locale('en'),
        );
        engine.complete();
        await _waitFor(() async {
          final memos = await db.listMemos(limit: 10);
          return memos.isNotEmpty &&
              (memos.single['content'] as String).contains('XHS Video Failure');
        });
        await _waitFor(() async => bootstrapAdapter.requestSyncCallCount >= 1);

        expect(preparer.callCount, 1);
        final memos = await db.listMemos(limit: 10);
        expect(memos, hasLength(1));
        expect(
          memos.single['content'] as String,
          contains('XHS Video Failure'),
        );
        expect(memos.single['attachments_json'] as String, '[]');
      },
    );

    test(
      'text-only Xiaohongshu video quick clip skips media download',
      () async {
        final testDb = await _createDatabase(
          'share_quick_clip_text_only_video',
        );
        final db = testDb.database;
        addTearDown(() async {
          await db.close();
          await deleteTestDatabase(testDb.dbName);
        });
        final sourceDir = await support.createTempDir(
          'share_quick_clip_text_only_video',
        );
        final sourceFile = File('${sourceDir.path}/clip.mp4');
        await sourceFile.writeAsString('video-bytes');
        final engine = _CompleterShareCaptureEngine(
          ShareCaptureResult.success(
            finalUrl: Uri.parse('https://www.xiaohongshu.com/explore/video-2'),
            articleTitle: 'XHS Video',
            textContent: 'Captured video body',
            pageKind: SharePageKind.video,
            siteParserTag: 'xiaohongshu',
            videoCandidates: const [
              ShareVideoCandidate(
                id: 'h264',
                url: 'https://sns-video.xhscdn.com/h264.mp4',
                source: ShareVideoSource.parser,
                isDirectDownloadable: true,
                priority: 160,
                parserTag: 'xiaohongshu',
              ),
            ],
          ),
        );
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWith((_) => db)],
        );
        addTearDown(container.dispose);
        final preparer = _FakeVideoAttachmentPreparer(sourceFile);
        final bootstrapAdapter = _FakeAppBootstrapAdapter(
          userSetting: const UserGeneralSetting(memoVisibility: 'PUBLIC'),
          requestSyncHandler: (ref, request) async {},
        );
        final service = ShareQuickClipService(
          ref: _FakeWidgetRef(container),
          bootstrapAdapter: bootstrapAdapter,
          engine: engine,
          videoAttachmentPreparer: preparer,
        );

        await service.start(
          payload: const SharePayload(
            type: SharePayloadType.text,
            text: 'https://www.xiaohongshu.com/explore/video-2',
            title: 'XHS Video',
          ),
          submission: const ShareQuickClipSubmission(
            tags: <String>[],
            textOnly: true,
            titleAndLinkOnly: false,
          ),
          locale: const Locale('en'),
        );
        engine.complete();
        await _waitFor(() async {
          final memos = await db.listMemos(limit: 10);
          return memos.isNotEmpty &&
              (memos.single['content'] as String).contains('XHS Video');
        });
        await _waitFor(() async => bootstrapAdapter.requestSyncCallCount >= 1);

        expect(preparer.callCount, 0);
        final memos = await db.listMemos(limit: 10);
        expect(memos.single['attachments_json'] as String, '[]');
      },
    );

    test('full Xiaohongshu image quick clip appends prepared image', () async {
      final testDb = await _createDatabase('share_quick_clip_xhs_image');
      final db = testDb.database;
      addTearDown(() async {
        await db.close();
        await deleteTestDatabase(testDb.dbName);
      });
      final imageDir = await support.createTempDir('share_quick_clip_image');
      final imageFile = File('${imageDir.path}/image.png');
      await imageFile.writeAsString('image-bytes');
      final localUrl = Uri.file(imageFile.path).toString();
      const sourceUrl = 'https://sns-webpic-qc.xhscdn.com/image.png';
      final engine = _CompleterShareCaptureEngine(
        ShareCaptureResult.success(
          finalUrl: Uri.parse('https://www.xiaohongshu.com/explore/image-1'),
          articleTitle: 'XHS Image',
          contentHtml: '<p><img src="$sourceUrl"></p>',
          textContent: 'Captured image body',
          pageKind: SharePageKind.article,
          siteParserTag: 'xiaohongshu',
        ),
      );
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWith((_) => db)],
      );
      addTearDown(container.dispose);
      final bootstrapAdapter = _FakeAppBootstrapAdapter(
        userSetting: const UserGeneralSetting(memoVisibility: 'PUBLIC'),
        requestSyncHandler: (ref, request) async {},
      );
      final service = ShareQuickClipService(
        ref: _FakeWidgetRef(container),
        bootstrapAdapter: bootstrapAdapter,
        engine: engine,
        inlineImageDownloadService: _FakeInlineImageDownloadService(
          ShareInlineImageDownloadResult(
            contentHtml: '<p><img src="$localUrl"></p>',
            attachmentSeeds: [
              ShareAttachmentSeed(
                uid: 'image-1',
                filePath: imageFile.path,
                filename: 'image.png',
                mimeType: 'image/png',
                size: await imageFile.length(),
                shareInlineImage: true,
                fromThirdPartyShare: true,
                sourceUrl: sourceUrl,
              ),
            ],
          ),
        ),
      );

      await service.start(
        payload: const SharePayload(
          type: SharePayloadType.text,
          text: 'https://www.xiaohongshu.com/explore/image-1',
          title: 'XHS Image',
        ),
        submission: const ShareQuickClipSubmission(
          tags: <String>[],
          textOnly: false,
          titleAndLinkOnly: false,
        ),
        locale: const Locale('en'),
      );
      engine.complete();
      await _waitFor(() async {
        final memos = await db.listMemos(limit: 10);
        if (memos.isEmpty) return false;
        return (memos.single['attachments_json'] as String).contains(
          'image/png',
        );
      });
      await _waitFor(() async => bootstrapAdapter.requestSyncCallCount >= 1);

      final memos = await db.listMemos(limit: 10);
      expect(memos.single['content'] as String, contains('XHS Image'));
      expect(memos.single['attachments_json'] as String, contains('image.png'));
    });
  });
}

Future<_TestDatabase> _createDatabase(String prefix) async {
  final dbName = uniqueDbName(prefix);
  final db = AppDatabase(dbName: dbName);
  await db.db;
  return _TestDatabase(dbName: dbName, database: db);
}

class _TestDatabase {
  const _TestDatabase({required this.dbName, required this.database});

  final String dbName;
  final AppDatabase database;
}

class _CompleterShareCaptureEngine implements ShareCaptureEngine {
  _CompleterShareCaptureEngine(this.result);

  final ShareCaptureResult result;
  final Completer<void> _completer = Completer<void>();

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  Future<ShareCaptureResult> capture(
    ShareCaptureRequest request, {
    void Function(ShareCaptureStage stage)? onStageChanged,
  }) async {
    onStageChanged?.call(ShareCaptureStage.loadingPage);
    await _completer.future;
    onStageChanged?.call(ShareCaptureStage.buildingPreview);
    return result;
  }
}

class _FakeVideoAttachmentPreparer extends ShareVideoAttachmentPreparer {
  _FakeVideoAttachmentPreparer(this.file) : super();

  final File file;
  int callCount = 0;

  @override
  Future<SharePreparedVideoAttachment> prepare({
    required ShareCaptureResult result,
    required ShareVideoCandidate candidate,
    required AttachmentUploadSizeLimit uploadSizeLimit,
    ValueChanged<ShareVideoProbeResult>? onProbeComplete,
    ValueChanged<double>? onDownloadProgress,
    ValueChanged<double>? onCompressionProgress,
    ShareVideoCompressionConfirmation? confirmCompression,
    bool Function()? isCancelled,
  }) async {
    callCount++;
    return SharePreparedVideoAttachment(
      filePath: file.path,
      filename: 'clip.mp4',
      mimeType: 'video/mp4',
      size: await file.length(),
      wasCompressed: false,
    );
  }
}

class _ThrowingVideoAttachmentPreparer extends ShareVideoAttachmentPreparer {
  _ThrowingVideoAttachmentPreparer() : super();

  int callCount = 0;

  @override
  Future<SharePreparedVideoAttachment> prepare({
    required ShareCaptureResult result,
    required ShareVideoCandidate candidate,
    required AttachmentUploadSizeLimit uploadSizeLimit,
    ValueChanged<ShareVideoProbeResult>? onProbeComplete,
    ValueChanged<double>? onDownloadProgress,
    ValueChanged<double>? onCompressionProgress,
    ShareVideoCompressionConfirmation? confirmCompression,
    bool Function()? isCancelled,
  }) async {
    callCount++;
    throw const ShareVideoAttachmentCompressionFailed();
  }
}

class _FakeInlineImageDownloadService extends ShareInlineImageDownloadService {
  _FakeInlineImageDownloadService(this.result) : super();

  final ShareInlineImageDownloadResult result;

  @override
  Future<ShareInlineImageDownloadResult> prepare(
    ShareCaptureResult result,
  ) async {
    return this.result;
  }
}

Future<void> _waitFor(
  Future<bool> Function() predicate, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  fail('Condition was not met before timeout');
}

class _FakeAppBootstrapAdapter extends AppBootstrapAdapter {
  _FakeAppBootstrapAdapter({
    required this.userSetting,
    required this.requestSyncHandler,
  });

  final UserGeneralSetting userSetting;
  final Future<void> Function(WidgetRef ref, SyncRequest request)
  requestSyncHandler;
  int requestSyncCallCount = 0;

  @override
  UserGeneralSetting? readUserGeneralSetting(WidgetRef ref) => userSetting;

  @override
  Future<void> requestSync(WidgetRef ref, SyncRequest request) {
    requestSyncCallCount++;
    return requestSyncHandler(ref, request);
  }
}

class _FakeWidgetRef implements WidgetRef {
  const _FakeWidgetRef(this._container);

  final ProviderContainer _container;

  @override
  BuildContext get context => throw UnimplementedError();

  @override
  bool exists(ProviderBase<Object?> provider) => _container.exists(provider);

  @override
  void invalidate(ProviderOrFamily provider) => _container.invalidate(provider);

  @override
  void listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    throw UnimplementedError();
  }

  @override
  ProviderSubscription<T> listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    throw UnimplementedError();
  }

  @override
  T read<T>(ProviderListenable<T> provider) => _container.read(provider);

  @override
  T refresh<T>(Refreshable<T> provider) => _container.refresh(provider);

  @override
  T watch<T>(ProviderListenable<T> provider) => _container.read(provider);
}
