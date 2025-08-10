# المكتبة الإسلامية (Flutter)

تطبيق Flutter باللغة العربية لعرض:
- تفسير آيات القرآن الكريم
- مكتبة الأحاديث النبوية الصحيحة
- قصص الأنبياء
- بحث موحّد عبر المحتوى

## المتطلبات
- Flutter SDK
- Python 3 (لاختيارياً لتوليد قاعدة البيانات من JSON)

## الإعداد
1) تثبيت الحزم:
```
flutter pub get
```

2) إنشاء قاعدة البيانات من ملفات JSON (عينات موجودة):
```
python3 scripts/json_to_sqlite.py --tafsir assets/json/tafsir_sample.json --hadiths assets/json/ahadith_sample.json --stories assets/json/stories_sample.json --out assets/databases/knowledge.db
```

3) التشغيل:
```
flutter run
```

> ملاحظة: عند أول تشغيل يقوم التطبيق بنسخ ملف `assets/databases/knowledge.db` إلى مجلد التطبيق الداخلي ثم يفتح القاعدة محليًا.

## البنية
- `lib/` الشفرة المصدرية للتطبيق
- `assets/databases/` قاعدة SQLite الجاهزة
- `assets/json/` عينات JSON
- `scripts/` سكربت تحويل JSON إلى SQLite

## مصادر البيانات
- التفاسير: مثل تفسير ابن كثير، السعدي
- الأحاديث: صحيح البخاري، صحيح مسلم
- القصص: مصادر موثوقة من كتب التاريخ والسيرة

يرجى التأكد من التزام حقوق النشر للمصادر الأصلية.