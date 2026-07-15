import 'renta.dart';

abstract class RentaRepository {
  Future<List<Renta>> obtenerRentas();
  Future<Renta> crearRenta(Renta renta);
  Future<Renta> actualizarRenta(Renta renta);
  Future<void> eliminarRenta(String id);
}
