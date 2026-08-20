import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/contador_badge.dart';
import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import '../../../core/widgets/responsive_content.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../agenda/domain/evento.dart';
import '../../agenda/presentation/eventos_providers.dart';
import '../../clientes/domain/cliente.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../../clientes/presentation/procedimientos_providers.dart';
import '../../facturas/domain/factura.dart';
import '../../facturas/presentation/facturas_providers.dart';

/// Algo próximo que mostrar en Inicio: una cita de agenda o un procedimiento
/// con fecha meta. Unifica ambas fuentes para verlas en una sola lista.
typedef _ItemProximo = ({
  DateTime fecha,
  String cliente,
  String subtitulo,
  String etiqueta,
  EstadoTono tono,
  String ruta,
});

class InicioScreen extends ConsumerStatefulWidget {
  const InicioScreen({super.key});

  @override
  ConsumerState<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends ConsumerState<InicioScreen> {
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  String get _saludo {
    final hora = DateTime.now().hour;
    if (hora < 14) return 'Buenos días';
    if (hora < 21) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String get _fechaHoy {
    final texto = DateFormat("EEEE, d 'de' MMMM", 'es_ES').format(DateTime.now());
    return texto[0].toUpperCase() + texto.substring(1);
  }

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

    // En pantallas anchas estos botones ya están en el panel lateral.
    final ocultarAccionesDeCuenta = MediaQuery.sizeOf(context).width >= anchoPanelLateral;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: ocultarAccionesDeCuenta
            ? null
            : [
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
          Text(_saludo, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 15, color: AppTheme.of(context).mutedInk),
              const SizedBox(width: 6),
              Text(
                _fechaHoy,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.of(context).mutedInk),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
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
              final ahora = DateTime.now();

              final deEventos = eventos.where((e) => !e.fecha.isBefore(ahora)).map<_ItemProximo>(
                    (e) => (
                      fecha: e.fecha,
                      cliente: e.clienteNombre ?? e.descripcion ?? 'Evento personal',
                      subtitulo: '${e.fecha.day}/${e.fecha.month}/${e.fecha.year}'
                          '${e.hora != null ? ' · ${e.hora}' : ''}',
                      etiqueta: e.categoria == CategoriaEvento.despacho ? 'Despacho' : 'Personal',
                      tono: EstadoTono.neutro,
                      ruta: '/agenda/${e.id}/editar',
                    ),
                  );

              final deProcedimientos = (procedimientosAsync.value ?? [])
                  .where(
                    (p) =>
                        p.fechaMeta != null &&
                        p.estado != EstadoProcedimiento.cerrado &&
                        !p.fechaMeta!.isBefore(ahora),
                  )
                  .map<_ItemProximo>(
                    (p) => (
                      fecha: p.fechaMeta!,
                      cliente: p.clienteNombre ?? 'Cliente',
                      subtitulo: '${p.nombre} · vence '
                          '${p.fechaMeta!.day}/${p.fechaMeta!.month}/${p.fechaMeta!.year}',
                      etiqueta: 'Procedimiento',
                      tono: EstadoTono.aviso,
                      ruta: '/clientes/${p.clienteId}/procedimientos/${p.id}/editar',
                    ),
                  );

              final proximos = [...deEventos, ...deProcedimientos].toList()
                ..sort((a, b) => a.fecha.compareTo(b.fecha));

              final texto = _busqueda.trim().toLowerCase();
              final filtrados = texto.isEmpty
                  ? proximos
                  : proximos.where((item) {
                      return item.cliente.toLowerCase().contains(texto) ||
                          item.etiqueta.toLowerCase().contains(texto) ||
                          item.subtitulo.toLowerCase().contains(texto);
                    }).toList();

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
                  TextField(
                    controller: _busquedaCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por cliente o tipo…',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _busqueda = value),
                  ),
                  const SizedBox(height: 12),
                  if (filtrados.isEmpty)
                    const Text('Sin eventos próximos.')
                  else
                    ...filtrados.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HairlineCard(
                          onTap: () => context.go(item.ruta),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.cliente,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      item.subtitulo,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              EstadoChip(label: item.etiqueta, tono: item.tono),
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
