import 'package:flutter/foundation.dart';
import 'plugin_suite.dart';

class AntiRevokePlugin extends NexusPlugin {
  final Map<String, String> _messageCache = {};

  AntiRevokePlugin({super.isEnabled = true});

  @override
  String get id => 'plugin_anti_revoke';
  @override
  String get name => 'Anti-Revoke (Prevent Deleted Messages)';

  @override
  Future<Map<String, dynamic>> interceptOutgoing(Map<String, dynamic> payload) async => payload;

  @override
  Future<Map<String, dynamic>> interceptIncoming(Map<String, dynamic> payload) async {
    final type = payload['type'];
    final messageId = payload['message_id'] as String?;
    final content = payload['content'] as String?;

    if (type == 'TEXT' && messageId != null && content != null) {
      // Cache incoming messages
      _messageCache[messageId] = content;
    } else if (type == 'DELETE_MESSAGE' && messageId != null) {
      if (isEnabled) {
        final originalContent = _messageCache[messageId];
        if (originalContent != null) {
          debugPrint('[Anti-Revoke] Intercepted deletion for message $messageId. Preserving content: "$originalContent"');
          // Convert delete command into a normal retained message with a [Deleted by sender] tag
          payload['type'] = 'TEXT';
          payload['content'] = '[Anti-Revoke] $originalContent';
        }
      }
    }
    return payload;
  }
}
