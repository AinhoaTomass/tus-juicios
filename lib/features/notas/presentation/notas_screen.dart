import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/hairline_card.dart';
import 'notas_providers.dart';

class NotasScreen extends ConsumerWidget {
  const NotasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notasAsync = ref.watch(notasListaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/notas/nuevo'),
        child: const Icon(Icons.add),
      ),
      body: notasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar notas: $error')),
        data: (notas) {
          if (notas.isEmpty) {
            return const Center(child: Text('Todavía no hay notas.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(notasListaProvider.notifier).refrescar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final nota = notas[index];
                return HairlineCard(
                  onTap: () => context.go('/notas/${nota.id}/editar'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nota.titulo, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${nota.fecha.day}/${nota.fecha.month}/${nota.fecha.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (nota.contenido != null) ...[
                        const SizedBox(height: 8),
                        Text(nota.contenido!, maxLines: 3, overflow: TextOverflow.ellipsis),
                      ],
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
