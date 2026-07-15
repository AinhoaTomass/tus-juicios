import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/factura.dart';
import '../domain/factura_repository.dart';
import 'factura_mapper.dart';

class FacturaRepositorySupabase implements FacturaRepository {
  FacturaRepositorySupabase({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  @override
  Future<List<Factura>> obtenerFacturas() async {
    final rows = await _client
        .from('facturas')
        .select('*, clientes(nombre)')
        .order('fecha', ascending: false);
    return rows.map((row) => row.toFactura()).toList();
  }

  @override
  Future<Factura> crearFactura(Factura factura) async {
    final row = await _client.from('facturas').insert(factura.toRow()).select().single();
    return row.toFactura();
  }

  @override
  Future<Factura> actualizarFactura(Factura factura) async {
    final row = await _client
        .from('facturas')
        .update(factura.toRow())
        .eq('id', factura.id)
        .select()
        .single();
    return row.toFactura();
  }

  @override
  Future<void> eliminarFactura(String id) {
    return _client.from('facturas').delete().eq('id', id);
  }
}
