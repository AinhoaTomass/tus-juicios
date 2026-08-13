import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/cliente_repository_supabase.dart';
import '../domain/cliente.dart';
import '../domain/cliente_repository.dart';

part 'clientes_providers.g.dart';

@riverpod
ClienteRepository clienteRepository(Ref ref) => ClienteRepositorySupabase();

@riverpod
class ClientesLista extends _$ClientesLista {
  @override
  Future<List<Cliente>> build() {
    return ref.watch(clienteRepositoryProvider).obtenerClientes();
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clienteRepositoryProvider).obtenerClientes(),
    );
  }
}

@riverpod
Future<Cliente> clientePorId(Ref ref, String id) {
  return ref.watch(clienteRepositoryProvider).obtenerClientePorId(id);
}

@riverpod
class ClientesPapelera extends _$ClientesPapelera {
  @override
  Future<List<Cliente>> build() {
    return ref.watch(clienteRepositoryProvider).obtenerClientesEnPapelera();
  }

  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clienteRepositoryProvider).obtenerClientesEnPapelera(),
    );
  }
}
