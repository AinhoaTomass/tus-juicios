enum EstadoRenta { enCurso, presentada, pendienteDatos }

class Renta {
  const Renta({
    required this.id,
    required this.clienteId,
    required this.ejercicio,
    required this.estado,
    this.resultado,
    this.fecha,
    this.clienteNombre,
  });

  final String id;
  final String clienteId;
  final int ejercicio;
  final EstadoRenta estado;
  final String? resultado;
  final DateTime? fecha;

  /// Solo relleno al leer (join con clientes); no se persiste.
  final String? clienteNombre;
}
