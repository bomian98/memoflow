part of '../memos_api.dart';

mixin _MemosApiResources on _MemosApiBase {
  Future<AttachmentUploadSizeLimit> getAttachmentUploadSizeLimit() async {
    await _ensureServerHints();
    return switch (_serverFlavor) {
      _ServerApiFlavor.v0_21 => _getLegacyStatusUploadSizeLimit(),
      _ServerApiFlavor.v0_22 ||
      _ServerApiFlavor.v0_23 ||
      _ServerApiFlavor.v0_24 => _getWorkspaceStorageUploadSizeLimit(),
      _ServerApiFlavor.v0_25Plus ||
      _ServerApiFlavor.unknown => _getInstanceStorageUploadSizeLimit(),
    };
  }

  Future<AttachmentUploadSizeLimit> _getLegacyStatusUploadSizeLimit() async {
    try {
      final response = await _dio.get('api/v1/status');
      final body = _expectJsonMap(response.data);
      return _uploadSizeLimitFromMiBValue(
        body['maxUploadSizeMiB'] ?? body['max_upload_size_mib'],
        source: AttachmentUploadSizeLimitSource.systemStatus,
      );
    } on DioException catch (error) {
      return _unknownAttachmentUploadSizeLimit(error);
    } on FormatException {
      return const AttachmentUploadSizeLimit.unknown(
        AttachmentUploadSizeLimitUnknownReason.invalidResponse,
      );
    }
  }

  Future<AttachmentUploadSizeLimit> _getWorkspaceStorageUploadSizeLimit() {
    return _getStorageSettingUploadSizeLimit(
      path: 'api/v1/workspace/settings/STORAGE',
      source: AttachmentUploadSizeLimitSource.workspaceStorageSetting,
    );
  }

  Future<AttachmentUploadSizeLimit> _getInstanceStorageUploadSizeLimit() {
    return _getStorageSettingUploadSizeLimit(
      path: 'api/v1/instance/settings/STORAGE',
      source: AttachmentUploadSizeLimitSource.instanceStorageSetting,
    );
  }

  Future<AttachmentUploadSizeLimit> _getStorageSettingUploadSizeLimit({
    required String path,
    required AttachmentUploadSizeLimitSource source,
  }) async {
    try {
      final response = await _dio.get(path);
      final body = _expectJsonMap(response.data);
      final storageSetting = _readMap(
        body['storageSetting'] ??
            body['storage_setting'] ??
            _readMap(body['value'])?['value'],
      );
      return _uploadSizeLimitFromMiBValue(
        storageSetting?['uploadSizeLimitMb'] ??
            storageSetting?['upload_size_limit_mb'],
        source: source,
      );
    } on DioException catch (error) {
      return _unknownAttachmentUploadSizeLimit(error);
    } on FormatException {
      return const AttachmentUploadSizeLimit.unknown(
        AttachmentUploadSizeLimitUnknownReason.invalidResponse,
      );
    }
  }

  AttachmentUploadSizeLimit _uploadSizeLimitFromMiBValue(
    Object? value, {
    required AttachmentUploadSizeLimitSource source,
  }) {
    final mebibytes = _readInt(value);
    if (mebibytes <= 0) {
      return const AttachmentUploadSizeLimit.unknown(
        AttachmentUploadSizeLimitUnknownReason.nonPositiveLimit,
      );
    }
    return AttachmentUploadSizeLimit.known(
      bytes: mebibytes * 1024 * 1024,
      source: source,
    );
  }

  AttachmentUploadSizeLimit _unknownAttachmentUploadSizeLimit(
    DioException error,
  ) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return const AttachmentUploadSizeLimit.unknown(
        AttachmentUploadSizeLimitUnknownReason.permissionDenied,
      );
    }
    if (status == 404 || status == 405) {
      return const AttachmentUploadSizeLimit.unknown(
        AttachmentUploadSizeLimitUnknownReason.endpointUnavailable,
      );
    }
    return const AttachmentUploadSizeLimit.unknown(
      AttachmentUploadSizeLimitUnknownReason.requestFailed,
    );
  }

  Future<Attachment> createAttachment({
    required String attachmentId,
    required String filename,
    required String mimeType,
    required List<int> bytes,
    String? memoUid,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    await _ensureServerHints();
    if (_useLegacyMemos || _attachmentMode == _AttachmentApiMode.legacy) {
      return _createAttachmentLegacy(
        attachmentId: attachmentId,
        filename: filename,
        mimeType: mimeType,
        bytes: bytes,
        memoUid: memoUid,
        onSendProgress: onSendProgress,
      );
    }
    if (_attachmentMode == _AttachmentApiMode.resources) {
      return _createAttachmentCompat(
        attachmentId: attachmentId,
        filename: filename,
        mimeType: mimeType,
        bytes: bytes,
        memoUid: memoUid,
        onSendProgress: onSendProgress,
      );
    }
    return _createAttachmentModern(
      attachmentId: attachmentId,
      filename: filename,
      mimeType: mimeType,
      bytes: bytes,
      memoUid: memoUid,
      onSendProgress: onSendProgress,
    );
  }

  Future<Attachment> _createAttachmentModern({
    required String attachmentId,
    required String filename,
    required String mimeType,
    required List<int> bytes,
    String? memoUid,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    final data = <String, Object?>{
      'filename': filename,
      'type': mimeType,
      'content': base64Encode(bytes),
      if (memoUid != null) 'memo': 'memos/$memoUid',
    };
    final response = await _dio.post(
      'api/v1/attachments',
      queryParameters: <String, Object?>{'attachmentId': attachmentId},
      data: data,
      options: _attachmentOptions(),
      onSendProgress: onSendProgress,
    );
    _attachmentMode = _AttachmentApiMode.attachments;
    final attachment = Attachment.fromJson(_expectJsonMap(response.data));
    return _normalizeAttachmentForServer(attachment);
  }

  Future<Attachment> _createAttachmentCompat({
    required String attachmentId,
    required String filename,
    required String mimeType,
    required List<int> bytes,
    String? memoUid,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    final data = <String, Object?>{
      'filename': filename,
      'type': mimeType,
      'content': base64Encode(bytes),
      if (memoUid != null) 'memo': 'memos/$memoUid',
    };
    final response = await _dio.post(
      'api/v1/resources',
      queryParameters: <String, Object?>{'resourceId': attachmentId},
      data: data,
      options: _attachmentOptions(),
      onSendProgress: onSendProgress,
    );
    _attachmentMode = _AttachmentApiMode.resources;
    final attachment = Attachment.fromJson(_expectJsonMap(response.data));
    return _normalizeAttachmentForServer(attachment);
  }

  Future<Attachment> getAttachment({required String attachmentUid}) async {
    await _ensureServerHints();
    if (_useLegacyMemos || _attachmentMode == _AttachmentApiMode.legacy) {
      return _getAttachmentLegacy(attachmentUid);
    }
    if (_attachmentMode == _AttachmentApiMode.resources) {
      return _getAttachmentCompat(attachmentUid);
    }
    return _getAttachmentModern(attachmentUid);
  }

  Future<Attachment> _getAttachmentModern(String attachmentUid) async {
    final response = await _dio.get('api/v1/attachments/$attachmentUid');
    _attachmentMode = _AttachmentApiMode.attachments;
    final attachment = Attachment.fromJson(_expectJsonMap(response.data));
    return _normalizeAttachmentForServer(attachment);
  }

  Future<Attachment> _getAttachmentCompat(String attachmentUid) async {
    final response = await _dio.get('api/v1/resources/$attachmentUid');
    _attachmentMode = _AttachmentApiMode.resources;
    final attachment = Attachment.fromJson(_expectJsonMap(response.data));
    return _normalizeAttachmentForServer(attachment);
  }

  Future<void> deleteAttachment({required String attachmentName}) async {
    await _ensureServerHints();
    final attachmentUid = _normalizeAttachmentUid(attachmentName);
    if (_useLegacyMemos || _attachmentMode == _AttachmentApiMode.legacy) {
      await _deleteAttachmentLegacy(attachmentUid);
      return;
    }
    if (_attachmentMode == _AttachmentApiMode.resources) {
      await _deleteAttachmentCompat(attachmentUid);
      return;
    }
    await _deleteAttachmentModern(attachmentUid);
  }

  Future<void> _deleteAttachmentModern(String attachmentUid) async {
    await _dio.delete('api/v1/attachments/$attachmentUid');
    _attachmentMode = _AttachmentApiMode.attachments;
  }

  Future<void> _deleteAttachmentCompat(String attachmentUid) async {
    await _dio.delete('api/v1/resources/$attachmentUid');
    _attachmentMode = _AttachmentApiMode.resources;
  }

  Future<void> _deleteAttachmentLegacy(String attachmentUid) async {
    final targetId = _tryParseLegacyResourceId(attachmentUid);
    if (targetId == null) {
      throw FormatException('Invalid legacy attachment id: $attachmentUid');
    }
    await _dio.delete('api/v1/resource/$targetId');
    _attachmentMode = _AttachmentApiMode.legacy;
  }

  Future<List<Attachment>> listMemoAttachments({
    required String memoUid,
  }) async {
    await _ensureServerHints();
    if (_attachmentMode == _AttachmentApiMode.legacy) {
      return const <Attachment>[];
    }
    if (_attachmentMode == _AttachmentApiMode.resources) {
      return _listMemoResources(memoUid);
    }
    if (_attachmentMode == _AttachmentApiMode.attachments) {
      return _listMemoAttachmentsModern(memoUid);
    }
    return _listMemoAttachmentsModern(memoUid);
  }

  Future<List<Attachment>> _listMemoAttachmentsModern(String memoUid) async {
    final response = await _dio.get(
      'api/v1/memos/$memoUid/attachments',
      queryParameters: const <String, Object?>{'pageSize': 1000},
    );
    _attachmentMode = _AttachmentApiMode.attachments;
    final body = _expectJsonMap(response.data);
    final list = body['attachments'];
    final attachments = <Attachment>[];
    if (list is List) {
      for (final item in list) {
        if (item is Map) {
          attachments.add(Attachment.fromJson(item.cast<String, dynamic>()));
        }
      }
    }
    return _normalizeAttachmentsForServer(attachments);
  }

  Future<List<Attachment>> _listMemoResources(String memoUid) async {
    final response = await _dio.get(
      'api/v1/memos/$memoUid/resources',
      queryParameters: const <String, Object?>{'pageSize': 1000},
    );
    _attachmentMode = _AttachmentApiMode.resources;
    final body = _expectJsonMap(response.data);
    final list = body['resources'];
    final attachments = <Attachment>[];
    if (list is List) {
      for (final item in list) {
        if (item is Map) {
          attachments.add(Attachment.fromJson(item.cast<String, dynamic>()));
        }
      }
    }
    return _normalizeAttachmentsForServer(attachments);
  }

  Future<void> setMemoAttachments({
    required String memoUid,
    required List<String> attachmentNames,
  }) async {
    await _ensureServerHints();
    if (_attachmentMode == _AttachmentApiMode.legacy) {
      await _setMemoAttachmentsLegacy(memoUid, attachmentNames);
      return;
    }
    if (_attachmentMode == _AttachmentApiMode.resources) {
      await _setMemoResources(memoUid, attachmentNames);
      return;
    }
    if (_attachmentMode == _AttachmentApiMode.attachments) {
      await _setMemoAttachmentsModern(memoUid, attachmentNames);
      return;
    }
    await _setMemoAttachmentsModern(memoUid, attachmentNames);
  }

  Future<void> _setMemoAttachmentsModern(
    String memoUid,
    List<String> attachmentNames,
  ) async {
    await _dio.patch(
      'api/v1/memos/$memoUid/attachments',
      data: <String, Object?>{
        'name': 'memos/$memoUid',
        'attachments': attachmentNames
            .map((n) => <String, Object?>{'name': n})
            .toList(growable: false),
      },
      options: _attachmentOptions(),
    );
    _attachmentMode = _AttachmentApiMode.attachments;
  }

  Future<void> _setMemoResources(
    String memoUid,
    List<String> attachmentNames,
  ) async {
    await _dio.patch(
      'api/v1/memos/$memoUid/resources',
      data: <String, Object?>{
        'name': 'memos/$memoUid',
        'resources': attachmentNames
            .map((n) => <String, Object?>{'name': n})
            .toList(growable: false),
      },
      options: _attachmentOptions(),
    );
    _attachmentMode = _AttachmentApiMode.resources;
  }

  Future<Attachment> _createAttachmentLegacy({
    required String attachmentId,
    required String filename,
    required String mimeType,
    required List<int> bytes,
    String? memoUid,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    final _ = [attachmentId, mimeType, memoUid];
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _dio.post(
      'api/v1/resource/blob',
      data: formData,
      options: _attachmentOptions(),
      onSendProgress: onSendProgress,
    );
    _attachmentMode = _AttachmentApiMode.legacy;
    return _attachmentFromLegacy(_expectJsonMap(response.data));
  }

  Future<Attachment> _getAttachmentLegacy(String attachmentUid) async {
    final targetId = _tryParseLegacyResourceId(attachmentUid);
    if (targetId == null) {
      throw FormatException('Invalid legacy attachment id: $attachmentUid');
    }
    final response = await _dio.get('api/v1/resource');
    final list = _readListPayload(response.data);
    for (final item in list) {
      if (item is Map) {
        final map = item.cast<String, dynamic>();
        if (_readInt(map['id']) == targetId) {
          return _attachmentFromLegacy(map);
        }
      }
    }
    throw StateError('Legacy attachment not found: $attachmentUid');
  }

  Future<void> _setMemoAttachmentsLegacy(
    String memoUid,
    List<String> attachmentNames,
  ) async {
    if (!_ensureLegacyMemoEndpointAllowed(
      'api/v1/memo',
      operation: 'set_memo_attachments_legacy',
    )) {
      throw StateError(
        'Legacy memo attachment endpoint is blocked for server flavor ${_serverFlavor.name}',
      );
    }
    final resourceIds = attachmentNames
        .map(_tryParseLegacyResourceId)
        .whereType<int>()
        .toSet()
        .toList(growable: false);

    await _dio.patch(
      'api/v1/memo/$memoUid',
      data: <String, Object?>{
        'id': _legacyMemoIdValue(memoUid),
        'resourceIdList': resourceIds,
      },
      options: _attachmentOptions(),
    );
    _attachmentMode = _AttachmentApiMode.legacy;
  }
}
