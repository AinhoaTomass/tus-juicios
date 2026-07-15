enum TipoEvento { juicio, smac, conciliacion }

class Evento {
  const Evento({
    required this.id,
    required this.clienteId,
    required this.tipo,
    required this.fecha,
    this.hora,
    this.descripcion,
    this.clienteNombre,
  });

  final String id;
  final String clienteId;
  final TipoEvento tipo;
  final DateTime fecha;

  /// Formato 'HH:mm'.
  final String? hora;
  final String? descripcion;

  /// Solo relleno al leer (join con clientes); no se persiste.
  final String? clienteNombre;
}
