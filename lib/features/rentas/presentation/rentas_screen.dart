import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/filtro_chips.dart';
import '../../../core/widgets/hairline_card.dart';
import '../../../core/widgets/stat_tile.dart';
import '../data/renta_mapper.dart';
import '../domain/renta.dart';
import 'rentas_providers.dart';

class RentasScreen extends ConsumerStatefulWidget {
  const RentasScreen({super.key});

  @override
  ConsumerState<RentasScreen> createState() => _RentasScreenState();
}

class _RentasScreenState extends ConsumerState<RentasScreen> {
  EstadoRenta? _filtro;

  EstadoTono _tono(EstadoRenta estado) => switch (estado) {
        EstadoRenta.enCurso => EstadoTono.aviso,
        EstadoRenta.presentada => EstadoTono.exito,
        EstadoRenta.pendienteDatos => EstadoTono.urgente,
      };

  @override
  Widget build(BuildContext context) {
    final rentasAsync = ref.watch(rentasListaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rentas')),
      body: rentasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar rentas: $error')),
        data: (rentas) {
          final anio = DateTime.now().year;
          final filtradas =
              _filtro == null ? rentas : rentas.where((r) => r.estado == _filtro).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(rentasListaProvider.notifier).refrescar(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                StatTileGrid(
                  tiles: [
                    StatTile(
                      valor: rentas.where((r) => r.ejercicio == anio).length.toString(),
                      etiqueta: 'Rentas $anio',
                    ),
                    StatTile(
                      valor: rentas
                          .where((r) => r.estado == EstadoRenta.presentada)
                          .length
                          .toString(),
                      etiqueta: 'Presentadas',
                    ),
                    StatTile(
                      valor: rentas
                          .where((r) => r.estado == EstadoRenta.enCurso)
                          .length
                          .toString(),
                      etiqueta: 'En curso',
                    ),
                    StatTile(
                      valor: rentas
                          .where((r) => r.estado == EstadoRenta.pendienteDatos)
                          .length
                          .toString(),
                      etiqueta: 'Pend. de datos',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FiltroChips<EstadoRenta?>(
                  opciones: const [
                    (null, 'Todas'),
                    (EstadoRenta.enCurso, 'En curso'),
                    (EstadoRenta.presentada, 'Presentadas'),
                    (EstadoRenta.pendienteDatos, 'Pend. de datos'),
                  ],
                  seleccion: _filtro,
                  onChanged: (valor) => setState(() => _filtro = valor),
                ),
                const SizedBox(height: 16),
                if (filtradas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No hay rentas en este filtro.')),
                  )
                else
                  ...filtradas.map(
                    (renta) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HairlineCard(
                        onTap: () => context.go('/rentas/${renta.id}/editar'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    renta.clienteNombre ?? 'Cliente',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                EstadoChip(
                                  label: renta.estado.etiqueta,
                                  tono: _tono(renta.estado),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RENTA ${renta.ejercicio}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: AppTheme.accent),
                            ),
                            if (renta.resultado != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Resultado: ${renta.resultado}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            if (renta.fecha != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                '${renta.estado == EstadoRenta.presentada ? 'Presentada' : 'Límite'} '
                                '${renta.fecha!.day}/${renta.fecha!.month}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/rentas/nuevo'),
                  child: const Text('Nueva renta'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
