import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import '../domain/cliente.dart';
import 'clientes_providers.dart';
import 'procedimientos_providers.dart';

class ClienteFichaScreen extends ConsumerWidget {
  const ClienteFichaScreen({super.key, required this.clienteId});

  final String clienteId;

  EstadoTono _tonoProcedimiento(EstadoProcedimiento estado) => switch (estado) {
        EstadoProcedimiento.activo => EstadoTono.exito,
        EstadoProcedimiento.pendiente => EstadoTono.aviso,
        EstadoProcedimiento.cerrado => EstadoTono.neutro,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsync = ref.watch(clientePorIdProvider(clienteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha de cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.go('/clientes/$clienteId/editar'),
          ),
        ],
      ),
      body: clienteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar el cliente: $error')),
        data: (cliente) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            HairlineCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cliente.nombre, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(cliente.nifCif, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  if (cliente.esUrgente) ...[
                    const SizedBox(height: 8),
                    const EstadoChip(label: 'Urgente', tono: EstadoTono.urgente),
                  ],
                  if (cliente.resumen != null) ...[
                    const SizedBox(height: 12),
                    Text(cliente.resumen!),
                  ],
                  if (cliente.telefono != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(cliente.telefono!),
                      ],
                    ),
                  ],
                  if (cliente.email != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(cliente.email!),
                      ],
                    ),
                  ],
                  if (cliente.direccion != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(cliente.direccion!)),
                      ],
                    ),
                  ],
                  if (cliente.fechaVencimiento != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Vence: ${cliente.fechaVencimiento!.day}/${cliente.fechaVencimiento!.month}/${cliente.fechaVencimiento!.year}',
                        ),
                      ],
                    ),
                  ],
                  if (cliente.notas != null) ...[
                    const SizedBox(height: 12),
                    Text('Notas', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(cliente.notas!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Procedimientos', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Nuevo procedimiento',
                  onPressed: () => context.go('/clientes/$clienteId/procedimientos/nuevo'),
                ),
              ],
            ),
            Consumer(
              builder: (context, ref, _) {
                final procedimientosAsync = ref.watch(procedimientosDeClienteProvider(clienteId));
                return procedimientosAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text('Error al cargar procedimientos: $error'),
                  data: (procedimientos) {
                    if (procedimientos.isEmpty) {
                      return const Text('Sin procedimientos registrados.');
                    }
                    return Column(
                      children: procedimientos
                          .map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: HairlineCard(
                                padding: const EdgeInsets.all(12),
                                onTap: () => context.go(
                                  '/clientes/$clienteId/procedimientos/${p.id}/editar',
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(p.nombre)),
                                    EstadoChip(
                                      label: p.estado.name,
                                      tono: _tonoProcedimiento(p.estado),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
