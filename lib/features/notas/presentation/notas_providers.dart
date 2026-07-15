import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/nota_repository_supabase.dart';
import '../domain/nota.dart';
import '../domain/nota_repository.dart';

part 'notas_providers.g.dart';

@riverpod
NotaRepository notaRepository(Ref ref) => NotaRepositorySupabase();

@riverpod
class NotasLista extends _$NotasLista {
  @override
  Future<List<Nota>> build() {
    return ref.watch(notaRepositoryProvider).obtenerNotas();
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(notaRepositoryProvider).obtenerNotas());
  }
}

@riverpod
Future<Nota> notaPorId(Ref ref, String id) async {
  final lista = await ref.watch(notasListaProvider.future);
  return lista.firstWhere((n) => n.id == id);
}
