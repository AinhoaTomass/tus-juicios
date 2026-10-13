import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/politica_contrasena.dart';

/// Cambio de contraseña con la sesión iniciada. Pide la contraseña actual
/// para que nadie pueda cambiarla con el móvil desbloqueado.
/// Devuelve `true` si se ha cambiado.
class CambiarContrasenaDialog extends StatefulWidget {
  const CambiarContrasenaDialog({super.key});

  @override
  State<CambiarContrasenaDialog> createState() =>
      _CambiarContrasenaDialogState();
}

class _CambiarContrasenaDialogState extends State<CambiarContrasenaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final email = supabase.auth.currentUser?.email;
    if (email == null) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      try {
        await supabase.auth.signInWithPassword(
          email: email,
          password: _actualCtrl.text,
        );
      } on AuthException {
        setState(() => _error = 'La contraseña actual no es correcta');
        return;
      }
      await supabase.auth.updateUser(
        UserAttributes(password: _nuevaCtrl.text),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar contraseña'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _actualCtrl,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                ),
                obscureText: true,
                autofocus: true,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nuevaCtrl,
                autofillHints: const [AutofillHints.newPassword],
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  helperText: ayudaContrasena,
                  helperMaxLines: 2,
                  errorMaxLines: 2,
                ),
                obscureText: true,
                validator: (value) {
                  final error = validarContrasenaNueva(value);
                  if (error != null) return error;
                  if (value == _actualCtrl.text) {
                    return 'Debe ser distinta de la actual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmCtrl,
                autofillHints: const [AutofillHints.newPassword],
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                ),
                obscureText: true,
                validator: (value) => value != _nuevaCtrl.text
                    ? 'Las contraseñas no coinciden'
                    : null,
                onFieldSubmitted: (_) => _guardar(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _cargando ? null : _guardar,
          child: _cargando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
