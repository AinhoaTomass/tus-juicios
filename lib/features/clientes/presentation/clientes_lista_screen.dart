import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import 'clientes_providers.dart';

class ClientesListaScreen extends ConsumerWidget {
  const ClientesListaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesListaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/clientes/nuevo'),
        child: const Icon(Icons.add),
      ),
      body: clientesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar clientes: $error')),
        data: (clientes) {
          if (clientes.isEmpty) {
            return const Center(child: Text('Todavía no hay clientes.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(clientesListaProvider.notifier).refrescar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: clientes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cliente = clientes[index];
                return HairlineCard(
                  onTap: () => context.go('/clientes/${cliente.id}'),
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
                      if (cliente.esUrgente)
                        const EstadoChip(label: 'Urgente', tono: EstadoTono.urgente),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
