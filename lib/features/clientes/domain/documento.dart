class Documento {
  const Documento({
    required this.id,
    required this.clienteId,
    required this.nombreArchivo,
    required this.storagePath,
    required this.fechaSubida,
    this.procedimientoId,
  });

  final String id;
  final String clienteId;
  final String nombreArchivo;
  final String storagePath;
  final DateTime fechaSubida;

  /// Nulo si el documento es general del cliente, no de un procedimiento concreto.
  final String? procedimientoId;
}
