import 'package:flutter/material.dart';
import 'core/storage/local_database.dart';
import 'core/network/secure_transport.dart';
import 'features/plugins/plugin_suite.dart';
import 'features/chat/presentation/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Secure Local Database
  final database = NexusDatabase();

  // 2. Initialize Secure Transport Layer
  final transport = SecureTransportLayer(
    serverUrl: 'wss://secure.nexuschat.internal/ws',
    tokenProvider: () async => 'mock_secure_jwt_token_123',
  );

  // 3. Register Plugin Suite
  final pluginManager = [
    ChatSchedulerPlugin(),
    AutoReplyPlugin(rules: {RegExp(r'hello', caseSensitive: false): 'Hello from NexusChat Hub automated agent!'}),
    GhostModePlugin(),
  ];

  // 4. Connect Transport in background
  try {
    await transport.connect();
  } catch (e) {
    debugPrint('Initial transport connection deferred: $e');
  }

  runApp(NexusChatApp(
    database: database,
    transport: transport,
    plugins: pluginManager,
  ));
}

class NexusChatApp extends StatelessWidget {
  final NexusDatabase database;
  final SecureTransportLayer transport;
  final List<NexusPlugin> plugins;

  const NexusChatApp({
    super.key,
    required this.database,
    required this.transport,
    required this.plugins,
  });

  @override
  Widget build(BuildContext context) {
    // Mock initial messages for demo presentation
    final sampleMessages = [
      {'content': 'Welcome to NexusChat Hub Enterprise', 'isMe': false},
      {'content': 'Encrypted local storage & plugin engine active.', 'isMe': true},
    ];

    return MaterialApp(
      title: 'NexusChat Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: NexusChatScreen(
        themeConfig: NexusThemeConfig.cyberpunkDark,
        messages: sampleMessages,
        onSendMessage: (text) async {
          var payload = {'type': 'TEXT', 'content': text, 'timestamp': DateTime.now().toIso8601String()};

          // Run through plugin outgoing interception pipeline
          for (var plugin in plugins) {
            payload = await plugin.interceptOutgoing(payload);
          }

          if (payload['block_transmission'] == true) {
            debugPrint('Message transmission blocked by plugin policy.');
            return;
          }

          // Send over transport
          try {
            transport.send(payload);
          } catch (e) {
            debugPrint('Failed to send over socket: $e');
          }
        },
      ),
    );
  }
}
