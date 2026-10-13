import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/formato/fechas.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/cliente.dart';
import '../domain/cliente_repository.dart';
import 'cliente_mapper.dart';

class ClienteRepositorySupabase implements ClienteRepository {
  ClienteRepositorySupabase({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  @override
  Future<List<Cliente>> obtenerClientes() async {
    final rows = await _client
        .from('clientes')
        .select()
        .isFilter('eliminado_en', null)
        .order('nombre', ascending: true);
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
  Future<List<Cliente>> obtenerClientesEnPapelera() async {
    final rows = await _client
        .from('clientes')
        .select()
        .not('eliminado_en', 'is', null)
        .order('eliminado_en', ascending: false);
    return rows.map((row) => row.toCliente()).toList();
  }

  @override
  Future<void> moverAPapelera(String id) {
    return _client
        .from('clientes')
        .update({'eliminado_en': instanteParaBd(DateTime.now())})
        .eq('id', id);
  }

  @override
  Future<void> restaurarDePapelera(String id) {
    return _client.from('clientes').update({'eliminado_en': null}).eq('id', id);
  }

  @override
  Future<void> eliminarCliente(String id) async {
    final facturas = await _client
        .from('facturas')
        .select('id')
        .eq('cliente_id', id)
        .count(CountOption.exact);
    if (facturas.count > 0) throw ClienteConFacturasException(facturas.count);

    // Las filas de `documentos` se borran en cascada con el cliente, pero
    // los archivos de Storage no: hay que guardarse sus rutas antes.
    final documentos = await _client
        .from('documentos')
        .select('storage_path')
        .eq('cliente_id', id);
    final rutas = [for (final d in documentos) d['storage_path'] as String];

    try {
      await _client.from('clientes').delete().eq('id', id);
    } on PostgrestException catch (e) {
      // 23503: violación de clave foránea (facturas creadas entre medias).
      if (e.code == '23503') throw const ClienteConFacturasException();
      rethrow;
    }

    // Storage admite como mucho 1000 rutas por llamada.
    for (var i = 0; i < rutas.length; i += 1000) {
      final lote = rutas.sublist(i, i + 1000 > rutas.length ? rutas.length : i + 1000);
      await _client.storage.from('documentos').remove(lote);
    }
  }
}
