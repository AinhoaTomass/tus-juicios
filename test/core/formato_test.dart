import 'package:flutter_test/flutter_test.dart';
import 'package:tusjuicios/core/formato/dias.dart';
import 'package:tusjuicios/core/formato/fechas.dart';
import 'package:tusjuicios/core/formato/importe.dart';

void main() {
  group('formatearImporte', () {
    test('usa punto de miles, coma decimal y € detrás', () {
      expect(formatearImporte(1234.5), '1.234,50 €');
      expect(formatearImporte(950), '950,00 €');
    });

    test('sin decimales redondea a euros', () {
      expect(formatearImporte(1234.5, decimales: false), '1.235 €');
    });
  });

  group('fechas para Supabase', () {
    test('una columna date se envía como día, sin hora', () {
      expect(fechaParaBd(DateTime(2026, 3, 5, 23, 59)), '2026-03-05');
    });

    test('una columna date se lee como medianoche local de ese día', () {
      final fecha = leerFecha('2026-03-05');
      expect(fecha, DateTime(2026, 3, 5));
      expect(fecha.isUtc, isFalse);
    });

    test('un instante se envía en UTC y se lee en hora local', () {
      final instante = DateTime(2026, 10, 13, 23, 30);
      final enviado = instanteParaBd(instante);
      expect(enviado, endsWith('Z'));
      expect(leerInstante(enviado), instante);
    });
  });

  group('días', () {
    final hoy = DateTime(2026, 10, 13, 18, 45);

    test('lo de hoy no cuenta como pasado aunque sea antes de la hora actual', () {
      expect(esHoyOPosterior(DateTime(2026, 10, 13), hoy), isTrue);
      expect(esHoyOPosterior(DateTime(2026, 10, 12), hoy), isFalse);
    });

    test('próximos 7 días incluye hoy y el séptimo día', () {
      expect(estaEnLosProximosDias(DateTime(2026, 10, 13), hoy, 7), isTrue);
      expect(estaEnLosProximosDias(DateTime(2026, 10, 20), hoy, 7), isTrue);
      expect(estaEnLosProximosDias(DateTime(2026, 10, 21), hoy, 7), isFalse);
      expect(estaEnLosProximosDias(DateTime(2026, 10, 12), hoy, 7), isFalse);
    });

    test('diasHasta no pierde un día al cruzar el cambio de hora', () {
      // En España la hora cambia el último domingo de octubre (25/10/2026).
      expect(diasHasta(DateTime(2026, 10, 26), DateTime(2026, 10, 24, 12)), 2);
      expect(diasHasta(DateTime(2026, 10, 10), hoy), -3);
    });
  });
}
