import 'dart:convert';

import 'package:charset/charset.dart';
import 'package:dio/dio.dart';

import '../../data/models/rss_feed.dart';
import '../../data/models/rss_feed_preview.dart';
import '../../data/repositories/rss_repository.dart';
import 'rss_feed_discovery.dart';
import 'rss_feed_parser.dart';

enum RssFeedDiscoveryFailure { emptyInput, invalidUrl, noFeedDiscovered }

class RssFeedDiscoveryException implements Exception {
  const RssFeedDiscoveryException(this.message, {required this.failure});

  final String message;
  final RssFeedDiscoveryFailure failure;

  @override
  String toString() => message;
}

class RssCollectionRefreshSummary {
  const RssCollectionRefreshSummary({
    required this.successCount,
    required this.failureCount,
  });

  final int successCount;
  final int failureCount;
}

class RssHttpResponse {
  const RssHttpResponse({
    required this.body,
    required this.statusCode,
    this.headers = const <String, String>{},
  });

  factory RssHttpResponse.fromBytes({
    required List<int> bodyBytes,
    required int statusCode,
    Map<String, String> headers = const <String, String>{},
  }) {
    final normalizedHeaders = _normalizeHeaderMap(headers);
    return RssHttpResponse(
      body: _decodeHttpBody(bodyBytes, normalizedHeaders),
      statusCode: statusCode,
      headers: normalizedHeaders,
    );
  }

  final String body;
  final int statusCode;
  final Map<String, String> headers;

  String header(String name) => headers[name.toLowerCase()] ?? '';
}

typedef RssHttpFetcher =
    Future<RssHttpResponse> Function(Uri uri, {Map<String, String>? headers});

class RssFeedFetchService {
  RssFeedFetchService({
    required RssRepository repository,
    RssFeedParser parser = const RssFeedParser(),
    RssFeedDiscovery discovery = const RssFeedDiscovery(),
    RssHttpFetcher? fetcher,
  }) : _repository = repository,
       _parser = parser,
       _discovery = discovery,
       _fetcher = fetcher ?? _defaultFetch;

  final RssRepository _repository;
  final RssFeedParser _parser;
  final RssFeedDiscovery _discovery;
  final RssHttpFetcher _fetcher;

  Future<RssFeedPreview> previewUrl(String inputUrl) async {
    final requestUri = _normalizeInputUrl(inputUrl);
    final directResponse = await _fetcher(requestUri);
    final directPreview = _tryParsePreview(
      directResponse,
      requestedUri: requestUri,
      feedUri: requestUri,
    );
    if (directPreview != null) {
      return directPreview;
    }

    final discovered = _discovery.discoverAlternateFeeds(
      directResponse.body,
      pageUri: requestUri,
    );
    for (final feedUri in discovered) {
      final response = await _fetcher(feedUri);
      final preview = _tryParsePreview(
        response,
        requestedUri: requestUri,
        feedUri: feedUri,
      );
      if (preview != null) {
        return preview.copyWith(discoveredFromHtml: true);
      }
    }
    throw const RssFeedDiscoveryException(
      'No supported RSS or Atom feed could be discovered.',
      failure: RssFeedDiscoveryFailure.noFeedDiscovered,
    );
  }

  Future<RssFeedPreview> refreshFeed(RssFeed feed) async {
    final feedUri = _normalizeInputUrl(feed.feedUrl);
    final headers = <String, String>{
      if (feed.etag.trim().isNotEmpty) 'If-None-Match': feed.etag.trim(),
      if (feed.lastModified.trim().isNotEmpty)
        'If-Modified-Since': feed.lastModified.trim(),
    };
    try {
      final response = await _fetcher(feedUri, headers: headers);
      if (response.statusCode == 304) {
        final preview = RssFeedPreview(
          requestedUrl: feed.feedUrl,
          feedUrl: feed.feedUrl,
          siteUrl: feed.siteUrl,
          title: feed.title,
          description: feed.description,
          iconUrl: feed.iconUrl,
          articles: const <RssArticlePreview>[],
          etag: feed.etag,
          lastModified: feed.lastModified,
        );
        await _repository.recordFeedSuccess(
          preview: preview,
          fetchedAt: DateTime.now(),
        );
        return preview;
      }
      final preview = _parser
          .parse(response.body, sourceUri: feedUri)
          .copyWith(
            requestedUrl: feed.feedUrl,
            feedUrl: feed.feedUrl,
            etag: response.header('etag'),
            lastModified: response.header('last-modified'),
          );
      await _repository.upsertFeedFromPreview(preview);
      return preview;
    } catch (error) {
      await _repository.recordFeedFailure(
        feedId: feed.id,
        error: error.toString(),
      );
      rethrow;
    }
  }

