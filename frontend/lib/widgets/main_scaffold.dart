import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/notes_page.dart';
import 'package:frontend/pages/upload_page.dart';

class MainScaffold extends StatefulWidget{
  const MainScaffold({super.key});

  @override
  State<StatefulWidget> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>{
  int _currentIndex = 0;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> get _pages => [
    HomePage(
      key: ValueKey('home_$_refreshCounter'),
      onSeeAll: () => setState(() {
        _currentIndex = 1;
      }),
    ),
    NotesPage(
      key: ValueKey('notes_$_refreshCounter'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.baseBg,
      appBar: AppBar(
        backgroundColor: theme.surfaceBg,
        title: Text('ReadEase', style: theme.baseTextStyle(theme.primaryTextColor).copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.settings, color: theme.primaryTextColor),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
        ]
      ),

      body: _pages[_currentIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const UploadPage(),
            ),
          ).then((_) {
            setState(() {
              _refreshCounter++;
            });
          });
        },
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex= index;
            });
          },   
                 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.note_outlined),
              activeIcon: Icon(Icons.note),
              label: 'Notes',
            ),
          ] 
        ),
    );
  }
}