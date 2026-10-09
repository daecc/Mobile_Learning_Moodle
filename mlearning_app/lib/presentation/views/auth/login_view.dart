import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mlearning_early_warning/presentation/viewmodels/auth/auth_provider.dart';
import 'package:mlearning_early_warning/core/theme/app_theme.dart';

/// Pantalla de Login / Inicio de Sesión Institucional.
///
/// Características:
/// - Formulario validado (código universitario + contraseña)
/// - Estados: loading, error, success
/// - Branding universitario
/// - Navegación automática a Dashboard tras login exitoso
/// - Accesibilidad: labels, hints, orden de foco
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Escuchar cambios de estado para navegación
    // (En producción usar GoRouter o navigatorKey global)
    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildForm(context, authProvider),
                  const SizedBox(height: 24),
                  _buildLoginButton(context, authProvider),
                  const SizedBox(height: 16),
                  _buildHelpText(context),
                  const SizedBox(height: 24),
                  _buildDemoCredentials(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header con logo y título
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Logo / Icono de la app
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'M-Learning Early Warning',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurfaceColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sistema de Alerta Temprana Académica',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariantColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Ingresa con tus credenciales institucionales',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariantColor.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Formulario de login
  Widget _buildForm(BuildContext context, AuthProvider authProvider) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.outlineColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo: Código universitario / Email
              TextFormField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                decoration: InputDecoration(
                  labelText: 'Código universitario o Email',
                  hintText: 'Ej: 20210001 o juan.perez@universidad.edu.pe',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu código universitario o email';
                  }
                  if (value.trim().length < 3) {
                    return 'Código muy corto';
                  }
                  return null;
                },
                autofillHints: const [AutofillHints.username, AutofillHints.email],
              ),
              const SizedBox(height: 16),

              // Campo: Contraseña
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingresa tu contraseña',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    tooltip: _obscurePassword ? 'Mostrar' : 'Ocultar',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(authProvider),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  if (value.length < 4) {
                    return 'Contraseña muy corta';
                  }
                  return null;
                },
                autofillHints: const [AutofillHints.password],
              ),
              const SizedBox(height: 12),

              // Row: Remember me + Forgot password
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) =>
                        setState(() => _rememberMe = value ?? false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text('Recordarme'),
                  const Spacer(),
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ],
              ),

              // Mensaje de error
              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Botón principal de login
  Widget _buildLoginButton(BuildContext context, AuthProvider authProvider) {
    return FilledButton(
      onPressed: authProvider.isLoading ? null : () => _handleLogin(authProvider),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.onPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: authProvider.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// Texto de ayuda inferior
  Widget _buildHelpText(BuildContext context) {
    return Text(
      '¿Problemas para acceder? Contacta a soporte TI: soporte@universidad.edu.pe',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.onSurfaceVariantColor.withValues(alpha: 0.6),
          ),
      textAlign: TextAlign.center,
    );
  }

  /// Credenciales de demo (solo desarrollo)
  Widget _buildDemoCredentials(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Credenciales de prueba (Demo)',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DemoCredentialRow(
            label: 'Estudiante 1',
            username: '20210001',
            password: '123456',
            onTap: () => _fillCredentials('20210001', '123456'),
          ),
          const SizedBox(height: 8),
          _DemoCredentialRow(
            label: 'Estudiante 2',
            username: '20210002',
            password: '123456',
            onTap: () => _fillCredentials('20210002', '123456'),
          ),
          const SizedBox(height: 8),
          _DemoCredentialRow(
            label: 'Estudiante 3',
            username: '20210003',
            password: '123456',
            onTap: () => _fillCredentials('20210003', '123456'),
          ),
        ],
      ),
    );
  }

  void _fillCredentials(String username, String password) {
    _usernameController.text = username;
    _passwordController.text = password;
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final success = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Navegación la maneja el listener en build()
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: const Text(
          'Para restablecer tu contraseña, contacta a la mesa de ayuda:\n\n'
          '📧 soporte@universidad.edu.pe\n'
          '📞 +51 1 234-5678\n\n'
          'O visita la oficina de Sistemas en el campus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

/// Fila de credenciales demo clickeable
class _DemoCredentialRow extends StatelessWidget {
  final String label;
  final String username;
  final String password;
  final VoidCallback onTap;

  const _DemoCredentialRow({
    required this.label,
    required this.username,
    required this.password,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label: $username',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: AppTheme.onSurfaceVariantColor,
                    ),
              ),
            ),
            Icon(
              Icons.touch_app_rounded,
              size: 16,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}