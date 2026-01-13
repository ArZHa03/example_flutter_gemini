import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ChatSection extends StatefulWidget {
  const ChatSection({super.key});

  @override
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  final TextEditingController _controller = TextEditingController();
  final Gemini gemini = Gemini.instance;
  final List<Content> _chats = [];
  bool _loading = false;

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    final String message = _controller.text;
    _controller.clear();

    setState(() {
      _chats.add(Content(role: 'user', parts: [Part.text(message)]));
      _loading = true;
    });

    gemini
        .streamChat(_chats)
        .listen(
          (value) {
            if (_chats.isNotEmpty && _chats.last.role == 'model') {
              // Append to existing model message
              final lastPart = _chats.last.parts?.lastOrNull;
              final existing = (lastPart is TextPart) ? lastPart.text : '';
              final newText = value.output ?? '';
              // If the last part is text, update it.
              // Note: Simple implementation assuming last part is always text for now.
              // Recreating the Content object for simplicity in this demo.
              setState(() {
                _chats.last = Content(role: 'model', parts: [Part.text(existing + newText)]);
              });
            } else {
              // New model message
              setState(() {
                _chats.add(Content(role: 'model', parts: [Part.text(value.output ?? '')]));
              });
            }
          },
          onError: (e) {
            setState(() {
              _loading = false;
              _chats.add(Content(role: 'model', parts: [Part.text('Error: $e')]));
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
      appBar: AppBar(title: const Text('Multi-turn Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final content = _chats[index];
                final isUser = content.role == 'user';
                final text =
                    content.parts?.fold(
                      '',
                      (previousValue, element) => previousValue + (element is TextPart ? element.text : ''),
                    ) ??
                    '';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    child: MarkdownBody(data: text),
                  ),
                );
              },
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
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder()),
                  ),
                ),
                IconButton(onPressed: _loading ? null : _sendMessage, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
