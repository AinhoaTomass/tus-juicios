import 'cliente.dart';

abstract class ClienteRepository {
  /// Solo clientes activos (no en papelera).
  Future<List<Cliente>> obtenerClientes();
  Future<Cliente> obtenerClientePorId(String id);
  Future<Cliente> crearCliente(Cliente cliente);
  Future<Cliente> actualizarCliente(Cliente cliente);

  Future<List<Cliente>> obtenerClientesEnPapelera();
  Future<void> moverAPapelera(String id);
  Future<void> restaurarDePapelera(String id);

  /// Borrado permanente, junto con sus procedimientos, rentas, citas y
  /// documentos (también los archivos). Solo se usa desde la papelera.
  /// Lanza [ClienteConFacturasException] si el cliente tiene facturas.
  Future<void> eliminarCliente(String id);
}

/// Se lanza al intentar eliminar definitivamente un cliente que tiene
/// facturas: las facturas emitidas deben conservarse (y su numeración no
/// puede tener huecos), así que la base de datos no permite borrarlas en
/// cascada con el cliente.
class ClienteConFacturasException implements Exception {
  const ClienteConFacturasException([this.numFacturas]);

  /// Nulo si no se sabe cuántas (la base de datos rechazó el borrado).
  final int? numFacturas;

  @override
  String toString() => switch (numFacturas) {
        1 => 'Tiene 1 factura, y las facturas deben conservarse.',
        null => 'Tiene facturas, y las facturas deben conservarse.',
        final n => 'Tiene $n facturas, y las facturas deben conservarse.',
      };
}
