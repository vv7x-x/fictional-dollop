import 'package:flutter/material.dart';
import '../../data/database_helper.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _refreshDb(BuildContext context) async {
    await DatabaseHelper.refreshFromAssets();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث قاعدة البيانات من الملفات المرفقة.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('عن التطبيق', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('تطبيق لعرض تفسير القرآن الكريم، الأحاديث الصحيحة، وقصص الأنبياء بواجهة عربية ودعم للبحث الموحّد.', textDirection: TextDirection.rtl),
        const SizedBox(height: 12),
        const Text('المصادر:', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('- التفاسير: كتب معتمدة مثل تفسير ابن كثير', textDirection: TextDirection.rtl),
        const Text('- الأحاديث: كتب معتمدة مثل صحيح البخاري وصحيح مسلم', textDirection: TextDirection.rtl),
        const Text('- القصص: مصادر موثوقة من كتب التاريخ والسيرة', textDirection: TextDirection.rtl),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _refreshDb(context),
          icon: const Icon(Icons.refresh),
          label: const Text('تحديث قاعدة البيانات من الملفات'),
        ),
      ],
    );
  }
}