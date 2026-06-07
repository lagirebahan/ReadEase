import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/main_scaffold.dart';
import 'package:frontend/pages/settings_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/services/auth_service.dart';

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
      home: const AuthWrapper(), 
      routes: {
        '/home' : (context) => const MainScaffold(),
        '/login' : (context) => const LoginPage(),
        '/register' : (context) => const RegisterPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          final theme = context.watch<AppTheme>();
          return Scaffold(
            backgroundColor: theme.baseBg,
            body: Center(
              child: CircularProgressIndicator(color: theme.accentColor),
            ),
          );
        }

        if (snapshot.data == true) {
          return const MainScaffold();
        }

        return const LoginPage();
      },
    );
  }
}