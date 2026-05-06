import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memos_flutter_app/data/api/memo_api_facade.dart';
import 'package:memos_flutter_app/data/api/memo_api_version.dart';
import 'package:memos_flutter_app/data/api/memos_api.dart';

void main() {
  group('attachment upload size limit route compatibility', () {
    test('reads 0.21 maxUploadSizeMiB from system status', () async {
      final server = await _FakeLimitServer.start(
        version: MemoApiVersion.v021,
        statusPayload: const <String, Object?>{'maxUploadSizeMiB': 64},
      );
      addTearDown(server.close);

      final api = _authenticatedApi(server);
      final limit = await api.getAttachmentUploadSizeLimit();

      expect(limit.bytes, 64 * 1024 * 1024);
      expect(limit.source, AttachmentUploadSizeLimitSource.systemStatus);
      expect(server.singleRequest.path, '/api/v1/status');
    });

    test(
      'reads 0.24 uploadSizeLimitMb from workspace storage setting',
      () async {
        final server = await _FakeLimitServer.start(
          version: MemoApiVersion.v024,
          storageStatusCode: HttpStatus.ok,
          storagePayload: const <String, Object?>{
            'storageSetting': <String, Object?>{'uploadSizeLimitMb': '96'},
          },
        );
        addTearDown(server.close);

        final api = _authenticatedApi(server);
        final limit = await api.getAttachmentUploadSizeLimit();

        expect(limit.bytes, 96 * 1024 * 1024);
        expect(
          limit.source,
          AttachmentUploadSizeLimitSource.workspaceStorageSetting,
        );
        expect(server.singleRequest.path, '/api/v1/workspace/settings/STORAGE');
      },
    );

    test(
      'reads 0.27 uploadSizeLimitMb from instance storage setting',
      () async {
        final server = await _FakeLimitServer.start(
          version: MemoApiVersion.v027,
          storageStatusCode: HttpStatus.ok,
          storagePayload: const <String, Object?>{
            'storageSetting': <String, Object?>{'uploadSizeLimitMb': '128'},
          },
        );
        addTearDown(server.close);

        final api = _authenticatedApi(server);
        final limit = await api.getAttachmentUploadSizeLimit();

        expect(limit.bytes, 128 * 1024 * 1024);
        expect(
          limit.source,
          AttachmentUploadSizeLimitSource.instanceStorageSetting,
        );
        expect(server.singleRequest.path, '/api/v1/instance/settings/STORAGE');
      },
    );

    test('permission denied storage setting becomes unknown', () async {
      final server = await _FakeLimitServer.start(
        version: MemoApiVersion.v027,
        storageStatusCode: HttpStatus.forbidden,
      );
      addTearDown(server.close);

      final api = _authenticatedApi(server);
      final limit = await api.getAttachmentUploadSizeLimit();

      expect(limit.isUnknown, isTrue);
      expect(
        limit.unknownReason,
        AttachmentUploadSizeLimitUnknownReason.permissionDenied,
      );
    });

    test('missing storage setting endpoint becomes unknown', () async {
      final server = await _FakeLimitServer.start(
        version: MemoApiVersion.v024,
        storageStatusCode: HttpStatus.notFound,
      );
      addTearDown(server.close);

      final api = _authenticatedApi(server);
      final limit = await api.getAttachmentUploadSizeLimit();

      expect(limit.isUnknown, isTrue);
      expect(
        limit.unknownReason,
        AttachmentUploadSizeLimitUnknownReason.endpointUnavailable,
      );
    });

    test('malformed storage setting response becomes unknown', () async {
      final server = await _FakeLimitServer.start(
        version: MemoApiVersion.v027,
        rawBody: '<html>not json</html>',
      );
      addTearDown(server.close);

      final api = _authenticatedApi(server);
      final limit = await api.getAttachmentUploadSizeLimit();

      expect(limit.isUnknown, isTrue);
      expect(
        limit.unknownReason,
        AttachmentUploadSizeLimitUnknownReason.invalidResponse,
      );
    });
  });
}

MemosApi _authenticatedApi(_FakeLimitServer server) {
  return MemoApiFacade.authenticated(
    baseUrl: server.baseUrl,
    personalAccessToken: 'test-pat',
    version: server.version,
  );
}

class _CapturedRequest {
  const _CapturedRequest({required this.method, required this.path});

  final String method;
  final String path;
}

class _FakeLimitServer {
  _FakeLimitServer._({
    required this.version,
    required HttpServer server,
    required this.statusPayload,
    required this.storagePayload,
    required this.storageStatusCode,
    required this.rawBody,
  }) : _server = server;

  final MemoApiVersion version;
  final HttpServer _server;
  final Object? statusPayload;
  final Object? storagePayload;
  final int storageStatusCode;
  final String? rawBody;
  final requests = <_CapturedRequest>[];

  Uri get baseUrl => Uri.parse('http://127.0.0.1:${_server.port}');

  _CapturedRequest get singleRequest {
    expect(requests, hasLength(1));
    return requests.single;
  }

  static Future<_FakeLimitServer> start({
    required MemoApiVersion version,
    Object? statusPayload,
    Object? storagePayload,
    int storageStatusCode = HttpStatus.ok,
    String? rawBody,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final harness = _FakeLimitServer._(
      version: version,
      server: server,
      statusPayload: statusPayload,
      storagePayload: storagePayload,
      storageStatusCode: storageStatusCode,
      rawBody: rawBody,
    );
    server.listen(harness._handleRequest);
    return harness;
  }

  Future<void> close() => _server.close(force: true);

  Future<void> _handleRequest(HttpRequest request) async {
    await utf8.decoder.bind(request).join();
    requests.add(
      _CapturedRequest(method: request.method, path: request.uri.path),
    );

    if (rawBody != null) {
      request.response.statusCode = HttpStatus.ok;
      request.response.write(rawBody);
      await request.response.close();
      return;
    }

    if (version == MemoApiVersion.v021 &&
        request.method == 'GET' &&
        request.uri.path == '/api/v1/status') {
      await _writeJson(
        request.response,
        statusPayload ?? const <String, Object?>{'maxUploadSizeMiB': 32},
      );
      return;
    }

    final expectedStoragePath = switch (version) {
      MemoApiVersion.v022 ||
      MemoApiVersion.v023 ||
      MemoApiVersion.v024 => '/api/v1/workspace/settings/STORAGE',
      MemoApiVersion.v025 ||
      MemoApiVersion.v026 ||
      MemoApiVersion.v027 => '/api/v1/instance/settings/STORAGE',
      MemoApiVersion.v021 => '',
    };
    if (request.method == 'GET' && request.uri.path == expectedStoragePath) {
      await _writeJson(
        request.response,
        storagePayload ??
            const <String, Object?>{
              'storageSetting': <String, Object?>{'uploadSizeLimitMb': '32'},
            },
        statusCode: storageStatusCode,
      );
      return;
    }

    await _writeJson(request.response, <String, Object?>{
      'error': 'Unhandled route',
    }, statusCode: HttpStatus.notFound);
  }
}

Future<void> _writeJson(
  HttpResponse response,
  Object payload, {
  int statusCode = HttpStatus.ok,
}) async {
  response.statusCode = statusCode;
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(payload));
  await response.close();
}
