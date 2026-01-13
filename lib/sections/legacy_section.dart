import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class LegacySection extends StatefulWidget {
  const LegacySection({super.key});

  @override
  State<LegacySection> createState() => _LegacySectionState();
}

class _LegacySectionState extends State<LegacySection> {
  final Gemini gemini = Gemini.instance;
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _output = '';
  bool _loading = false;
  Uint8List? _imageBytes;

  void _streamGenerate() {
    if (_promptController.text.isEmpty) return;
    setState(() {
      _output = '';
      _loading = true;
    });

    gemini
        .promptStream(parts: [Part.text(_promptController.text)])
        .listen(
          (value) {
            setState(() {
              _output += value?.output ?? '';
            });
          },
          onError: (e) {
            setState(() => _output = 'Error: $e');
            _loading = false;
          },
          onDone: () {
            setState(() => _loading = false);
          },
        );
  }

  void _textOnly() {
    if (_promptController.text.isEmpty) return;
    setState(() {
      _loading = true;
      _output = 'Loading...';
    });

    gemini
        .prompt(parts: [Part.text(_promptController.text)])
        .then((value) {
          setState(() {
            _output = value?.output ?? 'No output';
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

  void _textAndImage() {
    if (_imageBytes == null) {
      setState(() => _output = 'Pick an image first');
      return;
    }
    setState(() {
      _loading = true;
      _output = 'Loading...';
    });

    gemini
        .prompt(
          parts: [
            Part.text(_promptController.text.isEmpty ? 'Describe this' : _promptController.text),
            Part.inline(InlineData(mimeType: 'image/jpeg', data: base64Encode(_imageBytes!))),
          ],
        )
        .then((value) {
          setState(() {
            _output = value?.content?.parts?.fold('', (p, e) => p ?? (e is TextPart ? e.text : '')) ?? 'No output';
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _output = 'Image selected';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completions (Legacy)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(labelText: 'Prompt', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            if (_imageBytes != null) SizedBox(height: 100, child: Image.memory(_imageBytes!)),
            ElevatedButton(onPressed: _pickImage, child: const Text('Pick Image (For Text & Image)')),
            const Divider(),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: _loading ? null : _streamGenerate, child: const Text('Stream Generate')),
                ElevatedButton(onPressed: _loading ? null : _textOnly, child: const Text('Text Only')),
                ElevatedButton(onPressed: _loading ? null : _textAndImage, child: const Text('Text & Image')),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 20),
            Text(_output),
          ],
        ),
      ),
    );
  }
}
