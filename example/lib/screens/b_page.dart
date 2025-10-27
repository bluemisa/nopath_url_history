import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nopath_url_history/nopath_url_history.dart';

class BPage extends StatefulWidget {
  const BPage({super.key});

  @override
  State<BPage> createState() => _BPageState();
}

class _BPageState extends State<BPage> {
  int refreshCount = 0;
  final List<_KVItem> _customParams = [];

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  @override
  void dispose() {
    for (final item in _customParams) {
      item.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    setState(() {
      refreshCount++;
    });
  }

  void _addRow({String keyText = '', String valueText = ''}) {
    setState(() {
      _customParams.add(_KVItem(
        keyController: TextEditingController(text: keyText),
        valueController: TextEditingController(text: valueText),
      ));
    });
  }

  void _removeRow(int index) {
    setState(() {
      final item = _customParams.removeAt(index);
      item.dispose();
    });
  }

  Map<String, dynamic> _buildCustomParams() {
    final map = <String, dynamic>{};
    for (final item in _customParams) {
      final k = item.keyController.text.trim();
      final v = item.valueController.text.trim();
      if (k.isEmpty) continue;
      map[k] = v;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    // ⭐ Get parameters passed from previous page
    final params = JsonNavigator.getParams();

    return Scaffold(
      appBar: AppBar(
        title: const Text('B Page'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: JsonNavigator.goBack, // ⭐ Browser back
            tooltip: 'Back',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: JsonNavigator.goForward, // ⭐ Browser forward
            tooltip: 'Forward',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'B Page: Test Navigation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test Steps:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('1. A → B: Check params below'),
                        const Text(
                            '2. Click Refresh (top) - params should persist'),
                        const Text(
                            '3. Browser refresh (F5) - params should persist'),
                        const Text('4. Click Back - go to A'),
                        const Text(
                            '5. Click Forward - return to B with params'),
                        const SizedBox(height: 8),
                        Text(
                          'Refresh Count: $refreshCount',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
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
                        const Text(
                          'Params from A:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            jsonEncode(params),
                            style: const TextStyle(
                                fontSize: 14, fontFamily: 'monospace'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  JsonNavigator.navigateToWithParams(
                                      'c', params), // ⭐ With params
                              child: const Text('Go to C (same params)'),
                            ),
                            ElevatedButton(
                              onPressed: () => JsonNavigator.navigateTo(
                                  'c'), // ⭐ Without params
                              child: const Text('Go to C (empty)'),
                            ),
                          ],
                        ),
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
                        Row(
                          children: [
                            const Text(
                              'Custom Params for C:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addRow,
                              tooltip: 'Add Key/Value',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(_customParams.length, (index) {
                          final item = _customParams[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: item.keyController,
                                    decoration: const InputDecoration(
                                      labelText: 'key',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: item.valueController,
                                    decoration: const InputDecoration(
                                      labelText: 'value',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
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
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            final customParams = _buildCustomParams();
                            JsonNavigator.navigateToWithParams(
                                'c', customParams);
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Go to C with custom params'),
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
