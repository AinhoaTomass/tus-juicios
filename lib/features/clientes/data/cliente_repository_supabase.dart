import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/cliente.dart';
import '../domain/cliente_repository.dart';
import 'cliente_mapper.dart';

class ClienteRepositorySupabase implements ClienteRepository {
  ClienteRepositorySupabase({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  @override
  Future<List<Cliente>> obtenerClientes() async {
    final rows = await _client.from('clientes').select().order('nombre');
    return rows.map((row) => row.toCliente()).toList();
  }

  @override
  Future<Cliente> obtenerClientePorId(String id) async {
    final row = await _client.from('clientes').select().eq('id', id).single();
    return row.toCliente();
  }

  @override
  Future<Cliente> crearCliente(Cliente cliente) async {
    final row = await _client.from('clientes').insert(cliente.toRow()).select().single();
    return row.toCliente();
  }

  @override
  Future<Cliente> actualizarCliente(Cliente cliente) async {
    final row = await _client
        .from('clientes')
        .update(cliente.toRow())
        .eq('id', cliente.id)
        .select()
        .single();
    return row.toCliente();
  }

  @override
  Future<void> eliminarCliente(String id) {
    return _client.from('clientes').delete().eq('id', id);
  }
}
