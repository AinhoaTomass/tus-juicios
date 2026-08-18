import '../domain/cliente.dart';

extension ClienteMapper on Map<String, dynamic> {
  Cliente toCliente() => Cliente(
        id: this['id'] as String,
        nombre: this['nombre'] as String,
        nifCif: this['nif_cif'] as String?,
        tipo: TipoCliente.values.byName(this['tipo'] as String),
        telefono: this['telefono'] as String?,
        email: this['email'] as String?,
        direccion: this['direccion'] as String?,
        resumen: this['resumen'] as String?,
        fechaVencimiento: this['fecha_vencimiento'] == null
            ? null
            : DateTime.parse(this['fecha_vencimiento'] as String),
        notas: this['notas'] as String?,
        eliminadoEn: this['eliminado_en'] == null
            ? null
            : DateTime.parse(this['eliminado_en'] as String),
      );
}

extension ClienteToRow on Cliente {
  Map<String, dynamic> toRow() => {
        'nombre': nombre,
        'nif_cif': nifCif,
        'tipo': tipo.name,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'resumen': resumen,
        'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
        'notas': notas,
      };
}
