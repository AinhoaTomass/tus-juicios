import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import 'notas_providers.dart';

class NotasScreen extends ConsumerWidget {
  const NotasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notasAsync = ref.watch(notasListaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notas')),
      body: notasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar notas: $error')),
        data: (notas) {
          return RefreshIndicator(
            onRefresh: () => ref.read(notasListaProvider.notifier).refrescar(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (notas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Todavía no hay notas.')),
                  )
                else
                  ...notas.map(
                    (nota) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HairlineCard(
                        onTap: () => context.go('/notas/${nota.id}/editar'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('d MMM', 'es_ES').format(nota.fecha).toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(color: AppTheme.of(context).accent),
                                ),
                                if (nota.clienteNombre != null)
                                  EstadoChip(label: nota.clienteNombre!),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(nota.titulo, style: Theme.of(context).textTheme.titleMedium),
                            if (nota.contenido != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                nota.contenido!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/notas/nuevo'),
                  child: const Text('Nueva nota'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
