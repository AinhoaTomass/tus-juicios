import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Texto legible para el usuario a partir de un error de guardado/borrado.
/// Los fallos de red se agrupan en un único mensaje; los de Supabase
/// muestran su `message` en vez del `toString()` técnico.
String describirError(Object error) {
  final texto = error.toString();
  final esDeRed = texto.contains('SocketException') ||
      texto.contains('ClientException') ||
      texto.contains('Failed host lookup') ||
      texto.contains('XMLHttpRequest');
  if (esDeRed) return 'Sin conexión: comprueba internet e inténtalo de nuevo.';
  return switch (error) {
    PostgrestException(:final message) => message,
    StorageException(:final message) => message,
    AuthException(:final message) => message,
    _ => texto,
  };
}

/// Muestra en un SnackBar que algo ha fallado, p. ej.
/// `mostrarError(context, 'No se pudo guardar el cliente', e)`.
void mostrarError(BuildContext context, String queFallo, Object error) {
  debugPrint('$queFallo: $error');
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$queFallo. ${describirError(error)}')),
  );
}
