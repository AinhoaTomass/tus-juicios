import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/evento.dart';
import '../domain/evento_repository.dart';
import 'evento_mapper.dart';

class EventoRepositorySupabase implements EventoRepository {
  EventoRepositorySupabase({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  @override
  Future<List<Evento>> obtenerEventos() async {
    final rows = await _client
        .from('eventos')
        .select('*, clientes(nombre)')
        .order('fecha', ascending: true)
        .order('hora', ascending: true);
    return rows.map((row) => row.toEvento()).toList();
  }

  @override
  Future<Evento> crearEvento(Evento evento) async {
    final row = await _client.from('eventos').insert(evento.toRow()).select().single();
    return row.toEvento();
  }

  @override
  Future<Evento> actualizarEvento(Evento evento) async {
    final row = await _client
        .from('eventos')
        .update(evento.toRow())
        .eq('id', evento.id)
        .select()
        .single();
    return row.toEvento();
  }

  @override
  Future<void> eliminarEvento(String id) {
    return _client.from('eventos').delete().eq('id', id);
  }
}
