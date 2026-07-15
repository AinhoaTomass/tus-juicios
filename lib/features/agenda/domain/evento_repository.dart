import 'evento.dart';

abstract class EventoRepository {
  Future<List<Evento>> obtenerEventos();
  Future<Evento> crearEvento(Evento evento);
  Future<Evento> actualizarEvento(Evento evento);
  Future<void> eliminarEvento(String id);
}
