import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Admin/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'Admin/screens/main_screen.dart' as admin;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const KostFinderApp(),
    ),
  );
}

class KostFinderApp extends StatelessWidget {
  const KostFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KostFinder',
      debugShowCheckedModeBanner: false,
      // ── Gunakan AppTheme yang sudah selaras dengan Laravel CSS ───────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoggedIn) {
          if (auth.user?.role == 'admin') {
            return const admin.MainScreen();
          }
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}