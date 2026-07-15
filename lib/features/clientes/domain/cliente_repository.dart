import 'cliente.dart';

abstract class ClienteRepository {
  Future<List<Cliente>> obtenerClientes();
  Future<Cliente> obtenerClientePorId(String id);
  Future<Cliente> crearCliente(Cliente cliente);
  Future<Cliente> actualizarCliente(Cliente cliente);
  Future<void> eliminarCliente(String id);
}
