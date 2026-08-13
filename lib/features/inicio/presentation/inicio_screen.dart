import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/widgets/contador_badge.dart';
import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/filtro_chips.dart';
import '../../../core/widgets/hairline_card.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../agenda/domain/evento.dart';
import '../../agenda/presentation/eventos_providers.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../../clientes/presentation/procedimientos_providers.dart';
import '../../facturas/domain/factura.dart';
import '../../facturas/presentation/facturas_providers.dart';

class InicioScreen extends ConsumerStatefulWidget {
  const InicioScreen({super.key});

  @override
  ConsumerState<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends ConsumerState<InicioScreen> {
  TipoEvento? _filtroTipo;

  String get _saludo {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Hola, buenos días';
    if (hora < 20) return 'Hola, buenas tardes';
    return 'Hola, buenas noches';
  }

  String get _fechaHoy {
    final texto = DateFormat("EEEE, d 'de' MMMM", 'es_ES').format(DateTime.now());
    return texto[0].toUpperCase() + texto.substring(1);
  }

  String _etiquetaTipoEvento(TipoEvento tipo) => switch (tipo) {
        TipoEvento.juicio => 'Juicio',
        TipoEvento.smac => 'SMAC',
        TipoEvento.conciliacion => 'Conciliación',
      };

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesListaProvider);
    final eventosAsync = ref.watch(eventosListaProvider);
    final procedimientosAsync = ref.watch(procedimientosListaProvider);
    final facturasAsync = ref.watch(facturasListaProvider);

    final ahora = DateTime.now();
    final cobradoEsteMes = facturasAsync.value
            ?.where(
              (f) =>
                  f.estado == EstadoFactura.pagada &&
                  f.fecha.year == ahora.year &&
                  f.fecha.month == ahora.month,
            )
            .fold<double>(0, (suma, f) => suma + f.importe) ??
        0;
    final pendienteCobro = facturasAsync.value
            ?.where((f) => f.estado != EstadoFactura.pagada)
            .fold<double>(0, (suma, f) => suma + f.importe) ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
            onPressed: () => context.push('/ajustes'),
          ),
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
          Text(_saludo, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(_fechaHoy, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          StatTileGrid(
            tiles: [
              StatTile(
                valor: clientesAsync.value?.length.toString() ?? '–',
                etiqueta: 'Clientes',
                onTap: () => context.go('/clientes'),
              ),
              StatTile(
                valor: procedimientosAsync.value
                        ?.where((p) => p.estado.name == 'activo')
                        .length
                        .toString() ??
                    '–',
                etiqueta: 'Procedimientos activos',
                onTap: () => context.push('/procedimientos'),
              ),
              StatTile(
                valor: procedimientosAsync.value
                        ?.where((p) => p.estado.name == 'pendiente')
                        .length
                        .toString() ??
                    '–',
                etiqueta: 'Pendientes',
                onTap: () => context.push('/procedimientos'),
              ),
              StatTile(
                valor: eventosAsync.value
                        ?.where(
                          (e) =>
                              !e.fecha.isBefore(DateTime.now()) &&
                              !e.fecha.isAfter(DateTime.now().add(const Duration(days: 7))),
                        )
                        .length
                        .toString() ??
                    '–',
                etiqueta: 'Citas esta semana',
                onTap: () => context.go('/agenda'),
              ),
              StatTile(
                valor: '${cobradoEsteMes.toStringAsFixed(0)} €',
                etiqueta: 'Cobrado este mes',
                onTap: () => context.go('/facturas'),
              ),
              StatTile(
                valor: '${pendienteCobro.toStringAsFixed(0)} €',
                etiqueta: 'Pendiente de cobro',
                onTap: () => context.go('/facturas'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          eventosAsync.when(
            loading: () => const HairlineCard(child: LinearProgressIndicator()),
            error: (error, _) => HairlineCard(child: Text('Error: $error')),
            data: (eventos) {
              final proximos = eventos.where((e) => !e.fecha.isBefore(DateTime.now())).toList()
                ..sort((a, b) => a.fecha.compareTo(b.fecha));
              final filtrados = _filtroTipo == null
                  ? proximos
                  : proximos.where((e) => e.tipo == _filtroTipo).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Próximos eventos', style: Theme.of(context).textTheme.titleMedium),
                      ContadorBadge(valor: proximos.length),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FiltroChips<TipoEvento?>(
                    opciones: [
                      (null, 'Todos'),
                      (TipoEvento.juicio, 'Juicio'),
                      (TipoEvento.smac, 'SMAC'),
                      (TipoEvento.conciliacion, 'Conciliación'),
                    ],
                    seleccion: _filtroTipo,
                    onChanged: (valor) => setState(() => _filtroTipo = valor),
                  ),
                  const SizedBox(height: 12),
                  if (filtrados.isEmpty)
                    const Text('Sin eventos próximos.')
                  else
                    ...filtrados.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HairlineCard(
                          onTap: () => context.go('/agenda/${e.id}/editar'),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.clienteNombre ?? 'Cliente',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
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
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/clientes'),
            child: const Text('Ver todos los clientes'),
          ),
        ],
      ),
    );
  }
}
