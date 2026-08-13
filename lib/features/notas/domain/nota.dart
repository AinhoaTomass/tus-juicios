class Nota {
  const Nota({
    required this.id,
    required this.titulo,
    required this.fecha,
    this.contenido,
    this.clienteId,
    this.clienteNombre,
  });

  final String id;
  final String titulo;
  final DateTime fecha;
  final String? contenido;

  /// Nulo si es una nota general, no ligada a ningún cliente.
  final String? clienteId;

  /// Solo relleno al leer (join con clientes); no se persiste.
  final String? clienteNombre;
}
