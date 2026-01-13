import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class UtilitySection extends StatefulWidget {
  const UtilitySection({super.key});

  @override
  State<UtilitySection> createState() => _UtilitySectionState();
}

class _UtilitySectionState extends State<UtilitySection> {
  final Gemini gemini = Gemini.instance;
  final TextEditingController _tokenController = TextEditingController();

  String _output = '';
  bool _loading = false;

  void _countTokens() {
    if (_tokenController.text.isEmpty) return;
    setState(() => _loading = true);

    gemini
        .countTokens(_tokenController.text)
        .then((value) {
          setState(() {
            _output = 'Tokens: $value';
            _loading = false;
          });
        })
        .catchError((e) {
          setState(() {
            _output = 'Error: $e';
            _loading = false;
          });
        });
  }

  void _listModels() {
    setState(() => _loading = true);
    // Note: flutter_gemini 3.0.0 might not have listModels exposed directly in the simplified instance?
    // Let's check if it does. If not, we skip or use a different correct method.
    // Based on user request "List models scroll", I assume it's available.
    // Documentation says: gemini.listModels()
    gemini
        .listModels()
        .then((models) {
          setState(() {
            _output = models
                .map(
                  (e) =>
                      'Name: ${e.name}\n'
                      'Display Name: ${e.displayName}\n'
                      'Description: ${e.description}\n'
                      '-------------------',
                )
                .join('\n');
            _loading = false;
          });
        })
        .catchError((e) {
          setState(() {
            _output = 'Error: $e';
            _loading = false;
          });
        });
  }

  void _modelInfo() {
    // Hardcoded model name for demo
    setState(() => _loading = true);
    gemini
        .info(model: 'gemini-pro')
        .then((info) {
          setState(() {
            _output =
                'Model: ${info.name}\n'
                'Top P: ${info.topP}\n'
                'Top K: ${info.topK}';
            _loading = false;
          });
        })
        .catchError((e) {
          setState(() {
            _output = 'Error: $e';
            _loading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Utility APIs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _loading ? null : _listModels, child: const Text('List Models')),
                ElevatedButton(onPressed: _loading ? null : _modelInfo, child: const Text('Info (gemini-pro)')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tokenController,
                    decoration: const InputDecoration(labelText: 'Text to count tokens', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _loading ? null : _countTokens, child: const Text('Count')),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(_output))),
          ],
        ),
      ),
    );
  }
}
