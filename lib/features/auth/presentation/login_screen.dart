import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/inactividad.dart';
import '../../../core/network/supabase_client.dart';

const _claveUltimoEmail = 'ultimo_email';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _cargando = false;
  String? _error;
  String? _aviso;

  @override
  void initState() {
    super.initState();
    if (sesionCerradaPorInactividad.value) {
      _aviso = 'Sesión cerrada por inactividad';
      sesionCerradaPorInactividad.value = false;
    }
    _cargarUltimoEmail();
  }

  Future<void> _cargarUltimoEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_claveUltimoEmail);
    if (email == null || !mounted || _emailCtrl.text.isNotEmpty) return;
    _emailCtrl.text = email;
    _passwordFocus.requestFocus();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final email = _emailCtrl.text.trim();
      await supabase.auth.signInWithPassword(
        email: email,
        password: _passwordCtrl.text,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_claveUltimoEmail, email);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _recuperarContrasena() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) =>
          _DialogRecuperarContrasena(emailInicial: _emailCtrl.text.trim()),
    );
    if (email == null || email.isEmpty || !mounted) return;

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        // En web se vuelve a la raíz de la app (p. ej. .../tus-juicios/ en
        // GitHub Pages, no a la raíz del dominio). Supabase abre allí la
        // sesión temporal y emite `passwordRecovery`, y el router lleva a la
        // pantalla de nueva contraseña.
        redirectTo: kIsWeb
            ? Uri.base.resolve('.').toString()
            : 'tusjuicios://reset-password',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Te hemos enviado un email para restablecer la contraseña',
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'TusJuicios',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (_aviso != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _aviso!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Obligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    focusNode: _passwordFocus,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Obligatorio' : null,
                    onFieldSubmitted: (_) => _iniciarSesion(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _cargando ? null : _iniciarSesion,
                    child: _cargando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _cargando ? null : _recuperarContrasena,
                    child: const Text('¿Olvidaste tu contraseña?'),
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

class _DialogRecuperarContrasena extends StatefulWidget {
  const _DialogRecuperarContrasena({required this.emailInicial});

  final String emailInicial;

  @override
  State<_DialogRecuperarContrasena> createState() =>
      _DialogRecuperarContrasenaState();
}

class _DialogRecuperarContrasenaState
    extends State<_DialogRecuperarContrasena> {
  late final _emailCtrl = TextEditingController(text: widget.emailInicial);

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar contraseña'),
      content: TextField(
        controller: _emailCtrl,
        decoration: const InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_emailCtrl.text.trim()),
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
