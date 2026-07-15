enum TipoCliente { fisica, juridica }

enum EstadoCliente { activo, pendiente, cerrado }

enum EstadoProcedimiento { activo, pendiente, cerrado }

class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.nifCif,
    required this.tipo,
    required this.estado,
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
  final EstadoCliente estado;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? resumen;
  final DateTime? fechaVencimiento;
  final String? notas;
  final List<Procedimiento> procedimientos;

  /// Urgente si el procedimiento no está cerrado y vence en <=3 días.
  bool get esUrgente {
    if (estado == EstadoCliente.cerrado || fechaVencimiento == null) return false;
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
  });

  final String id;
  final String clienteId;
  final String nombre;
  final EstadoProcedimiento estado;
  final DateTime? fechaMeta;
}
