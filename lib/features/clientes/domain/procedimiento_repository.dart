import 'cliente.dart';

abstract class ProcedimientoRepository {
  Future<List<Procedimiento>> obtenerProcedimientosDeCliente(String clienteId);
  Future<Procedimiento> crearProcedimiento(Procedimiento procedimiento);
  Future<Procedimiento> actualizarProcedimiento(Procedimiento procedimiento);
  Future<void> eliminarProcedimiento(String id);
}
