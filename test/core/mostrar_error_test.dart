import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tusjuicios/core/widgets/mostrar_error.dart';

void main() {
  test('los fallos de red dan un único mensaje comprensible', () {
    expect(
      describirError(Exception('ClientException: Failed host lookup: x.supabase.co')),
      'Sin conexión: comprueba internet e inténtalo de nuevo.',
    );
  });

  test('de los errores de Supabase se muestra solo el mensaje', () {
    expect(
      describirError(const PostgrestException(message: 'duplicate key', code: '23505')),
      'duplicate key',
    );
  });
}
