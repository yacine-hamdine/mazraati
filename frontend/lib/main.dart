import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import './config/app_theme.dart';

// Onboarding
import './features/onboarding/presentation/screens/onboarding_page.dart';

// Auth
import './features/auth/data/repositories/auth_repository.dart';
import './features/auth/logic/auth_bloc.dart';
import './features/auth/presentation/auth_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mazraati Marketplace',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingPage(),
        '/auth': (context) => BlocProvider(
              create: (context) => AuthBloc(authRepository: authRepository),
              child: const AuthPage(),
            ),
        // '/home': (context) => const HomePage(),
      },
    );
  }
}
