import 'dart:convert';

import 'package:dio/dio.dart';

import 'update_config.dart';

const Duration kUpdateConfigTimeout = Duration(seconds: 3);
const List<String> kUpdateConfigUrls = [
  'https://juanzeng.hzc073.com/memoflow/update/latest.json',
  'https://hzc073.github.io/memoflow_config/update/latest.json',
  'https://raw.githubusercontent.com/hzc073/memoflow_config/gh-pages/update/latest.json',
  'https://raw.githubusercontent.com/hzc073/memoflow_config/main/memoflow_update.json',
];

const List<String> kPreviewUpdateConfigUrls = [
  'https://hzc073.github.io/memoflow_config/update/latest.preview.json',
  'https://raw.githubusercontent.com/hzc073/memoflow_config/gh-pages/update/latest.preview.json',
  'https://raw.githubusercontent.com/hzc073/memoflow_config/main/memoflow_update.preview.json',
];

enum UpdateConfigSourceType { production, preview, customUrl, localJson }

class UpdateConfigSource {
  const UpdateConfigSource._({required this.type, this.url, this.jsonText});

  const UpdateConfigSource.production()
    : this._(type: UpdateConfigSourceType.production);

  const UpdateConfigSource.preview()
    : this._(type: UpdateConfigSourceType.preview);

  const UpdateConfigSource.customUrl(String url)
    : this._(type: UpdateConfigSourceType.customUrl, url: url);

  const UpdateConfigSource.localJson(String jsonText)
    : this._(type: UpdateConfigSourceType.localJson, jsonText: jsonText);

  final UpdateConfigSourceType type;
  final String? url;
  final String? jsonText;
}

class UpdateConfigService {
  UpdateConfigService({
    Dio? dio,
    List<String>? configUrls,
    List<String>? previewConfigUrls,
  }) : _dio = dio ?? Dio(),
       _configUrls = configUrls ?? kUpdateConfigUrls,
       _previewConfigUrls = previewConfigUrls ?? kPreviewUpdateConfigUrls;

  final Dio _dio;
  final List<String> _configUrls;
  final List<String> _previewConfigUrls;

  Future<UpdateAnnouncementConfig?> fetchLatest({
    Duration timeout = kUpdateConfigTimeout,
    UpdateConfigSource source = const UpdateConfigSource.production(),
  }) async {
    if (source.type == UpdateConfigSourceType.localJson) {
      return _parseConfig(source.jsonText ?? '');
    }

    final urls = switch (source.type) {
      UpdateConfigSourceType.production => _configUrls,
      UpdateConfigSourceType.preview => _previewConfigUrls,
      UpdateConfigSourceType.customUrl => [source.url ?? ''],
      UpdateConfigSourceType.localJson => const <String>[],
    };

    for (final url in urls) {
      final trimmed = url.trim();
      if (trimmed.isEmpty) continue;
      final config = await _fetchFromUrl(trimmed, timeout: timeout);
      if (config != null) return config;
    }
    return null;
  }

  Future<UpdateAnnouncementConfig?> _fetchFromUrl(
    String url, {
    required Duration timeout,
  }) async {
    try {
      _dio.options
        ..connectTimeout = timeout
        ..sendTimeout = timeout
        ..receiveTimeout = timeout;
      final response = await _dio.get<dynamic>(
        url,
        options: Options(
          responseType: ResponseType.json,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );
      final data = response.data;
      return _parseDecodedConfig(data);
    } on DioException {
      return null;
    } on FormatException {
      return null;
    }
  }

  UpdateAnnouncementConfig? _parseConfig(String raw) {
    try {
      return _parseDecodedConfig(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  UpdateAnnouncementConfig? _parseDecodedConfig(dynamic data) {
    final decoded = data is String ? jsonDecode(data) : data;
    if (decoded is Map) {
      return UpdateAnnouncementConfig.fromJson(decoded.cast<String, dynamic>());
    }
    return null;
  }
}
