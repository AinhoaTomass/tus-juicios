import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import '../data/renta_mapper.dart';
import '../domain/renta.dart';
import 'rentas_providers.dart';

class RentasScreen extends ConsumerWidget {
  const RentasScreen({super.key});

  EstadoTono _tono(EstadoRenta estado) => switch (estado) {
        EstadoRenta.enCurso => EstadoTono.aviso,
        EstadoRenta.presentada => EstadoTono.exito,
        EstadoRenta.pendienteDatos => EstadoTono.urgente,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentasAsync = ref.watch(rentasListaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rentas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/rentas/nuevo'),
        child: const Icon(Icons.add),
      ),
      body: rentasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar rentas: $error')),
        data: (rentas) {
          if (rentas.isEmpty) {
            return const Center(child: Text('Todavía no hay rentas registradas.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(rentasListaProvider.notifier).refrescar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rentas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final renta = rentas[index];
                return HairlineCard(
                  onTap: () => context.go('/rentas/${renta.id}/editar'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              renta.clienteNombre ?? 'Cliente',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Ejercicio ${renta.ejercicio}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      EstadoChip(label: renta.estado.etiqueta, tono: _tono(renta.estado)),
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
