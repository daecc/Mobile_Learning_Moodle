import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mlearning_early_warning/core/config/api_config.dart';
import 'package:mlearning_early_warning/core/network/dio_client.dart';
import 'package:mlearning_early_warning/core/theme/app_theme.dart';
import 'package:mlearning_early_warning/data/services/auth/auth_service.dart';
import 'package:mlearning_early_warning/data/services/auth/auth_service_http.dart';
import 'package:mlearning_early_warning/data/services/course/course_service.dart';
import 'package:mlearning_early_warning/data/services/course/course_service_http.dart';
import 'package:mlearning_early_warning/data/services/risk_api_service.dart';
import 'package:mlearning_early_warning/data/services/risk/risk_api_service_http.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/auth/auth_provider.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/courses/courses_viewmodel.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/risk_viewmodel.dart';
import 'package:mlearning_early_warning/presentation/views/auth/login_view.dart';
import 'package:mlearning_early_warning/presentation/views/navigation/main_navigation_view.dart';
import 'package:mlearning_early_warning/presentation/views/risk_detail/risk_detail_view.dart';

/// Punto de entrada principal de la aplicación M-Learning Early Warning.
///
/// Configura:
/// - MultiProvider para inyección de dependencias (Services + ViewModels)
/// - Tema global (Light/Dark) con Material Design 3
/// - Rutas y navegación con autenticación
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Widget raíz de la aplicación.
///
/// Arquitectura de Providers (Clean Architecture):
/// 1. Capa de Datos: AuthService, CourseService, RiskApiService
/// 2. Capa de Presentación: AuthProvider, CoursesViewModel, RiskViewModel
/// 3. AuthProvider se inicializa primero y restaura sesión automáticamente
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ===== CLIENTE HTTP (Dio) =====
        // Compartido por todos los servicios HTTP; adjunta el JWT automáticamente.
        Provider<Dio>(
          create: (_) => buildDio(),
          dispose: (_, dio) => dio.close(),
        ),

        // ===== CAPA DE DATOS (Services) =====
        // Alterna entre datos Mock y backend FastAPI según ApiConfig.useMock
        Provider<AuthService>(
          create: (context) => ApiConfig.useMock
              ? AuthServiceMock()
              : AuthServiceHttp(dio: context.read<Dio>()),
          dispose: (_, service) => service.clearSession(),
        ),

        Provider<CourseService>(
          create: (context) => ApiConfig.useMock
              ? CourseServiceMock()
              : CourseServiceHttp(dio: context.read<Dio>()),
        ),

        Provider<RiskApiService>(
          create: (context) => ApiConfig.useMock
              ? RiskApiServiceMock()
              : RiskApiServiceHttp(dio: context.read<Dio>()),
        ),

        // ===== CAPA DE PRESENTACIÓN (ViewModels) =====
        // AuthProvider - Gestiona estado global de autenticación
        // Se inicializa automáticamente al crear (restaura sesión)
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
          ),
          lazy: false, // Inicializar inmediatamente para restaurar sesión
        ),

        // CoursesViewModel - Depende de CourseService y AuthProvider (studentId)
        ChangeNotifierProxyProvider2<AuthProvider, CourseService, CoursesViewModel>(
          create: (context) => CoursesViewModel(
            courseService: context.read<CourseService>(),
            studentId: 'EST-0001',
          ),
          update: (context, authProvider, courseService, previous) {
            final newStudentId = authProvider.user?.id ?? 'EST-0001';
            if (previous != null && previous.studentId == newStudentId) {
              return previous;
            }
            return CoursesViewModel(
              courseService: courseService,
              studentId: newStudentId,
            );
          },
        ),

        // RiskViewModel - Depende de RiskApiService
        ProxyProvider<RiskApiService, RiskViewModel>(
          update: (_, apiService, _) => RiskViewModel(apiService: apiService),
          dispose: (_, vm) => vm.dispose(),
        ),
      ],
      child: const _AppView(),
    );
  }
}

/// Vista principal que configura tema, rutas y navegación con guard de auth.
class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M-Learning Early Warning',
      debugShowCheckedModeBanner: false,

      // Temas Material 3
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Rutas nombradas
      routes: {
        '/login': (_) => const LoginView(),
        '/home': (_) => const MainNavigationView(),
        '/risk-detail': (_) => const RiskDetailView(),
      },

      // Ruta inicial: Decide según estado de auth
      home: const _AuthGate(),

      // Builder global
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.85, 1.15),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}

/// Gate de autenticación: muestra Login o Home según estado.
///
/// Escucha AuthProvider y navega automáticamente:
/// - initializing → Splash/Loading
/// - unauthenticated/error → LoginView
/// - authenticated → MainNavigationView
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Loading inicial mientras restaura sesión
    if (authProvider.isInitializing) {
      return const _SplashScreen();
    }

    // Autenticado → Home con navegación
    if (authProvider.isAuthenticated) {
      return const MainNavigationView();
    }

    // No autenticado → Login
    return const LoginView();
  }
}

/// Pantalla de carga inicial (Splash)
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            // Container no puede ser const por BoxShadow
            Container( // ignore: prefer_const_constructors
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'M-Learning Early Warning',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sistema de Alerta Temprana Académica',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Restaurando sesión...',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}