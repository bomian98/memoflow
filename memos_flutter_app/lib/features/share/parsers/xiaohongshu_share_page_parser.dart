import '../share_clip_models.dart';
import 'share_page_parser.dart';

class XiaohongshuSharePageParser implements SharePageParser {
  @override
  bool canParse(SharePageSnapshot snapshot) {
    final host = snapshot.host.toLowerCase();
    return host == 'xhslink.com' ||
        host.endsWith('.xiaohongshu.com') ||
        host == 'xiaohongshu.com';
  }

  @override
  SharePageParserResult parse(SharePageSnapshot snapshot) {
    final bridge = snapshot.bridgeData;
    final windowStates =
        tryDecodeJsonMap(bridge['windowStates']) ?? const <String, dynamic>{};
    final roots = <Object?>[
      windowStates['__INITIAL_STATE__'],
      windowStates['__INITIAL_SSR_STATE__'],
      ...asDynamicList(bridge['bootstrapStates']),
    ];
    for (final record in snapshot.networkRecords) {
      final lowerUrl = record.url.toLowerCase();
      if (lowerUrl.contains('note') ||
          lowerUrl.contains('feed') ||
          lowerUrl.contains('detail')) {
        roots.add(tryDecodeJsonMap(record.responseBody) ?? record.responseBody);
      }
    }

    final directCandidates = <ShareVideoCandidate>[];
    final unsupportedCandidates = <ShareVideoCandidate>[];
    var identifiedAsVideo = false;

    for (final root in roots) {
      if (root == null) continue;
      final typeValues = deepValuesForKey(root, const {
        'noteType',
        'type',
        'modelType',
      });
      for (final value in typeValues) {
        final normalized = (value?.toString() ?? '').toLowerCase();
        if (normalized.contains('video')) {
          identifiedAsVideo = true;
        }
      }

      for (final value in deepValuesForKey(root, const {'masterUrl', 'url'})) {
        final url = normalizeShareText(value?.toString());
        final candidate = _candidateFromUrl(url, snapshot);
        if (candidate == null) continue;
        identifiedAsVideo = true;
        if (candidate.isDirectDownloadable) {
          directCandidates.add(candidate);
        } else {
          unsupportedCandidates.add(candidate);
        }
      }

      for (final value in deepValuesForKey(root, const {'backupUrls'})) {
        for (final backup in asDynamicList(value)) {
          final candidate = _candidateFromUrl(backup?.toString(), snapshot);
          if (candidate == null) continue;
          identifiedAsVideo = true;
          if (candidate.isDirectDownloadable) {
            directCandidates.add(candidate);
          } else {
            unsupportedCandidates.add(candidate);
          }
        }
      }

      for (final value in deepValuesForKey(root, const {'stream'})) {
        for (final map in deepMaps(value)) {
          final url = normalizeShareText(
            map['masterUrl']?.toString() ?? map['url']?.toString(),
          );
          final candidate = _candidateFromUrl(url, snapshot);
          if (candidate == null) continue;
          identifiedAsVideo = true;
          if (candidate.isDirectDownloadable) {
            directCandidates.add(candidate);
          } else {
            unsupportedCandidates.add(candidate);
          }
        }
      }
    }

    final mergedDirect = mergeShareVideoCandidates(directCandidates);
    final mergedUnsupported = mergeShareVideoCandidates(unsupportedCandidates);
    final imageAttachmentUrls = _collectImageAttachmentUrls(roots);
    final pageKind =
        identifiedAsVideo ||
            mergedDirect.isNotEmpty ||
            mergedUnsupported.isNotEmpty
        ? SharePageKind.video
        : imageAttachmentUrls.isNotEmpty
        ? SharePageKind.article
        : SharePageKind.unknown;

    return SharePageParserResult(
      pageKind: pageKind,
      videoCandidates: mergedDirect,
      unsupportedVideoCandidates: mergedUnsupported,
      imageAttachmentUrls: pageKind == SharePageKind.video
          ? const <String>[]
          : imageAttachmentUrls,
      title: _resolveTitle(roots, bridge),
      excerpt: _resolveExcerpt(roots, bridge),
      parserTag: 'xiaohongshu',
    );
  }

