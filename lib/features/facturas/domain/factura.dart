enum EstadoFactura { pendiente, pagada, vencida }

class Factura {
  const Factura({
    required this.id,
    required this.numero,
    required this.clienteId,
    required this.importe,
    required this.estado,
    required this.fecha,
    this.concepto,
    this.clienteNombre,
  });

  final String id;
  final String numero;
  final String clienteId;
  final double importe;
  final EstadoFactura estado;
  final DateTime fecha;
  final String? concepto;

  /// Solo relleno al leer (join con clientes); no se persiste.
  final String? clienteNombre;
}
