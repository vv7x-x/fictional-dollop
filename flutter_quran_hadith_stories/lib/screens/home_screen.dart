import 'package:flutter/material.dart';
import 'tafsir/surah_list_screen.dart';
import 'hadiths/hadith_list_screen.dart';
import 'stories/story_list_screen.dart';
import 'search/search_screen.dart';
import 'about/about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      SurahListScreen(),
      HadithListScreen(),
      StoryListScreen(),
      SearchScreen(),
      AboutScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكتبة الإسلامية', textDirection: TextDirection.rtl),
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'التفسير'),
          NavigationDestination(icon: Icon(Icons.book_outlined), label: 'أحاديث'),
          NavigationDestination(icon: Icon(Icons.auto_stories), label: 'قصص'),
          NavigationDestination(icon: Icon(Icons.search), label: 'بحث'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'حول'),
        ],
      ),
    );
  }
}