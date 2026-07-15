import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/cliente.dart';
import '../domain/procedimiento_repository.dart';
import 'procedimiento_mapper.dart';

class ProcedimientoRepositorySupabase implements ProcedimientoRepository {
  ProcedimientoRepositorySupabase({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  @override
  Future<List<Procedimiento>> obtenerProcedimientos() async {
    final rows = await _client
        .from('procedimientos')
        .select('*, clientes(nombre)')
        .order('created_at', ascending: false);
    return rows.map((row) => row.toProcedimiento()).toList();
  }

  @override
  Future<List<Procedimiento>> obtenerProcedimientosDeCliente(String clienteId) async {
    final rows = await _client
        .from('procedimientos')
        .select()
        .eq('cliente_id', clienteId)
        .order('created_at');
    return rows.map((row) => row.toProcedimiento()).toList();
  }

  @override
  Future<Procedimiento> crearProcedimiento(Procedimiento procedimiento) async {
    final row =
        await _client.from('procedimientos').insert(procedimiento.toRow()).select().single();
    return row.toProcedimiento();
  }

  @override
  Future<Procedimiento> actualizarProcedimiento(Procedimiento procedimiento) async {
    final row = await _client
        .from('procedimientos')
        .update(procedimiento.toRow())
        .eq('id', procedimiento.id)
        .select()
        .single();
    return row.toProcedimiento();
  }

  @override
  Future<void> eliminarProcedimiento(String id) {
    return _client.from('procedimientos').delete().eq('id', id);
  }
}
