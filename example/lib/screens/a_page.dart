import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nopath_url_history/nopath_url_history.dart';
import '../main.dart'; // Import for AppPage enum
import '../widgets/demo_top_actions.dart';

class APage extends StatefulWidget {
  const APage({super.key});

  @override
  State<APage> createState() => _APageState();
}

class _APageState extends State<APage> {
  final List<_KVItem> _items = [];

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  void _addRow({String keyText = '', String valueText = ''}) {
    setState(() {
      _items.add(_KVItem(
        keyController: TextEditingController(text: keyText),
        valueController: TextEditingController(text: valueText),
      ));
    });
  }

  void _removeRow(int index) {
    setState(() {
      final item = _items.removeAt(index);
      item.dispose();
    });
  }

  Map<String, dynamic> _buildParams() {
    final map = <String, dynamic>{};
    for (final item in _items) {
      final k = item.keyController.text.trim();
      final v = item.valueController.text.trim();
      if (k.isEmpty) continue;
      map[k] = v;
    }
    return map;
  }

  void _reset() {
    for (final i in _items) {
      i.dispose();
    }
    setState(() {
      _items.clear();
      _addRow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = _buildParams();
    return Scaffold(
      appBar: AppBar(
        title: const Text('A Page'),
        backgroundColor: Colors.blue,
        actions: const [DemoTopActions()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('A Page: Build JSON and navigate to B'),
                const SizedBox(height: 12),
                const _InstructionsCard(),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _addRow,
                              child: const Text('Add Key/Value'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _reset,
                              child: const Text('Reset'),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () {
                                // ⭐ Navigate with enum and params (Typed API)
                                JsonNavigator.navigateToEnumWithParams(
                                    AppPage.b, params);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Go to B with JSON'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_items.length, (index) {
                          final item = _items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 240,
                                  child: TextField(
                                    controller: item.keyController,
                                    decoration:
                                        const InputDecoration(labelText: 'key'),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: item.valueController,
                                    decoration: const InputDecoration(
                                        labelText: 'value'),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Remove',
                                  onPressed: () => _removeRow(index),
                                  icon: const Icon(Icons.delete_outline),
                                )
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('JSON Preview'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(jsonEncode(params)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KVItem {
  _KVItem({required this.keyController, required this.valueController});
  final TextEditingController keyController;
  final TextEditingController valueController;
  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Demo Guide:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1) Use the top-right toggles: Logging, Login'),
            Text('2) Add key/values below to build JSON'),
            Text('3) "Go to B with JSON" to pass data'),
            Text('4) If Login is OFF, navigating to B/C redirects to Login'),
          ],
        ),
      ),
    );
  }
}
