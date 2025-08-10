import 'package:flutter/material.dart';
import '../../data/repositories/content_repository.dart';
import '../../widgets/arabic_text.dart';
import '../hadiths/hadith_detail_screen.dart';
import '../stories/story_detail_screen.dart';
import '../tafsir/verse_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ContentRepository _repo = ContentRepository();
  Map<String, List<Map<String, Object?>>> _results = const {
    'tafsir': [],
    'hadiths': [],
    'stories': [],
  };
  bool _loading = false;

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() => _loading = true);
    final res = await _repo.searchAll(q);
    if (!mounted) return;
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'ابحث في التفاسير والأحاديث والقصص',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _search, child: const Text('بحث')),
            ],
          ),
        ),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView(
            children: [
              _buildSection(
                title: 'تفاسير',
                items: _results['tafsir'] ?? [],
                itemBuilder: (item) => ListTile(
                  title: ArabicText(item['content'] as String? ?? ''),
                  subtitle: Text('المصدر: ${item['source']}', textDirection: TextDirection.rtl),
                  onTap: () {
                    final verseId = item['verse_id'] as int;
                    final surahId = item['surah_id'] as int;
                    final surahName = (item['surah_name'] as String?) ?? 'السورة';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VerseListScreen(surahId: surahId, surahName: surahName),
                      ),
                    );
                  },
                ),
              ),
              _buildSection(
                title: 'أحاديث',
                items: _results['hadiths'] ?? [],
                itemBuilder: (item) => ListTile(
                  title: ArabicText(item['content'] as String? ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${item['collection']} • ${item['book']} • رقم ${item['number']}', textDirection: TextDirection.rtl),
                  onTap: () {
                    final id = item['id'] as int;
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => HadithDetailScreen(hadithId: id)));
                  },
                ),
              ),
              _buildSection(
                title: 'قصص',
                items: _results['stories'] ?? [],
                itemBuilder: (item) => ListTile(
                  title: Text(item['title'] as String? ?? '', textDirection: TextDirection.rtl),
                  subtitle: ArabicText(item['content'] as String? ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    final id = item['id'] as int;
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryDetailScreen(storyId: id)));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Map<String, Object?>> items, required Widget Function(Map<String, Object?>) itemBuilder}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Card(
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(title, textDirection: TextDirection.rtl),
          children: items.isEmpty
              ? [const ListTile(title: Text('لا توجد نتائج', textDirection: TextDirection.rtl))]
              : items.map(itemBuilder).toList(),
        ),
      ),
    );
  }
}