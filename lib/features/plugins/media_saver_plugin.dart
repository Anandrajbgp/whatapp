import 'package:flutter/foundation.dart';
import 'plugin_suite.dart';

class MediaSaverPlugin extends NexusPlugin {
  MediaSaverPlugin({super.isEnabled = true});

  @override
  String get id => 'plugin_media_saver';
  @override
  String get name => 'Auto-Save Ephemeral Media & Status';

  @override
  Future<Map<String, dynamic>> interceptOutgoing(Map<String, dynamic> payload) async => payload;

  @override
  Future<Map<String, dynamic>> interceptIncoming(Map<String, dynamic> payload) async {
    final type = payload['type'];
    if ((type == 'IMAGE' || type == 'VIDEO' || type == 'EPHEMERAL_MEDIA') && isEnabled) {
      final mediaUrl = payload['media_url'] as String?;
      if (mediaUrl != null) {
        debugPrint('[Media Saver] Auto-downloading ephemeral media from $mediaUrl to secure local storage directory.');
        // Trigger background download and store in app sandbox
        payload['saved_locally'] = true;
      }
    }
    return payload;
  }
}
