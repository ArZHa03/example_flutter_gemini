import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart';

class TextAndImageSection extends StatefulWidget {
  const TextAndImageSection({super.key});

  @override
  State<TextAndImageSection> createState() => _TextAndImageSectionState();
}

class _TextAndImageSectionState extends State<TextAndImageSection> {
  final TextEditingController _controller = TextEditingController();
  final Gemini gemini = Gemini.instance;
  final ImagePicker _picker = ImagePicker();

  String _result = '';
  bool _loading = false;
  Uint8List? _selectedImageBytes;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  void _generate() {
    if (_controller.text.isEmpty && _selectedImageBytes == null) return;
    if (_selectedImageBytes == null) {
      setState(() {
        _result = 'Please select an image.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _result = '';
    });

    gemini
        .prompt(
          parts: [
            Part.text(_controller.text),
            Part.inline(InlineData(mimeType: 'image/jpeg', data: base64Encode(_selectedImageBytes!))),
          ],
        )
        .then((value) {
          setState(() {
            _result = value?.content?.parts?.fold('', (p, e) => p ?? (e is TextPart ? e.text : '')) ?? 'No output';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text and Image')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _result.isEmpty && !_loading
                  ? const Center(child: Text('Enter prompt and select image'))
                  : MarkdownBody(data: _result),
            ),
          ),
          if (_selectedImageBytes != null)
            Container(height: 100, padding: const EdgeInsets.all(8), child: Image.memory(_selectedImageBytes!)),
          if (_loading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(onPressed: _loading ? null : _pickImage, icon: const Icon(Icons.image), tooltip: 'Pick Image'),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Enter prompt (optional)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _loading ? null : _generate, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
