import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import '../domain/factura.dart';
import 'facturas_providers.dart';

class FacturasScreen extends ConsumerWidget {
  const FacturasScreen({super.key});

  EstadoTono _tono(EstadoFactura estado) => switch (estado) {
        EstadoFactura.pendiente => EstadoTono.aviso,
        EstadoFactura.pagada => EstadoTono.exito,
        EstadoFactura.vencida => EstadoTono.urgente,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facturasAsync = ref.watch(facturasListaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Facturas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/facturas/nuevo'),
        child: const Icon(Icons.add),
      ),
      body: facturasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar facturas: $error')),
        data: (facturas) {
          if (facturas.isEmpty) {
            return const Center(child: Text('Todavía no hay facturas.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(facturasListaProvider.notifier).refrescar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: facturas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final factura = facturas[index];
                return HairlineCard(
                  onTap: () => context.go('/facturas/${factura.id}/editar'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(factura.numero, style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              factura.clienteNombre ?? 'Cliente',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${factura.importe.toStringAsFixed(2)} €'),
                          const SizedBox(height: 4),
                          EstadoChip(label: factura.estado.name, tono: _tono(factura.estado)),
                        ],
                      ),
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
