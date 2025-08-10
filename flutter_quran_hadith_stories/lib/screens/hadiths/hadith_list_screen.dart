import 'package:flutter/material.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/models/hadith.dart';
import '../../widgets/paged_list_view.dart';
import '../../widgets/arabic_text.dart';
import 'hadith_detail_screen.dart';

class HadithListScreen extends StatelessWidget {
  const HadithListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository();
    return PagedListView<Hadith>(
      pageLoader: (offset, limit) => repo.getHadiths(limit: limit, offset: offset),
      itemBuilder: (context, h, i) {
        return Card(
          child: ListTile(
            title: ArabicText(h.textAr, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('${h.collection} • ${h.book} • رقم ${h.number}', textDirection: TextDirection.rtl),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HadithDetailScreen(hadithId: h.id)),
            ),
          ),
        );
      },
    );
  }
}