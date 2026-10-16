import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import 'courses_screen.dart';

/// Pantalla de acceso al Aula Virtual (Moodle LMS).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codigoController = TextEditingController(text: 'guillermo1234');
  final _passwordController = TextEditingController(text: 'Base22SW42');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _codigoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _seleccionarCuenta(String usuario, String password) {
    setState(() {
      _codigoController.text = usuario;
      _passwordController.text = password;
    });
  }

  Future<void> _ingresar() async {
    final codigo = _codigoController.text.trim();
    final password = _passwordController.text.trim();

    if (codigo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu usuario y contraseña de Moodle.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final ok = await authVm.login(codigo, password);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CoursesScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  authVm.error ?? 'Error al iniciar sesión. Revisa tus credenciales.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.riskHigh,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final themeVm = context.watch<ThemeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Botón de Modo Oscuro en la esquina superior
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => themeVm.toggleTheme(),
                      icon: Icon(
                        themeVm.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: themeVm.isDarkMode ? Colors.amber : AppColors.textSecondaryOf(context),
                      ),
                      tooltip: themeVm.isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                    ),
                  ),

                  // Logo e Identidad Institucional
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Badge Institucional UNMSM
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.brandSoftOf(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.brand.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 14, color: AppColors.brand),
                          SizedBox(width: 6),
                          Text(
                            'UNMSM · FISI · MoodleCloud',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brand,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Rumbo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimaryOf(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Analítica Predictiva y Prevención de Riesgo Académico en Moodle',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryOf(context),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tarjeta del Formulario
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderOf(context)),
                      boxShadow: AppColors.cardShadowOf(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _codigoController,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: AppColors.textPrimaryOf(context)),
                          decoration: const InputDecoration(
                            labelText: 'Usuario Moodle',
                            hintText: 'ej. guillermo1234',
                            prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.brand),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(color: AppColors.textPrimaryOf(context)),
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.brand),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textMutedOf(context),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          onSubmitted: (_) => _ingresar(),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: authVm.isLoading ? null : _ingresar,
                          child: authVm.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Iniciar Sesión'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Acceso rápido para presentación / pruebas
                  Text(
                    'Cuentas registradas para la sustentación:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMutedOf(context),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.school_outlined, size: 16, color: AppColors.brand),
                        label: const Text('Guillermo (3 cursos)'),
                        backgroundColor: AppColors.surfaceOf(context),
                        side: BorderSide(color: AppColors.borderOf(context)),
                        onPressed: () => _seleccionarCuenta('guillermo1234', 'Base22SW42'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.person_outline, size: 16, color: AppColors.brand),
                        label: const Text('Joseph (2 cursos)'),
                        backgroundColor: AppColors.surfaceOf(context),
                        side: BorderSide(color: AppColors.borderOf(context)),
                        onPressed: () => _seleccionarCuenta('josephr.c27', 'Base22SW41'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.bolt_outlined, size: 16, color: AppColors.riskMedium),
                        label: const Text('Modo Demo'),
                        backgroundColor: AppColors.surfaceOf(context),
                        side: BorderSide(color: AppColors.borderOf(context)),
                        onPressed: () => _seleccionarCuenta('DEMO', 'demo123'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
