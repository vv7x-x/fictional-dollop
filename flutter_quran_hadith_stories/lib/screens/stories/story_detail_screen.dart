import 'package:flutter/material.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/models/story.dart';
import '../../widgets/arabic_text.dart';

class StoryDetailScreen extends StatelessWidget {
  final int storyId;
  const StoryDetailScreen({super.key, required this.storyId});

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('قصة النبي', textDirection: TextDirection.rtl)),
      body: FutureBuilder<Story?>(
        future: repo.getStoryById(storyId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = snap.data;
          if (s == null) {
            return const Center(child: Text('لم يتم العثور على القصة'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(s.title, textDirection: TextDirection.rtl, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('النبي: ${s.prophet}', textDirection: TextDirection.rtl, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                ArabicText(s.content, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          );
        },
      ),
    );
  }
}