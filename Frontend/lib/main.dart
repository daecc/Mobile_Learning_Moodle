import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/courses_viewmodel.dart';
import 'viewmodels/metacognitive_viewmodel.dart';
import 'viewmodels/riesgo_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/tutor_viewmodel.dart';
import 'views/screens/courses_screen.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/main_navigation_screen.dart';

void main() {
  runApp(const RumboBootstrap());
}

/// Punto de composición de dependencias (MVVM + Provider).
class RumboBootstrap extends StatelessWidget {
  const RumboBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final authVm = AuthViewModel(apiService: apiService);
    final themeVm = ThemeViewModel();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeViewModel>.value(value: themeVm),
        ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
        ChangeNotifierProvider<CoursesViewModel>(
          create: (_) => CoursesViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider<RiesgoViewModel>(
          create: (_) => RiesgoViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider<TutorViewModel>(
          create: (_) => TutorViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider<MetacognitiveViewModel>(
          create: (_) => MetacognitiveViewModel(apiService: apiService),
        ),
      ],
      child: RumboApp(authVm: authVm),
    );
  }
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class RumboApp extends StatelessWidget {
  final AuthViewModel authVm;

  const RumboApp({super.key, required this.authVm});

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<ThemeViewModel>();

    return MaterialApp(
      title: 'Rumbo',
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeVm.themeMode,
      home: ListenableBuilder(
        listenable: authVm,
        builder: (context, _) => authVm.isLoggedIn
            ? const MainNavigationScreen()
            : const LoginScreen(),
      ),
    );
  }
}
