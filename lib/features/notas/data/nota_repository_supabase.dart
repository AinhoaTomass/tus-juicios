import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/nota.dart';
import '../domain/nota_repository.dart';
import 'nota_mapper.dart';

class NotaRepositorySupabase implements NotaRepository {
  NotaRepositorySupabase({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  @override
  Future<List<Nota>> obtenerNotas() async {
    final rows = await _client
        .from('notas')
        .select('*, clientes(nombre)')
        .order('fecha', ascending: false);
    return rows.map((row) => row.toNota()).toList();
  }

  @override
  Future<List<Nota>> obtenerNotasDeCliente(String clienteId) async {
    final rows = await _client
        .from('notas')
        .select()
        .eq('cliente_id', clienteId)
        .order('fecha', ascending: false);
    return rows.map((row) => row.toNota()).toList();
  }

  @override
  Future<Nota> crearNota(Nota nota) async {
    final row = await _client.from('notas').insert(nota.toRow()).select().single();
    return row.toNota();
  }

  @override
  Future<Nota> actualizarNota(Nota nota) async {
    final row = await _client
        .from('notas')
        .update(nota.toRow())
        .eq('id', nota.id)
        .select()
        .single();
    return row.toNota();
  }

  @override
  Future<void> eliminarNota(String id) {
    return _client.from('notas').delete().eq('id', id);
  }
}
