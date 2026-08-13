import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/documento_repository_supabase.dart';
import '../domain/documento.dart';
import '../domain/documento_repository.dart';

part 'documentos_providers.g.dart';

@riverpod
DocumentoRepository documentoRepository(Ref ref) => DocumentoRepositorySupabase();

@riverpod
class DocumentosDeCliente extends _$DocumentosDeCliente {
  @override
  Future<List<Documento>> build(String clienteId) {
    return ref.watch(documentoRepositoryProvider).obtenerDocumentosDeCliente(clienteId);
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(documentoRepositoryProvider).obtenerDocumentosDeCliente(clienteId),
    );
  }
}

@riverpod
class DocumentosDeProcedimiento extends _$DocumentosDeProcedimiento {
  @override
  Future<List<Documento>> build(String procedimientoId) {
    return ref.watch(documentoRepositoryProvider).obtenerDocumentosDeProcedimiento(procedimientoId);
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(documentoRepositoryProvider).obtenerDocumentosDeProcedimiento(procedimientoId),
    );
  }
}
