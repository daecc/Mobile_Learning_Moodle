import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'courses_screen.dart';
import 'main_navigation_screen.dart';

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
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
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

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Fondo azul superior con degradado, brillos y bordes curvos
            Container(
              width: double.infinity,
              height: 350,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D2167),
                    Color(0xFF173899),
                    Color(0xFF2457D6),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(38),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(38),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo grande difuminado arriba a la derecha
                    Positioned(
                      top: -45,
                      right: -35,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.lightBlueAccent.withValues(alpha: 0.28),
                              Colors.lightBlueAccent.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Círculo grande difuminado a la izquierda
                    Positioned(
                      top: 10,
                      left: -55,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.blueAccent.withValues(alpha: 0.25),
                              Colors.blueAccent.withValues(alpha: 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Brillo suave abajo a la derecha
                    Positioned(
                      bottom: -30,
                      right: -20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF60A5FA).withValues(alpha: 0.30),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Resplandor radial central detrás del globo/birrete
                    Positioned(
                      top: 25,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.28),
                              const Color(0xFF60A5FA).withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Esferas / partículas decorativas (bokeh)
                    Positioned(
                      top: 120,
                      left: 55,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyanAccent.withValues(alpha: 0.35),
                              Colors.blue.withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 68,
                      right: 95,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.lightBlueAccent.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 86,
                      right: 68,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.lightBlueAccent.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 95,
                      left: 78,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido principal
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo e Identidad Institucional (Animación Lottie)
                      Center(
                        child: SizedBox(
                          width: 220,
                          height: 220,
                          child: Lottie.asset(
                            'assets/animations/login_amimation.json',
                            fit: BoxFit.contain,
                            repeat: true,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 76,
                                height: 76,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const Text(
                        'Rumbo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Tarjeta del Formulario
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceOf(context),
                          borderRadius: BorderRadius.circular(24),
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
          ],
        ),
      ),
    );
  }
}
