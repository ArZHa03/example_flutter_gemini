import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class EmbeddingsSection extends StatefulWidget {
  const EmbeddingsSection({super.key});

  @override
  State<EmbeddingsSection> createState() => _EmbeddingsSectionState();
}

class _EmbeddingsSectionState extends State<EmbeddingsSection> {
  final Gemini gemini = Gemini.instance;
  final TextEditingController _controller = TextEditingController();

  String _output = '';
  bool _loading = false;

  void _embedContent() {
    if (_controller.text.isEmpty) return;
    setState(() => _loading = true);

    gemini
        .batchEmbedContents([_controller.text])
        .then((value) {
          // Technically batchEmbedContents returns a list of embeddings
          final first = value?.isNotEmpty == true ? value!.first : null;
          final embedding = first?.join(', ') ?? 'No embedding';
          setState(() {
            _output = 'Embedding (Truncated):\n[$embedding]';
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

  void _batchEmbed() {
    // Demo batch: Split text by comma
    if (_controller.text.isEmpty) return;
    final texts = _controller.text.split(',');

    setState(() => _loading = true);

    gemini
        .batchEmbedContents(texts)
        .then((value) {
          final sb = StringBuffer();
          int i = 0;
          value?.forEach((e) {
            sb.writeln('Text: ${texts[i++].trim()}');
            sb.writeln('Vector: [${e?.take(5).join(', ')}...]'); // Truncate for display
            sb.writeln('----------------');
          });
          setState(() {
            _output = sb.toString();
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
      appBar: AppBar(title: const Text('Embeddings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Enter text (comma separated for batch)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _loading ? null : _embedContent, child: const Text('Embed (Single)')),
                ElevatedButton(onPressed: _loading ? null : _batchEmbed, child: const Text('Batch Embed (Split by comma)')),
              ],
            ),
            if (_loading) const Padding(padding: EdgeInsets.only(top: 12.0), child: LinearProgressIndicator()),
            const SizedBox(height: 12),
            Expanded(child: SingleChildScrollView(child: Text(_output))),
          ],
        ),
      ),
    );
  }
}
