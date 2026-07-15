import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/renta_repository_supabase.dart';
import '../domain/renta.dart';
import '../domain/renta_repository.dart';

part 'rentas_providers.g.dart';

@riverpod
RentaRepository rentaRepository(Ref ref) => RentaRepositorySupabase();

@riverpod
class RentasLista extends _$RentasLista {
  @override
  Future<List<Renta>> build() {
    return ref.watch(rentaRepositoryProvider).obtenerRentas();
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(rentaRepositoryProvider).obtenerRentas());
  }
}

@riverpod
Future<Renta> rentaPorId(Ref ref, String id) async {
  final lista = await ref.watch(rentasListaProvider.future);
  return lista.firstWhere((r) => r.id == id);
}
