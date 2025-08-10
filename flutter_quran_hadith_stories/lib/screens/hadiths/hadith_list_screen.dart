import 'package:flutter/material.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/models/hadith.dart';
import '../../widgets/paged_list_view.dart';
import '../../widgets/arabic_text.dart';
import 'hadith_detail_screen.dart';

class HadithListScreen extends StatefulWidget {
  const HadithListScreen({super.key});

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final ContentRepository _repo = ContentRepository();
  String _collection = 'الكل';
  String _grade = 'الكل';
  late Future<List<String>> _collectionsFuture;
  late Future<List<String>> _gradesFuture;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = _repo.getHadithCollections();
    _gradesFuture = _repo.getHadithGrades();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _collectionsFuture,
                  builder: (c, s) {
                    final items = ['الكل', ...((s.data) ?? [])];
                    return DropdownButtonFormField<String>(
                      value: _collection,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'المجموعة', border: OutlineInputBorder()),
                      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, textDirection: TextDirection.rtl))).toList(),
                      onChanged: (v) => setState(() => _collection = v ?? 'الكل'),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _gradesFuture,
                  builder: (c, s) {
                    final items = ['الكل', ...((s.data) ?? [])];
                    return DropdownButtonFormField<String>(
                      value: _grade,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'الدرجة', border: OutlineInputBorder()),
                      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, textDirection: TextDirection.rtl))).toList(),
                      onChanged: (v) => setState(() => _grade = v ?? 'الكل'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PagedListView<Hadith>(
            pageLoader: (offset, limit) => _repo.getHadiths(limit: limit, offset: offset, collection: _collection, grade: _grade),
            itemBuilder: (context, h, i) {
              return Card(
                child: ListTile(
                  title: ArabicText(h.textAr, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${h.collection} • ${h.book} • رقم ${h.number} • ${h.grade}', textDirection: TextDirection.rtl),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HadithDetailScreen(hadithId: h.id)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}