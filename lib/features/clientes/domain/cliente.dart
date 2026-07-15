enum TipoCliente { fisica, juridica }

enum EstadoProcedimiento { activo, pendiente, cerrado }

class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.nifCif,
    required this.tipo,
    this.telefono,
    this.email,
    this.direccion,
    this.resumen,
    this.fechaVencimiento,
    this.notas,
    this.procedimientos = const [],
  });

  final String id;
  final String nombre;
  final String nifCif;
  final TipoCliente tipo;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? resumen;
  final DateTime? fechaVencimiento;
  final String? notas;
  final List<Procedimiento> procedimientos;

  /// Urgente si vence en <=3 días.
  bool get esUrgente {
    if (fechaVencimiento == null) return false;
    final dias = fechaVencimiento!.difference(DateTime.now()).inDays;
    return dias <= 3;
  }
}

class Procedimiento {
  const Procedimiento({
    required this.id,
    required this.clienteId,
    required this.nombre,
    required this.estado,
    this.fechaMeta,
    this.clienteNombre,
  });

  final String id;
  final String clienteId;
  final String nombre;
  final EstadoProcedimiento estado;
  final DateTime? fechaMeta;

  /// Solo relleno al leer el listado global (join con clientes); no se persiste.
  final String? clienteNombre;
}
