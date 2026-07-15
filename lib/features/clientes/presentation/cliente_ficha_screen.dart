import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
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
      appBar: AppBar(title: const Text('Ficha de cliente')),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cliente.nombre,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      if (cliente.esUrgente)
                        const EstadoChip(label: 'Urgente', tono: EstadoTono.urgente),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cliente.nifCif} · '
                    '${cliente.tipo == TipoCliente.fisica ? 'FÍSICA' : 'JURÍDICA'}',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: AppTheme.accent),
                  ),
                  if (cliente.resumen != null) ...[
                    const SizedBox(height: 12),
                    Text(cliente.resumen!),
                  ],
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  if (cliente.telefono != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(cliente.telefono!),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (cliente.email != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(cliente.email!),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (cliente.direccion != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(cliente.direccion!)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (cliente.fechaVencimiento != null)
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Vence: ${cliente.fechaVencimiento!.day}/${cliente.fechaVencimiento!.month}/${cliente.fechaVencimiento!.year}',
                        ),
                      ],
                    ),
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
            Text('Procedimientos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            p.nombre,
                                            style: Theme.of(context).textTheme.titleSmall,
                                          ),
                                        ),
                                        EstadoChip(
                                          label: p.estado.name,
                                          tono: _tonoProcedimiento(p.estado),
                                        ),
                                      ],
                                    ),
                                    if (p.fechaMeta != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Vence ${p.fechaMeta!.day}/${p.fechaMeta!.month}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/clientes/$clienteId/editar'),
                  child: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.go('/clientes/$clienteId/procedimientos/nuevo'),
                  child: const Text('Nuevo trámite'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
