import 'dart:typed_data';

import 'documento.dart';

abstract class DocumentoRepository {
  /// Todos los documentos del cliente, generales y de cualquier procedimiento.
  Future<List<Documento>> obtenerDocumentosDeCliente(String clienteId);

  Future<List<Documento>> obtenerDocumentosDeProcedimiento(String procedimientoId);

  Future<Documento> subirDocumento({
    required String clienteId,
    required String nombreArchivo,
    required Uint8List bytes,
    String? procedimientoId,
  });

  /// URL temporal (5 min) para ver/descargar el documento.
  Future<String> obtenerUrlDescarga(Documento documento);

  Future<void> eliminarDocumento(Documento documento);
}