  Future<RssCollectionRefreshSummary> refreshCollection(
    String collectionId,
  ) async {
    final sources = await _repository.listCollectionRssSources(collectionId);
    var success = 0;
    var failure = 0;
    for (final source in sources) {
      try {
        await refreshFeed(source.feed);
        success += 1;
      } catch (_) {
        failure += 1;
      }
    }
    return RssCollectionRefreshSummary(
      successCount: success,
      failureCount: failure,
    );
  }

  RssFeedPreview? _tryParsePreview(
    RssHttpResponse response, {
    required Uri requestedUri,
    required Uri feedUri,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return null;
    }
    try {
      return _parser
          .parse(response.body, sourceUri: feedUri)
          .copyWith(
            requestedUrl: requestedUri.toString(),
            feedUrl: feedUri.toString(),
            etag: response.header('etag'),
            lastModified: response.header('last-modified'),
          );
    } catch (_) {
      return null;
    }
  }

  Uri _normalizeInputUrl(String inputUrl) {
    final trimmed = inputUrl.trim();
    if (trimmed.isEmpty) {
      throw const RssFeedDiscoveryException(
        'Enter a feed or site URL.',
        failure: RssFeedDiscoveryFailure.emptyInput,
      );
    }
    final withScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(trimmed)
        ? trimmed
        : 'https://$trimmed';
    final parsed = Uri.tryParse(withScheme);
    if (parsed == null || parsed.host.trim().isEmpty) {
      throw RssFeedDiscoveryException(
        'Invalid URL: $inputUrl',
        failure: RssFeedDiscoveryFailure.invalidUrl,
      );
    }
    return parsed;
  }

  static Future<RssHttpResponse> _defaultFetch(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final dio = Dio(
      BaseOptions(
        followRedirects: true,
        responseType: ResponseType.bytes,
        validateStatus: (_) => true,
      ),
    );
    final response = await dio.getUri<List<int>>(
      uri,
      options: Options(headers: headers),
    );
    final normalizedHeaders = <String, String>{};
    for (final entry in response.headers.map.entries) {
      if (entry.value.isEmpty) continue;
      normalizedHeaders[entry.key.toLowerCase()] = entry.value.first;
    }
    return RssHttpResponse.fromBytes(
      bodyBytes: response.data ?? const <int>[],
      statusCode: response.statusCode ?? 0,
      headers: normalizedHeaders,
    );
  }
}

Map<String, String> _normalizeHeaderMap(Map<String, String> headers) {
  return <String, String>{
    for (final entry in headers.entries) entry.key.toLowerCase(): entry.value,
  };
}

String _decodeHttpBody(List<int> bytes, Map<String, String> headers) {
  if (bytes.isEmpty) return '';

  final bomEncoding = Charset.detect(
    bytes,
    orders: const <Encoding>[],
    utf8BOM: true,
  );
  if (bomEncoding != null) {
    return bomEncoding.decode(bytes);
  }

  final declaredName =
      _charsetFromContentType(headers['content-type'] ?? '') ??
      _charsetFromXmlDeclaration(bytes);
  final declaredEncoding = declaredName == null
      ? null
      : Charset.getByName(declaredName);
  if (declaredEncoding != null) {
    return declaredEncoding.decode(bytes);
  }

  try {
    return utf8.decode(bytes);
  } on FormatException {
    final detected = Charset.detect(bytes);
    if (detected != null) {
      return detected.decode(bytes);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }
}

String? _charsetFromContentType(String value) {
  final match = RegExp(
    r'charset\s*=\s*"?([^";\s]+)',
    caseSensitive: false,
  ).firstMatch(value);
  return match?.group(1)?.trim();
}

String? _charsetFromXmlDeclaration(List<int> bytes) {
  final prefixLength = bytes.length < 512 ? bytes.length : 512;
  final prefix = latin1.decode(bytes.take(prefixLength).toList());
  final match = RegExp(
    r'<\?xml[^>]*encoding\s*=\s*["'
    ']([^"'
    ']+)["'
    ']',
    caseSensitive: false,
  ).firstMatch(prefix);
  return match?.group(1)?.trim();
}
