import 'package:flutter/material.dart';

import '../../../../app/locale.dart';
import '../../../post/presentation/pages/post_list_page.dart';
import '../../../post/presentation/pages/search_page.dart';
import '../../../user/presentation/pages/users_page.dart';
import '../../settings/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    _pages = [PostListPage(), SearchPage(), UsersPage(), SettingsPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: context.tr(I18nKeys.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: context.tr(I18nKeys.search)),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: context.tr(I18nKeys.users)),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: context.tr(I18nKeys.settings)),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
