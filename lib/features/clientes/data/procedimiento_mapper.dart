import '../domain/cliente.dart';

extension ProcedimientoMapper on Map<String, dynamic> {
  Procedimiento toProcedimiento() => Procedimiento(
        id: this['id'] as String,
        clienteId: this['cliente_id'] as String,
        nombre: this['nombre'] as String,
        estado: EstadoProcedimiento.values.byName(this['estado'] as String),
        fechaMeta:
            this['fecha_meta'] == null ? null : DateTime.parse(this['fecha_meta'] as String),
        clienteNombre: (this['clientes'] as Map<String, dynamic>?)?['nombre'] as String?,
      );
}

extension ProcedimientoToRow on Procedimiento {
  Map<String, dynamic> toRow() => {
        'cliente_id': clienteId,
        'nombre': nombre,
        'estado': estado.name,
        'fecha_meta': fechaMeta?.toIso8601String(),
      };
}
