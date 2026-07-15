import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/evento_repository_supabase.dart';
import '../domain/evento.dart';
import '../domain/evento_repository.dart';

part 'eventos_providers.g.dart';

@riverpod
EventoRepository eventoRepository(Ref ref) => EventoRepositorySupabase();

@riverpod
class EventosLista extends _$EventosLista {
  @override
  Future<List<Evento>> build() {
    return ref.watch(eventoRepositoryProvider).obtenerEventos();
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(eventoRepositoryProvider).obtenerEventos());
  }
}

@riverpod
Future<Evento> eventoPorId(Ref ref, String id) async {
  final lista = await ref.watch(eventosListaProvider.future);
  return lista.firstWhere((e) => e.id == id);
}
