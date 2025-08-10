import 'package:flutter/material.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/models/verse.dart';
import '../../data/models/tafsir.dart';
import '../../widgets/arabic_text.dart';
import '../../widgets/paged_list_view.dart';

class VerseListScreen extends StatelessWidget {
  final int surahId;
  final String surahName;

  const VerseListScreen({super.key, required this.surahId, required this.surahName});

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository();

    return Scaffold(
      appBar: AppBar(title: Text(surahName, textDirection: TextDirection.rtl)),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('مرر للأسفل لتحميل مزيد من الآيات', textDirection: TextDirection.rtl),
          ),
          Expanded(
            child: PagedListView<Verse>(
              pageLoader: (offset, limit) => repo.getVersesBySurah(surahId, limit: limit, offset: offset),
              itemBuilder: (context, v, i) => _VerseWithTafsirTile(verse: v),
              pageSize: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseWithTafsirTile extends StatelessWidget {
  final Verse verse;
  const _VerseWithTafsirTile({required this.verse});

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ArabicText('﴿ ${verse.textAr} ﴾', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(width: 8),
                Text('(${verse.ayahNumber})', textDirection: TextDirection.rtl),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<Tafsir?>(
              future: repo.getTafsirForVerse(verse.id),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }
                final t = snap.data;
                if (t == null) {
                  return const Text('لا يوجد تفسير متاح لهذه الآية');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('المصدر: ${t.source}', textDirection: TextDirection.rtl, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 6),
                    ArabicText(t.text, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}