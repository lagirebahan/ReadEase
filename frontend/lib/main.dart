import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/main_scaffold.dart';
import 'package:frontend/pages/settings_page.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (_) => AppTheme()..load(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReadEase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainScaffold(), 
      routes: {
        '/home' : (context) => const MainScaffold(),
        '/settings': (context) => const SettingsPage(),
        // '/reader': (context) => const ReaderPage(),
      },
    );
  }
}