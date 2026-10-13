import 'package:flutter_test/flutter_test.dart';
import 'package:tusjuicios/features/facturas/data/factura_mapper.dart';
import 'package:tusjuicios/features/facturas/domain/factura.dart';
import 'package:tusjuicios/features/facturas/domain/totales_facturas.dart';

Factura _factura(double importe, EstadoFactura estado, DateTime fecha, {String numero = ''}) =>
    Factura(
      id: '',
      numero: numero,
      clienteId: 'c',
      importe: importe,
      estado: estado,
      fecha: fecha,
    );

void main() {
  final facturas = [
    _factura(100, EstadoFactura.pagada, DateTime(2026, 10, 2)),
    _factura(50, EstadoFactura.pagada, DateTime(2026, 9, 30)),
    _factura(30, EstadoFactura.pendiente, DateTime(2026, 10, 5)),
    _factura(20, EstadoFactura.vencida, DateTime(2025, 12, 1)),
  ];

  test('cobrado en el mes solo cuenta pagadas de ese mes', () {
    expect(cobradoEnMes(facturas, DateTime(2026, 10, 13)), 100);
  });

  test('pendiente de cobro incluye pendientes y vencidas', () {
    expect(pendienteDeCobro(facturas), 50);
  });

  test('facturado en el año cuenta todas las del año', () {
    expect(facturadoEnAnio(facturas, 2026), 180);
  });

  group('toRow', () {
    test('al dar de alta no envía número: lo asigna la base de datos', () {
      final row = _factura(10, EstadoFactura.pendiente, DateTime(2026, 10, 13, 18)).toRow();
      expect(row.containsKey('numero'), isFalse);
      expect(row['fecha'], '2026-10-13');
    });

    test('al editar mantiene el número', () {
      final row = _factura(10, EstadoFactura.pendiente, DateTime(2026, 10, 13), numero: '2026/004')
          .toRow();
      expect(row['numero'], '2026/004');
    });
  });
}
