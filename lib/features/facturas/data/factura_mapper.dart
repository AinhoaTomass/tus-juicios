import '../domain/factura.dart';

extension FacturaMapper on Map<String, dynamic> {
  Factura toFactura() => Factura(
        id: this['id'] as String,
        numero: this['numero'] as String,
        clienteId: this['cliente_id'] as String,
        importe: (this['importe'] as num).toDouble(),
        estado: EstadoFactura.values.byName(this['estado'] as String),
        fecha: DateTime.parse(this['fecha'] as String),
        concepto: this['concepto'] as String?,
        clienteNombre: (this['clientes'] as Map<String, dynamic>?)?['nombre'] as String?,
        clienteNifCif: (this['clientes'] as Map<String, dynamic>?)?['nif_cif'] as String?,
        clienteDireccion: (this['clientes'] as Map<String, dynamic>?)?['direccion'] as String?,
      );
}

extension FacturaToRow on Factura {
  Map<String, dynamic> toRow() => {
        'numero': numero,
        'cliente_id': clienteId,
        'importe': importe,
        'estado': estado.name,
        'fecha': fecha.toIso8601String(),
        'concepto': concepto,
      };
}
