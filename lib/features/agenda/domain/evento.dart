enum TipoEvento { juicio, smac, conciliacion, otro }

class Evento {
  const Evento({
    required this.id,
    this.clienteId,
    required this.tipo,
    required this.fecha,
    this.hora,
    this.descripcion,
    this.clienteNombre,
  });

  final String id;

  /// Nulo cuando el evento no está vinculado a ningún cliente (p.ej. una cita médica).
  final String? clienteId;
  final TipoEvento tipo;
  final DateTime fecha;

  /// Formato 'HH:mm'.
  final String? hora;
  final String? descripcion;

  /// Solo relleno al leer (join con clientes); no se persiste.
  final String? clienteNombre;
}
