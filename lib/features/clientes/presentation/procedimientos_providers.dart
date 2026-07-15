import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/procedimiento_repository_supabase.dart';
import '../domain/cliente.dart';
import '../domain/procedimiento_repository.dart';

part 'procedimientos_providers.g.dart';

@riverpod
ProcedimientoRepository procedimientoRepository(Ref ref) => ProcedimientoRepositorySupabase();

@riverpod
class ProcedimientosDeCliente extends _$ProcedimientosDeCliente {
  @override
  Future<List<Procedimiento>> build(String clienteId) {
    return ref.watch(procedimientoRepositoryProvider).obtenerProcedimientosDeCliente(clienteId);
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(procedimientoRepositoryProvider).obtenerProcedimientosDeCliente(clienteId),
    );
  }
}

@riverpod
Future<Procedimiento> procedimientoPorId(Ref ref, String clienteId, String procedimientoId) async {
  final lista = await ref.watch(procedimientosDeClienteProvider(clienteId).future);
  return lista.firstWhere((p) => p.id == procedimientoId);
}
