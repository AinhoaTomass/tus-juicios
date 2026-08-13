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
        .order('fecha_subida');
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
    final path = '$userId/$clienteId/${DateTime.now().millisecondsSinceEpoch}_$nombreArchivo';

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
