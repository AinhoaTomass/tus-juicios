import 'package:flutter_test/flutter_test.dart';
import 'package:tusjuicios/features/clientes/domain/cliente.dart';
import 'package:tusjuicios/features/clientes/domain/contacto.dart';

Cliente _cliente({DateTime? vence, String? telefono}) => Cliente(
      id: '1',
      nombre: 'Ana',
      tipo: TipoCliente.fisica,
      fechaVencimiento: vence,
      telefono: telefono,
    );

void main() {
  final hoy = DateTime(2026, 10, 13, 10);

  group('Cliente.esUrgenteEn', () {
    test('urgente si vence en 3 días o menos, o ya venció', () {
      expect(_cliente(vence: DateTime(2026, 10, 16)).esUrgenteEn(hoy), isTrue);
      expect(_cliente(vence: DateTime(2026, 10, 1)).esUrgenteEn(hoy), isTrue);
    });

    test('no urgente a 4 días ni sin fecha', () {
      expect(_cliente(vence: DateTime(2026, 10, 17)).esUrgenteEn(hoy), isFalse);
      expect(_cliente().esUrgenteEn(hoy), isFalse);
    });
  });

  test('datos incompletos si solo tiene el nombre', () {
    expect(_cliente().datosIncompletos, isTrue);
    expect(_cliente(telefono: '600000000').datosIncompletos, isFalse);
  });

  group('Procedimiento.vencidoEn', () {
    Procedimiento proc(DateTime? meta, EstadoProcedimiento estado) => Procedimiento(
          id: 'p',
          clienteId: '1',
          nombre: 'Demanda',
          estado: estado,
          fechaMeta: meta,
        );

    test('vence hoy todavía no está vencido', () {
      expect(proc(DateTime(2026, 10, 13), EstadoProcedimiento.activo).vencidoEn(hoy), isFalse);
      expect(proc(DateTime(2026, 10, 12), EstadoProcedimiento.activo).vencidoEn(hoy), isTrue);
    });

    test('un procedimiento cerrado nunca está vencido', () {
      expect(proc(DateTime(2026, 1, 1), EstadoProcedimiento.cerrado).vencidoEn(hoy), isFalse);
    });
  });

  group('numeroWhatsApp', () {
    test('un móvil español sin prefijo lleva +34', () {
      expect(numeroWhatsApp('600 11 22 33'), '34600112233');
    });

    test('respeta los prefijos internacionales', () {
      expect(numeroWhatsApp('+44 7700 900123'), '447700900123');
      expect(numeroWhatsApp('0034 600112233'), '34600112233');
    });
  });
}
