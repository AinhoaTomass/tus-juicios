class Nota {
  const Nota({
    required this.id,
    required this.titulo,
    required this.fecha,
    this.contenido,
  });

  final String id;
  final String titulo;
  final DateTime fecha;
  final String? contenido;
}
