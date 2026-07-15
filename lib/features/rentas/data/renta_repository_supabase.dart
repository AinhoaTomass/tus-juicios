import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/renta.dart';
import '../domain/renta_repository.dart';
import 'renta_mapper.dart';

class RentaRepositorySupabase implements RentaRepository {
  RentaRepositorySupabase({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  @override
  Future<List<Renta>> obtenerRentas() async {
    final rows = await _client
        .from('rentas')
        .select('*, clientes(nombre)')
        .order('ejercicio', ascending: false);
    return rows.map((row) => row.toRenta()).toList();
  }

  @override
  Future<Renta> crearRenta(Renta renta) async {
    final row = await _client.from('rentas').insert(renta.toRow()).select().single();
    return row.toRenta();
  }

  @override
  Future<Renta> actualizarRenta(Renta renta) async {
    final row = await _client
        .from('rentas')
        .update(renta.toRow())
        .eq('id', renta.id)
        .select()
        .single();
    return row.toRenta();
  }

  @override
  Future<void> eliminarRenta(String id) {
    return _client.from('rentas').delete().eq('id', id);
  }
}
