enum TipoEvento { juicio, smac, conciliacion, otro }

enum CategoriaEvento { despacho, personal }

class Evento {
  const Evento({
    required this.id,
    this.clienteId,
    required this.categoria,
    required this.tipo,
    required this.fecha,
    this.hora,
    this.descripcion,
    this.clienteNombre,
  });

  final String id;

  /// Nulo cuando el evento no está vinculado a ningún cliente dado de alta
  /// (evento personal, o de despacho con un abogado u otro contacto libre).
  final String? clienteId;
  final CategoriaEvento categoria;
  final TipoEvento tipo;
  final DateTime fecha;

  /// Formato 'HH:mm'.
  final String? hora;
  final String? descripcion;

  /// Solo relleno al leer (join con clientes); no se persiste.
  final String? clienteNombre;
}
