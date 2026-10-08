import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/home/screens/home_shell.dart';
import 'providers/auth_provider.dart';
import 'providers/habit_provider.dart';
import 'services/auth_service.dart';
import 'services/habit_service.dart';

class MomentumApp extends StatelessWidget {
  const MomentumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(AuthService()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, HabitProvider>(
          create: (_) => HabitProvider(HabitService()),
          update: (_, auth, habits) => habits!..bindUser(auth.user?.uid),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: auth.initializing
          ? const SplashScreen(key: ValueKey('splash'))
          : auth.isAuthenticated
              ? const HomeShell(key: ValueKey('home'))
              : const LoginScreen(key: ValueKey('login')),
    );
  }
}
