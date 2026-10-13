import 'factura.dart';

abstract class FacturaRepository {
  Future<List<Factura>> obtenerFacturas();
  Future<Factura> crearFactura(Factura factura);
  Future<Factura> actualizarFactura(Factura factura);

  // Sin eliminarFactura a propósito: las facturas emitidas deben
  // conservarse y la base de datos rechaza cualquier borrado. Si una está
  // mal, se emite una rectificativa.
}
