import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/documento.dart';
import '../domain/documento_repository.dart';
import 'documento_mapper.dart';

class DocumentoRepositorySupabase implements DocumentoRepository {
  DocumentoRepositorySupabase({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;
  static const _bucket = 'documentos';

  @override
  Future<List<Documento>> obtenerDocumentosDeCliente(String clienteId) async {
    final rows = await _client
        .from('documentos')
        .select()
        .eq('cliente_id', clienteId)
        .isFilter('procedimiento_id', null)
        .order('fecha_subida', ascending: false);
    return rows.map((row) => row.toDocumento()).toList();
  }

  @override
  Future<List<Documento>> obtenerDocumentosDeProcedimiento(String procedimientoId) async {
    // Ascendente: la línea de tiempo del procedimiento se lee del más
    // antiguo al más reciente.
    final rows = await _client
        .from('documentos')
        .select()
        .eq('procedimiento_id', procedimientoId)
        .order('fecha_subida', ascending: true);
    return rows.map((row) => row.toDocumento()).toList();
  }

  @override
  Future<Documento> subirDocumento({
    required String clienteId,
    required String nombreArchivo,
    required Uint8List bytes,
    required DateTime fecha,
    String? procedimientoId,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final nombreSaneado = _sanearNombreParaStorage(nombreArchivo);
    final path = '$userId/$clienteId/${DateTime.now().millisecondsSinceEpoch}_$nombreSaneado';

    await _client.storage.from(_bucket).uploadBinary(path, bytes);
    final row = await _client
        .from('documentos')
        .insert({
          'cliente_id': clienteId,
          'procedimiento_id': procedimientoId,
          'nombre_archivo': nombreArchivo,
          'storage_path': path,
          'fecha_subida': fecha.toIso8601String(),
        })
        .select()
        .single();
    return row.toDocumento();
  }

  @override
  Future<String> obtenerUrlDescarga(Documento documento) {
    return _client.storage.from(_bucket).createSignedUrl(documento.storagePath, 60 * 5);
  }

  @override
  Future<void> eliminarDocumento(Documento documento) async {
    await _client.storage.from(_bucket).remove([documento.storagePath]);
    await _client.from('documentos').delete().eq('id', documento.id);
  }
}

const _acentosATexto = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'Á': 'A', 'À': 'A', 'Ä': 'A', 'Â': 'A',
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e', 'É': 'E', 'È': 'E', 'Ë': 'E', 'Ê': 'E',
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', 'Í': 'I', 'Ì': 'I', 'Ï': 'I', 'Î': 'I',
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'Ó': 'O', 'Ò': 'O', 'Ö': 'O', 'Ô': 'O',
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', 'Ú': 'U', 'Ù': 'U', 'Ü': 'U', 'Û': 'U',
  'ñ': 'n', 'Ñ': 'N', 'ç': 'c', 'Ç': 'C',
};

/// Las claves de Supabase Storage rechazan acentos y otros caracteres fuera
/// de ASCII (error `InvalidKey`), así que el nombre de archivo original se
/// transcribe a un formato seguro solo para la ruta de almacenamiento.
String _sanearNombreParaStorage(String nombreArchivo) {
  final sinAcentos = nombreArchivo.split('').map((c) => _acentosATexto[c] ?? c).join();
  return sinAcentos
      .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
      .replaceAll(RegExp(r'_+'), '_');
}
