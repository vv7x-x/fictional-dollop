import 'package:flutter/material.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/models/surah.dart';
import 'verse_list_screen.dart';
import '../../widgets/arabic_text.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final ContentRepository _repo = ContentRepository();
  late Future<List<Surah>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getSurahs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Surah>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final surahs = snap.data ?? [];
        return ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (context, i) {
            final s = surahs[i];
            return Card(
              child: ListTile(
                title: ArabicText(s.nameAr, style: Theme.of(context).textTheme.titleMedium),
                trailing: const Icon(Icons.arrow_back_ios_new),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VerseListScreen(surahId: s.id, surahName: s.nameAr),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}