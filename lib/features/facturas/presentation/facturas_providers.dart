import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/factura_repository_supabase.dart';
import '../domain/factura.dart';
import '../domain/factura_repository.dart';

part 'facturas_providers.g.dart';

@riverpod
FacturaRepository facturaRepository(Ref ref) => FacturaRepositorySupabase();

@riverpod
class FacturasLista extends _$FacturasLista {
  @override
  Future<List<Factura>> build() {
    return ref.watch(facturaRepositoryProvider).obtenerFacturas();
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(facturaRepositoryProvider).obtenerFacturas());
  }
}

@riverpod
Future<Factura> facturaPorId(Ref ref, String id) async {
  final lista = await ref.watch(facturasListaProvider.future);
  return lista.firstWhere((f) => f.id == id);
}
