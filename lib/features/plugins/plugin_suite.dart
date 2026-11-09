import 'package:flutter/material.dart';

abstract class NexusPlugin {
  String get id;
  String get name;
  bool isEnabled;
  NexusPlugin({required this.isEnabled});

  Future<Map<String, dynamic>> interceptOutgoing(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> interceptIncoming(Map<String, dynamic> payload);
}

class ChatSchedulerPlugin extends NexusPlugin {
  ChatSchedulerPlugin({super.isEnabled = true});
  @override
  String get id => 'plugin_scheduler';
  @override
  String get name => 'Automated Chat Scheduler';

  @override
  Future<Map<String, dynamic>> interceptOutgoing(Map<String, dynamic> payload) async {
    if (payload.containsKey('scheduled_at')) {
      debugPrint('[Scheduler Plugin] Message deferred to ${payload['scheduled_at']}');
      payload['status'] = 'PENDING_SCHEDULE';
    }
    return payload;
  }

  @override
  Future<Map<String, dynamic>> interceptIncoming(Map<String, dynamic> payload) async => payload;
}

class AutoReplyPlugin extends NexusPlugin {
  final Map<RegExp, String> rules;
  AutoReplyPlugin({required this.rules, super.isEnabled = true});

  @override
  String get id => 'plugin_autoreply';
  @override
  String get name => 'Regex Auto-Reply Engine';

  @override
  Future<Map<String, dynamic>> interceptOutgoing(Map<String, dynamic> payload) async => payload;

  @override
  Future<Map<String, dynamic>> interceptIncoming(Map<String, dynamic> payload) async {
    final text = payload['content'] as String? ?? '';
    for (var entry in rules.entries) {
      if (entry.key.hasMatch(text)) {
        debugPrint('[Auto-Reply] Trigger matched! Scheduling auto-response.');
      }
    }
    return payload;
  }
}

class GhostModePlugin extends NexusPlugin {
  GhostModePlugin({super.isEnabled = true});

  @override
  String get id => 'plugin_ghost_mode';
  @override
  String get name => 'Ghost Mode (Suppress Read Receipts)';

  @override
  Future<Map<String, dynamic>> interceptOutgoing(Map<String, dynamic> payload) async {
    if (isEnabled && payload['type'] == 'READ_RECEIPT') {
      debugPrint('[Ghost Mode] Outgoing read receipt blocked locally.');
      payload['block_transmission'] = true;
    }
    return payload;
  }

  @override
  Future<Map<String, dynamic>> interceptIncoming(Map<String, dynamic> payload) async => payload;
}
