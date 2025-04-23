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

// Home
import './features/home/data/repositories/home_repository.dart';
import './features/home/data/providers/home_api_provider.dart';
import './features/home/logic/home_bloc.dart';
import './features/home/logic/home_event.dart';
import './features/home/presentation/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final apiProvider = HomeApiProvider();
    final homeRepository = HomeRepository(apiProvider: apiProvider);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => authRepository),
        RepositoryProvider<HomeRepository>(create: (_) => homeRepository),
      ],
      child: MaterialApp(
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
          '/home': (context) => BlocProvider(
                create: (context) => HomeBloc(repository: homeRepository),
                child: const HomePage(),
              ),
        },
      ),
    );
  }
}
