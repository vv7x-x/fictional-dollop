import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text('عن التطبيق', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('تطبيق لعرض تفسير القرآن الكريم، الأحاديث الصحيحة، وقصص الأنبياء بواجهة عربية ودعم للبحث الموحّد.', textDirection: TextDirection.rtl),
        SizedBox(height: 12),
        Text('المصادر:', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text('- التفاسير: كتب معتمدة مثل تفسير ابن كثير', textDirection: TextDirection.rtl),
        Text('- الأحاديث: كتب معتمدة مثل صحيح البخاري وصحيح مسلم', textDirection: TextDirection.rtl),
        Text('- القصص: مصادر مقيدة من كتب التاريخ والسيرة', textDirection: TextDirection.rtl),
        SizedBox(height: 12),
        Text('ملاحظة: تأكد دائماً من التحقق من صحة الأحاديث ودرجتها من مصادر موثوقة.', textDirection: TextDirection.rtl),
      ],
    );
  }
}