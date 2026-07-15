import 'factura.dart';

abstract class FacturaRepository {
  Future<List<Factura>> obtenerFacturas();
  Future<Factura> crearFactura(Factura factura);
  Future<Factura> actualizarFactura(Factura factura);
  Future<void> eliminarFactura(String id);
}