  ShareVideoCandidate? _candidateFromUrl(
    String? url,
    SharePageSnapshot snapshot,
  ) {
    final normalizedUrl = normalizeShareText(url);
    if (normalizedUrl == null) return null;
    final isDirect = isDirectVideoUrl(normalizedUrl);
    final isUnsupported = isUnsupportedStreamUrl(normalizedUrl);
    if (!isDirect && !isUnsupported) return null;
    return ShareVideoCandidate(
      id: 'xiaohongshu_${normalizeShareVideoUrl(normalizedUrl).hashCode.abs()}',
      url: normalizeShareVideoUrl(normalizedUrl),
      title: fileNameFromUrl(normalizedUrl),
      source: ShareVideoSource.parser,
      referer: snapshot.finalUrl.toString(),
      cookieUrl: snapshot.finalUrl.toString(),
      isDirectDownloadable: isDirect,
      priority: isDirect ? 120 : 20,
      parserTag: 'xiaohongshu',
      reason: isUnsupported ? 'stream_only_not_supported' : null,
    );
  }

  String? _resolveTitle(List<Object?> roots, Map<String, dynamic> bridge) {
    for (final root in roots) {
      final title = firstStringAtPaths(root, const [
        ['note', 'title'],
        ['noteInfo', 'note', 'title'],
        ['title'],
      ]);
      if (title != null) return title;
    }
    return normalizeShareText(bridge['articleTitle']?.toString()) ??
        normalizeShareText(bridge['pageTitle']?.toString());
  }

  String? _resolveExcerpt(List<Object?> roots, Map<String, dynamic> bridge) {
    for (final root in roots) {
      final excerpt = firstStringAtPaths(root, const [
        ['note', 'desc'],
        ['noteInfo', 'note', 'desc'],
        ['desc'],
      ]);
      if (excerpt != null) return excerpt;
    }
    return normalizeShareText(bridge['excerpt']?.toString());
  }

  List<String> _collectImageAttachmentUrls(List<Object?> roots) {
    final urls = <String>{};
    for (final root in roots) {
      for (final value in deepValuesForKey(root, const {
        'imageList',
        'image_list',
        'images',
        'image',
        'cover',
        'coverUrl',
        'urlDefault',
        'urlPre',
        'urlSizeLarge',
        'traceId',
      })) {
        _collectImageUrlStrings(value, urls);
      }
    }
    return urls.toList(growable: false);
  }

  void _collectImageUrlStrings(Object? value, Set<String> output) {
    if (value == null) return;
    if (value is String) {
      final normalized = normalizeShareText(value);
      if (normalized != null && _looksLikeImageUrl(normalized)) {
        output.add(normalized);
      }
      return;
    }
    if (value is List) {
      for (final item in value) {
        _collectImageUrlStrings(item, output);
      }
      return;
    }
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString().toLowerCase();
        if (_isImageUrlField(key) || _isImageContainerField(key)) {
          _collectImageUrlStrings(entry.value, output);
        }
      }
    }
  }

  bool _isImageContainerField(String key) {
    return key.contains('image') ||
        key.contains('cover') ||
        key.contains('pic') ||
        key == 'note_card';
  }

  bool _isImageUrlField(String key) {
    return key == 'url' ||
        key == 'src' ||
        key == 'url_default' ||
        key == 'urldefault' ||
        key == 'url_pre' ||
        key == 'urlpre' ||
        key == 'url_size_large' ||
        key == 'urlsizelarge' ||
        key == 'imageurl' ||
        key == 'image_url';
  }

  bool _looksLikeImageUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'http' && scheme != 'https') return false;
    final lower = value.toLowerCase();
    if (lower.contains('.mp4') || lower.contains('.m3u8')) return false;
    if (RegExp(r'\.(jpe?g|png|webp|gif|avif|heic)(?:[?#]|$)').hasMatch(lower)) {
      return true;
    }
    final host = uri.host.toLowerCase();
    return host.contains('xhscdn') ||
        host.contains('sns-webpic') ||
        lower.contains('imageview') ||
        lower.contains('/spectrum/');
  }
}
