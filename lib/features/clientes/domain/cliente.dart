import '../../../core/formato/dias.dart';

enum TipoCliente { fisica, juridica }

enum EstadoProcedimiento { activo, pendiente, cerrado }

class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    this.nifCif,
    required this.tipo,
    this.telefono,
    this.email,
    this.direccion,
    this.resumen,
    this.fechaVencimiento,
    this.notas,
    this.eliminadoEn,
    this.procedimientos = const [],
  });

  final String id;
  final String nombre;
  final String? nifCif;
  final TipoCliente tipo;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? resumen;
  final DateTime? fechaVencimiento;
  final String? notas;

  /// Si no es nulo, el cliente está en la papelera desde esa fecha.
  final DateTime? eliminadoEn;
  final List<Procedimiento> procedimientos;

  /// Urgente si vence en 3 días o menos (o ya ha vencido).
  bool get esUrgente => esUrgenteEn(DateTime.now());

  bool esUrgenteEn(DateTime hoy) =>
      fechaVencimiento != null && diasHasta(fechaVencimiento!, hoy) <= 3;

  /// Solo tiene el nombre (p.ej. dado de alta rápida desde un evento de
  /// agenda): faltan sus datos de contacto por completar.
  bool get datosIncompletos =>
      nifCif == null && telefono == null && email == null && direccion == null;
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

  /// Vencido si tiene fecha meta pasada y sigue sin cerrarse. No cambia
  /// [estado]: es solo un aviso visual para que se revise manualmente.
  bool get vencido => vencidoEn(DateTime.now());

  bool vencidoEn(DateTime hoy) =>
      fechaMeta != null &&
      estado != EstadoProcedimiento.cerrado &&
      !esHoyOPosterior(fechaMeta!, hoy);
}
