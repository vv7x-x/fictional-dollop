import 'package:flutter/material.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/models/verse.dart';
import '../../data/models/tafsir.dart';
import '../../widgets/arabic_text.dart';

class VerseListScreen extends StatelessWidget {
  final int surahId;
  final String surahName;

  const VerseListScreen({super.key, required this.surahId, required this.surahName});

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository();

    return Scaffold(
      appBar: AppBar(title: Text(surahName, textDirection: TextDirection.rtl)),
      body: FutureBuilder<List<Verse>>(
        future: repo.getVersesBySurah(surahId, limit: 3000, offset: 0),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final verses = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, i) {
              final v = verses[i];
              return _VerseWithTafsirTile(verse: v);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: verses.length,
          );
        },
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
                ArabicText('﴿ ${verse.textAr} ﴾', style: Theme.of(context).textTheme.titleMedium),
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