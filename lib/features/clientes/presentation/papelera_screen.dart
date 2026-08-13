import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/hairline_card.dart';
import '../domain/cliente.dart';
import 'clientes_providers.dart';

class PapeleraScreen extends ConsumerWidget {
  const PapeleraScreen({super.key});

  Future<void> _restaurar(BuildContext context, WidgetRef ref, Cliente cliente) async {
    await ref.read(clienteRepositoryProvider).restaurarDePapelera(cliente.id);
    ref.invalidate(clientesPapeleraProvider);
    ref.invalidate(clientesListaProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${cliente.nombre} restaurado')));
    }
  }

  Future<void> _eliminarDefinitivamente(BuildContext context, WidgetRef ref, Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar definitivamente'),
        content: Text(
          '"${cliente.nombre}" se borrará para siempre, junto con sus procedimientos y '
          'documentos. Esta acción no se puede deshacer. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    await ref.read(clienteRepositoryProvider).eliminarCliente(cliente.id);
    ref.invalidate(clientesPapeleraProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final papeleraAsync = ref.watch(clientesPapeleraProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Papelera')),
      body: papeleraAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar la papelera: $error')),
        data: (clientes) {
          if (clientes.isEmpty) {
            return const Center(child: Text('La papelera está vacía.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clientes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return HairlineCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cliente.nombre, style: Theme.of(context).textTheme.titleMedium),
                          Text(cliente.nifCif, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.restore_from_trash_outlined),
                      tooltip: 'Restaurar',
                      onPressed: () => _restaurar(context, ref, cliente),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_outlined),
                      tooltip: 'Eliminar definitivamente',
                      onPressed: () => _eliminarDefinitivamente(context, ref, cliente),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
