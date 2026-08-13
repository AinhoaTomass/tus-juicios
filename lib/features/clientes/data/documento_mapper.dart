import '../domain/documento.dart';

extension DocumentoMapper on Map<String, dynamic> {
  Documento toDocumento() => Documento(
        id: this['id'] as String,
        clienteId: this['cliente_id'] as String,
        nombreArchivo: this['nombre_archivo'] as String,
        storagePath: this['storage_path'] as String,
        fechaSubida: DateTime.parse(this['fecha_subida'] as String),
        procedimientoId: this['procedimiento_id'] as String?,
        procedimientoNombre: (this['procedimientos'] as Map<String, dynamic>?)?['nombre'] as String?,
      );
}
