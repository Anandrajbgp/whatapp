import 'package:flutter/material.dart';
import '../plugin_suite.dart';

class ModSettingsScreen extends StatefulWidget {
  final List<NexusPlugin> plugins;

  const ModSettingsScreen({super.key, required this.plugins});

  @override
  State<ModSettingsScreen> createState() => _ModSettingsScreenState();
}

class _ModSettingsScreenState extends State<ModSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NexusMod Control Center'),
        backgroundColor: const Color(0xFF6200EE),
      ),
      body: ListView.builder(
        itemCount: widget.plugins.length,
        itemBuilder: (context, index) {
          final plugin = widget.plugins[index];
          return SwitchListTile(
            title: Text(plugin.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text('ID: ${plugin.id}', style: const TextStyle(color: Colors.grey)),
            value: plugin.isEnabled,
            activeColor: Colors.purpleAccent,
            onChanged: (bool value) {
              setState(() {
                plugin.isEnabled = value;
              });
            },
          );
        },
      ),
    );
  }
}
