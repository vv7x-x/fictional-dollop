import 'package:flutter/material.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/models/hadith.dart';
import '../../widgets/arabic_text.dart';

class HadithDetailScreen extends StatelessWidget {
  final int hadithId;
  const HadithDetailScreen({super.key, required this.hadithId});

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('نص الحديث', textDirection: TextDirection.rtl)),
      body: FutureBuilder<Hadith?>(
        future: repo.getHadithById(hadithId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final h = snap.data;
          if (h == null) {
            return const Center(child: Text('لم يتم العثور على الحديث'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                ArabicText(h.textAr, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text('السند: ${h.sanad}', textDirection: TextDirection.rtl),
                const SizedBox(height: 8),
                Text('المصدر: ${h.collection} • ${h.book} • رقم ${h.number}', textDirection: TextDirection.rtl),
                const SizedBox(height: 8),
                Text('الدرجة: ${h.grade}', textDirection: TextDirection.rtl),
              ],
            ),
          );
        },
      ),
    );
  }
}