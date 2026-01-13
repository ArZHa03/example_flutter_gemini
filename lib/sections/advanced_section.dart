import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class AdvancedSection extends StatefulWidget {
  const AdvancedSection({super.key});

  @override
  State<AdvancedSection> createState() => _AdvancedSectionState();
}

class _AdvancedSectionState extends State<AdvancedSection> {
  final Gemini gemini = Gemini.instance;
  final TextEditingController _promptController = TextEditingController();

  double _temperature = 0.5;
  int _maxTokens = 100;
  String _result = '';
  bool _loading = false;

  void _generateWithConfig() {
    if (_promptController.text.isEmpty) return;
    setState(() => _loading = true);

    gemini
        .promptStream(
          parts: [Part.text(_promptController.text)],
          generationConfig: GenerationConfig(temperature: _temperature, maxOutputTokens: _maxTokens),
          safetySettings: [
            SafetySetting(category: SafetyCategory.harassment, threshold: SafetyThreshold.blockLowAndAbove),
            SafetySetting(category: SafetyCategory.hateSpeech, threshold: SafetyThreshold.blockLowAndAbove),
          ],
        )
        .listen(
          (value) {
            setState(() {
              _result += value?.output ?? '';
            });
          },
          onError: (e) {
            setState(() {
              _result = 'Error: $e';
              _loading = false;
            });
          },
          onDone: () {
            setState(() {
              _loading = false;
            });
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Config')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Generation Config', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Text('Temperature: '),
                Expanded(
                  child: Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _temperature.toString(),
                    onChanged: (v) => setState(() => _temperature = v),
                  ),
                ),
                Text(_temperature.toString()),
              ],
            ),
            Row(
              children: [
                const Text('Max Tokens: '),
                Expanded(
                  child: Slider(
                    value: _maxTokens.toDouble(),
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    label: _maxTokens.toString(),
                    onChanged: (v) => setState(() => _maxTokens = v.toInt()),
                  ),
                ),
                Text(_maxTokens.toString()),
              ],
            ),
            const Divider(),
            const Text(
              'Safety Settings: Hardcoded to Block Low & Above for Harassment/Hate',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const Divider(),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(hintText: 'Enter prompt to test config', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () {
                        setState(() => _result = '');
                        _generateWithConfig();
                      },
                child: const Text('Generate with Config'),
              ),
            ),
            if (_loading) const Padding(padding: EdgeInsets.only(top: 8.0), child: LinearProgressIndicator()),
            const SizedBox(height: 12),
            const Text('Output:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: MarkdownBody(data: _result),
            ),
          ],
        ),
      ),
    );
  }
}
