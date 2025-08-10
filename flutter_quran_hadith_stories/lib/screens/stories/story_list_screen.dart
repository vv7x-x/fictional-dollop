import 'package:flutter/material.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/models/story.dart';
import '../../widgets/paged_list_view.dart';
import 'story_detail_screen.dart';

class StoryListScreen extends StatelessWidget {
  const StoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository();
    return PagedListView<Story>(
      pageLoader: (offset, limit) => repo.getStories(limit: limit, offset: offset),
      itemBuilder: (context, s, i) {
        return Card(
          child: ListTile(
            title: Text(s.title, textDirection: TextDirection.rtl),
            subtitle: Text('النبي: ${s.prophet}', textDirection: TextDirection.rtl),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => StoryDetailScreen(storyId: s.id)),
            ),
          ),
        );
      },
    );
  }
}