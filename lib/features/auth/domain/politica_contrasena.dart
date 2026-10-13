/// Requisitos de contraseña. Deben coincidir con los configurados en
/// Supabase (Authentication → Sign In / Providers → Email): si la app es
/// más permisiva, el usuario escribe una contraseña que "vale" y Supabase
/// la rechaza al guardar.
const longitudMinimaContrasena = 10;

/// Símbolos que Supabase cuenta como símbolo.
const _simbolos = r'''!@#$%^&*()_+-=[]{};'\:"|<>?,./`~''';

const ayudaContrasena =
    'Mínimo $longitudMinimaContrasena caracteres, con mayúsculas, minúsculas, números y símbolos.';

/// Validador para campos de contraseña nueva: `null` si es válida o el
/// motivo por el que no lo es.
String? validarContrasenaNueva(String? valor) {
  if (valor == null || valor.isEmpty) return 'Obligatorio';
  final faltan = [
    if (valor.length < longitudMinimaContrasena) 'mínimo $longitudMinimaContrasena caracteres',
    if (!valor.contains(RegExp('[a-z]'))) 'una minúscula',
    if (!valor.contains(RegExp('[A-Z]'))) 'una mayúscula',
    if (!valor.contains(RegExp('[0-9]'))) 'un número',
    if (!valor.split('').any(_simbolos.contains)) 'un símbolo',
  ];
  if (faltan.isEmpty) return null;
  return 'Falta: ${faltan.join(', ')}';
}
