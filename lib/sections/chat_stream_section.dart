import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ChatStreamSection extends StatefulWidget {
  const ChatStreamSection({super.key});

  @override
  State<ChatStreamSection> createState() => _ChatStreamSectionState();
}

class _ChatStreamSectionState extends State<ChatStreamSection> {
  final TextEditingController _controller = TextEditingController();
  final Gemini gemini = Gemini.instance;
  String _result = '';
  bool _loading = false;

  void _generate(bool stream) {
    if (_controller.text.isEmpty) return;

    setState(() {
      _loading = true;
      _result = '';
    });

    final prompt = _controller.text;

    if (stream) {
      gemini
          .promptStream(parts: [Part.text(prompt)])
          .listen(
            (value) {
              setState(() {
                _result += value?.output ?? '';
              });
            },
            onError: (e) {
              setState(() {
                _loading = false;
                _result = 'Error: $e';
              });
            },
            onDone: () {
              setState(() {
                _loading = false;
              });
            },
          );
    } else {
      gemini
          .prompt(parts: [Part.text(prompt)])
          .then((value) {
            setState(() {
              _result = value?.output ?? 'No output';
              _loading = false;
            });
          })
          .catchError((e) {
            setState(() {
              _result = 'Error: $e';
              _loading = false;
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stream & Future Log')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _result.isEmpty && !_loading
                  ? const Center(child: Text('Enter a prompt to start'))
                  : MarkdownBody(data: _result),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Enter prompt', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loading ? null : () => _generate(false),
                  icon: const Icon(Icons.send),
                  tooltip: 'Future (Text)',
                ),
                IconButton(
                  onPressed: _loading ? null : () => _generate(true),
                  icon: const Icon(Icons.flash_on),
                  tooltip: 'Stream',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
