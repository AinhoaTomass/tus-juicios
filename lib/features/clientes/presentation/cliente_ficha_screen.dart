import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import '../../../core/widgets/mostrar_error.dart';
import '../../notas/presentation/notas_providers.dart';
import '../domain/cliente.dart';
import '../domain/contacto.dart';
import 'clientes_providers.dart';
import 'documentos_providers.dart';
import 'procedimientos_providers.dart';
import 'widgets/seccion_documentos.dart';

class ClienteFichaScreen extends ConsumerWidget {
  const ClienteFichaScreen({super.key, required this.clienteId});

  final String clienteId;

  EstadoTono _tonoProcedimiento(EstadoProcedimiento estado) => switch (estado) {
        EstadoProcedimiento.activo => EstadoTono.exito,
        EstadoProcedimiento.pendiente => EstadoTono.aviso,
        EstadoProcedimiento.cerrado => EstadoTono.neutro,
      };

  Future<void> _moverAPapelera(BuildContext context, WidgetRef ref, Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mover a la papelera'),
        content: Text(
          '"${cliente.nombre}" se moverá a la papelera. Podrás restaurarlo desde ahí.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Mover a papelera'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await ref.read(clienteRepositoryProvider).moverAPapelera(cliente.id);
    } catch (error) {
      if (context.mounted) mostrarError(context, 'No se pudo mover a la papelera', error);
      return;
    }
    ref.invalidate(clientesListaProvider);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsync = ref.watch(clientePorIdProvider(clienteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha de cliente'),
        actions: [
          clienteAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => const SizedBox.shrink(),
            data: (cliente) => IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Mover a papelera',
              onPressed: () => _moverAPapelera(context, ref, cliente),
            ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cliente.nombre,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      if (cliente.datosIncompletos) ...[
                        Tooltip(
                          message: 'Faltan datos por completar',
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.of(context).accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (cliente.esUrgente)
                        const EstadoChip(label: 'Urgente', tono: EstadoTono.urgente),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (cliente.nifCif != null) cliente.nifCif!,
                      cliente.tipo == TipoCliente.fisica ? 'FÍSICA' : 'JURÍDICA',
                    ].join(' · '),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: AppTheme.of(context).accentInk),
                  ),
                  if (cliente.resumen != null) ...[
                    const SizedBox(height: 12),
                    Text(cliente.resumen!),
                  ],
                  if (cliente.telefono != null || cliente.email != null) ...[
                    const SizedBox(height: 16),
                    _AccionesContacto(cliente: cliente),
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
                                        Wrap(
                                          spacing: 4,
                                          children: [
                                            if (p.vencido)
                                              const EstadoChip(
                                                label: 'Vencido',
                                                tono: EstadoTono.urgente,
                                              ),
                                            EstadoChip(
                                              label: p.estado.name,
                                              tono: _tonoProcedimiento(p.estado),
                                            ),
                                          ],
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
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) {
                final documentosAsync = ref.watch(documentosDeClienteProvider(clienteId));
                return documentosAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text('Error al cargar documentos: $error'),
                  data: (documentos) => SeccionDocumentos(
                    documentos: documentos,
                    clienteId: clienteId,
                    onCambio: (_) => ref.invalidate(documentosDeClienteProvider(clienteId)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notas', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Nueva nota',
                  onPressed: () => context.go('/clientes/$clienteId/notas/nuevo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final notasAsync = ref.watch(notasDeClienteProvider(clienteId));
                return notasAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text('Error al cargar notas: $error'),
                  data: (notas) {
                    if (notas.isEmpty) {
                      return const Text('Sin notas.');
                    }
                    return Column(
                      children: notas
                          .map(
                            (nota) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: HairlineCard(
                                padding: const EdgeInsets.all(12),
                                onTap: () =>
                                    context.go('/clientes/$clienteId/notas/${nota.id}/editar'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${nota.fecha.day}/${nota.fecha.month}/${nota.fecha.year}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(color: AppTheme.of(context).accentInk),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(nota.titulo, style: Theme.of(context).textTheme.titleSmall),
                                    if (nota.contenido != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        nota.contenido!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                  child: const Text('Nuevo procedimiento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Botones para contactar con el cliente desde su ficha: llamar, email y
/// WhatsApp. Solo aparecen los que tienen dato (teléfono o email).
class _AccionesContacto extends StatelessWidget {
  const _AccionesContacto({required this.cliente});

  final Cliente cliente;

  Future<void> _abrir(BuildContext context, Uri uri, String que) async {
    final messenger = ScaffoldMessenger.of(context);
    var abierto = false;
    try {
      abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!abierto) {
      messenger.showSnackBar(SnackBar(content: Text('No se pudo abrir $que')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final telefono = cliente.telefono;
    final email = cliente.email;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (telefono != null)
          OutlinedButton.icon(
            onPressed: () => _abrir(
              context,
              Uri(scheme: 'tel', path: telefono.replaceAll(RegExp(r'[^0-9+]'), '')),
              'el teléfono',
            ),
            icon: const Icon(Icons.phone_outlined, size: 18),
            label: const Text('Llamar'),
          ),
        if (telefono != null)
          OutlinedButton.icon(
            onPressed: () => _abrir(
              context,
              Uri.https('wa.me', '/${numeroWhatsApp(telefono)}'),
              'WhatsApp',
            ),
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: const Text('WhatsApp'),
          ),
        if (email != null)
          OutlinedButton.icon(
            onPressed: () => _abrir(context, Uri(scheme: 'mailto', path: email), 'el email'),
            icon: const Icon(Icons.email_outlined, size: 18),
            label: const Text('Email'),
          ),
      ],
    );
  }
}
