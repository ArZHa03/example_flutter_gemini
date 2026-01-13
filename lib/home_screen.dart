import 'package:example_flutter_gemini_new/sections/advanced_section.dart';
import 'package:example_flutter_gemini_new/sections/chat_section.dart';
import 'package:example_flutter_gemini_new/sections/chat_stream_section.dart';
import 'package:example_flutter_gemini_new/sections/embeddings_section.dart';
import 'package:example_flutter_gemini_new/sections/legacy_section.dart';
import 'package:example_flutter_gemini_new/sections/text_and_image_section.dart';
import 'package:example_flutter_gemini_new/sections/utility_section.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<SectionItem> _sections = [
    SectionItem(
      title: 'Stream & Future',
      subtitle: 'Text Prompt Log',
      icon: Icons.chat_bubble_outline,
      target: const ChatStreamSection(),
    ),
    SectionItem(
      title: 'Multi-turn Chat',
      subtitle: 'Conversational UI',
      icon: Icons.forum,
      target: const ChatSection(),
    ),
    SectionItem(
      title: 'Text & Image',
      subtitle: 'Multimodal Inputs',
      icon: Icons.image,
      target: const TextAndImageSection(),
    ),
    SectionItem(
      title: 'Utility APIs',
      subtitle: 'Tokens, Model Info',
      icon: Icons.info_outline,
      target: const UtilitySection(),
    ),
     SectionItem(
      title: 'Embeddings',
      subtitle: 'EmbedContents & Batch',
      icon: Icons.code,
      target: const EmbeddingsSection(),
    ),
    SectionItem(
      title: 'Advanced Usage',
      subtitle: 'Safety & Config',
      icon: Icons.settings,
      target: const AdvancedSection(),
    ),
    SectionItem(
      title: 'Legacy APIs',
      subtitle: 'Old Methods',
      icon: Icons.history,
      target: const LegacySection(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _sections[index];
          return Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(item.icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => item.target),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SectionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget target;

  SectionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.target,
  });
}
