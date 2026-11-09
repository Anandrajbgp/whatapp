import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SecureTransportLayer {
  final String serverUrl;
  final Future<String?> Function() tokenProvider;
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  bool _isConnected = false;

  final StreamController<Map<String, dynamic>> _incomingController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get incomingStream => _incomingController.stream;

  SecureTransportLayer({required this.serverUrl, required this.tokenProvider});

  Future<void> connect() async {
    final token = await tokenProvider();
    if (token == null) throw Exception('Authentication token missing for transport layer');

    final uri = Uri.parse('$serverUrl?token=$token');
    _channel = WebSocketChannel.connect(uri);
    _isConnected = true;

    _channel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data);
        _incomingController.add(decoded);
      },
      onError: (error) {
        debugPrint('Transport Error: $error');
        _handleDisconnect();
      },
      onDone: () {
        debugPrint('Transport Connection Closed.');
        _handleDisconnect();
      },
    );

    _startHeartbeat();
  }

  void send(Map<String, dynamic> payload) {
    if (!_isConnected || _channel == null) {
      throw Exception('Socket is not connected. Message queued.');
    }
    _channel!.sink.add(jsonEncode(payload));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        send({'type': 'PING', 'timestamp': DateTime.now().toIso8601String()});
      }
    });
  }

  void _handleDisconnect() {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    Future.delayed(const Duration(seconds: 5), () => connect());
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _incomingController.close();
  }
}
