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

  /// Borrado permanente. Solo se usa desde la papelera.
  Future<void> eliminarCliente(String id);
}
