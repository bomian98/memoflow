import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/attachments/attachment_preprocessor.dart';
import '../settings/image_compression_settings_provider.dart';

final attachmentPreprocessorProvider = Provider<AttachmentPreprocessor>((ref) {
  // Use the StateNotifier so UI and preprocessor share the same settings source,
  // avoiding a race where the picker reads defaults (enabled=true) while the
  // preprocessor still reads stale storage (enabled=false).
  final settingsProvider = ref.watch(imageCompressionSettingsProvider);
  return DefaultAttachmentPreprocessor(
    loadSettings: () async => settingsProvider,
  );
});
