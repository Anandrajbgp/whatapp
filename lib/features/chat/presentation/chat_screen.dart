import 'package:flutter/material.dart';

class NexusThemeConfig {
  final Color primaryBubbleColor;
  final Color secondaryBubbleColor;
  final Color backgroundColor;
  final String fontFamily;
  final double borderRadius;

  const NexusThemeConfig({
    required this.primaryBubbleColor,
    required this.secondaryBubbleColor,
    required this.backgroundColor,
    required this.fontFamily,
    required this.borderRadius,
  });

  static const cyberpunkDark = NexusThemeConfig(
    primaryBubbleColor: Color(0xFF6200EE),
    secondaryBubbleColor: Color(0xFF2D2D2D),
    backgroundColor: Color(0xFF121212),
    fontFamily: 'Roboto',
    borderRadius: 16.0,
  );
}

class NexusChatScreen extends StatelessWidget {
  final NexusThemeConfig themeConfig;
  final List<Map<String, dynamic>> messages;
  final Function(String) onSendMessage;

  const NexusChatScreen({
    super.key,
    required this.themeConfig,
    required this.messages,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: themeConfig.backgroundColor,
        fontFamily: themeConfig.fontFamily,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NexusChat Hub'),
          backgroundColor: themeConfig.primaryBubbleColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['isMe'] as bool;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? themeConfig.primaryBubbleColor : themeConfig.secondaryBubbleColor,
                        borderRadius: BorderRadius.circular(themeConfig.borderRadius),
                      ),
                      child: Text(
                        msg['content'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Type secure message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: themeConfig.primaryBubbleColor),
                    onPressed: () {
                      if (textController.text.isNotEmpty) {
                        onSendMessage(textController.text);
                        textController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
