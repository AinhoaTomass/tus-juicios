import 'dart:typed_data';

import 'documento.dart';

abstract class DocumentoRepository {
  /// Solo los documentos generales del cliente (sin procedimiento). Los
  /// ligados a un procedimiento solo aparecen dentro de ese procedimiento.
  Future<List<Documento>> obtenerDocumentosDeCliente(String clienteId);

  Future<List<Documento>> obtenerDocumentosDeProcedimiento(String procedimientoId);

  Future<Documento> subirDocumento({
    required String clienteId,
    required String nombreArchivo,
    required Uint8List bytes,
    required DateTime fecha,
    String? procedimientoId,
  });

  /// URL temporal (5 min) para ver/descargar el documento.
  Future<String> obtenerUrlDescarga(Documento documento);

  Future<void> eliminarDocumento(Documento documento);
}
