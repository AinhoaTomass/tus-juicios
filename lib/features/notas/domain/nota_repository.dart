import 'nota.dart';

abstract class NotaRepository {
  Future<List<Nota>> obtenerNotas();
  Future<Nota> crearNota(Nota nota);
  Future<Nota> actualizarNota(Nota nota);
  Future<void> eliminarNota(String id);
}
