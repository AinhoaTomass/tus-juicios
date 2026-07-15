import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import '../../agenda/domain/evento.dart';
import '../../agenda/presentation/eventos_providers.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../../clientes/presentation/procedimientos_providers.dart';
import '../../facturas/domain/factura.dart';
import '../../facturas/presentation/facturas_providers.dart';

class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  String _etiquetaTipoEvento(TipoEvento tipo) => switch (tipo) {
        TipoEvento.juicio => 'Juicio',
        TipoEvento.smac => 'SMAC',
        TipoEvento.conciliacion => 'Conciliación',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientesAsync = ref.watch(clientesListaProvider);
    final eventosAsync = ref.watch(eventosListaProvider);
    final facturasAsync = ref.watch(facturasListaProvider);
    final procedimientosAsync = ref.watch(procedimientosListaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => supabase.auth.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Próximos eventos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          eventosAsync.when(
            loading: () => const HairlineCard(child: LinearProgressIndicator()),
            error: (error, _) => HairlineCard(child: Text('Error: $error')),
            data: (eventos) {
              final limite = DateTime.now().add(const Duration(days: 7));
              final proximos = eventos.where((e) => !e.fecha.isAfter(limite)).toList()
                ..sort((a, b) => a.fecha.compareTo(b.fecha));
              if (proximos.isEmpty) {
                return const HairlineCard(child: Text('Sin eventos en los próximos 7 días.'));
              }
              return Column(
                children: proximos
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HairlineCard(
                          padding: const EdgeInsets.all(12),
                          onTap: () => context.go('/agenda/${e.id}/editar'),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.clienteNombre ?? 'Cliente'),
                                    Text(
                                      '${e.fecha.day}/${e.fecha.month}/${e.fecha.year}'
                                      '${e.hora != null ? ' · ${e.hora}' : ''}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              EstadoChip(label: _etiquetaTipoEvento(e.tipo)),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Clientes urgentes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          clientesAsync.when(
            loading: () => const HairlineCard(child: LinearProgressIndicator()),
            error: (error, _) => HairlineCard(child: Text('Error: $error')),
            data: (clientes) {
              final urgentes = clientes.where((c) => c.esUrgente).toList();
              if (urgentes.isEmpty) {
                return const HairlineCard(child: Text('Ningún cliente con vencimiento cercano.'));
              }
              return Column(
                children: urgentes
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HairlineCard(
                          padding: const EdgeInsets.all(12),
                          onTap: () => context.go('/clientes/${c.id}'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(c.nombre)),
                              const EstadoChip(label: 'Urgente', tono: EstadoTono.urgente),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Facturas pendientes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          facturasAsync.when(
            loading: () => const HairlineCard(child: LinearProgressIndicator()),
            error: (error, _) => HairlineCard(child: Text('Error: $error')),
            data: (facturas) {
              final pendientes = facturas
                  .where(
                    (f) => f.estado == EstadoFactura.pendiente || f.estado == EstadoFactura.vencida,
                  )
                  .toList();
              if (pendientes.isEmpty) {
                return const HairlineCard(child: Text('No hay facturas pendientes ni vencidas.'));
              }
              final total = pendientes.fold<double>(0, (suma, f) => suma + f.importe);
              return HairlineCard(
                onTap: () => context.go('/facturas'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${pendientes.length} factura(s) por cobrar'),
                    Text('${total.toStringAsFixed(2)} €'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Procedimientos activos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          procedimientosAsync.when(
            loading: () => const HairlineCard(child: LinearProgressIndicator()),
            error: (error, _) => HairlineCard(child: Text('Error: $error')),
            data: (procedimientos) {
              final activos = procedimientos.where((p) => p.estado.name == 'activo').length;
              return HairlineCard(
                onTap: () => context.push('/procedimientos'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$activos procedimiento(s) activo(s)'),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
