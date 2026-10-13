import 'package:flutter_test/flutter_test.dart';
import 'package:tusjuicios/features/auth/domain/politica_contrasena.dart';

void main() {
  test('acepta una contraseña que cumple todo', () {
    expect(validarContrasenaNueva('Despacho#2026'), isNull);
  });

  test('explica todo lo que falta', () {
    expect(
      validarContrasenaNueva('abc'),
      'Falta: mínimo 10 caracteres, una mayúscula, un número, un símbolo',
    );
  });

  test('exige un símbolo aunque cumpla lo demás', () {
    expect(validarContrasenaNueva('Despacho2026'), 'Falta: un símbolo');
  });

  test('vacía es obligatoria', () {
    expect(validarContrasenaNueva(''), 'Obligatorio');
  });
}
