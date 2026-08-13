import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/filtro_chips.dart';
import '../../../core/widgets/hairline_card.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../ajustes/presentation/ajustes_providers.dart';
import '../data/factura_pdf.dart';
import '../domain/factura.dart';
import 'facturas_providers.dart';

class FacturasScreen extends ConsumerStatefulWidget {
  const FacturasScreen({super.key});

  @override
  ConsumerState<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends ConsumerState<FacturasScreen> {
  EstadoFactura? _filtro;

  EstadoTono _tono(EstadoFactura estado) => switch (estado) {
        EstadoFactura.pendiente => EstadoTono.aviso,
        EstadoFactura.pagada => EstadoTono.exito,
        EstadoFactura.vencida => EstadoTono.urgente,
      };

  Future<void> _verPdf(Factura factura) async {
    final despacho = await ref.read(datosDespachoProvider.future);
    await Printing.layoutPdf(
      name: 'Factura ${factura.numero}',
      onLayout: (_) => generarFacturaPdf(factura, despacho),
    );
  }

  @override
  Widget build(BuildContext context) {
    final facturasAsync = ref.watch(facturasListaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Facturas')),
      body: facturasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar facturas: $error')),
        data: (facturas) {
          final anio = DateTime.now().year;
          final delAnio = facturas.where((f) => f.fecha.year == anio);
          final facturado = delAnio.fold<double>(0, (suma, f) => suma + f.importe);
          final pendienteCobro = facturas
              .where((f) => f.estado == EstadoFactura.pendiente)
              .fold<double>(0, (suma, f) => suma + f.importe);
          final filtradas =
              _filtro == null ? facturas : facturas.where((f) => f.estado == _filtro).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(facturasListaProvider.notifier).refrescar(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                StatTileGrid(
                  tiles: [
                    StatTile(
                      valor: '${facturado.toStringAsFixed(0)} €',
                      etiqueta: 'Facturado $anio',
                    ),
                    StatTile(
                      valor: '${pendienteCobro.toStringAsFixed(0)} €',
                      etiqueta: 'Pendiente de cobro',
                    ),
                    StatTile(
                      valor: facturas
                          .where((f) => f.estado == EstadoFactura.vencida)
                          .length
                          .toString(),
                      etiqueta: 'Vencidas',
                    ),
                    StatTile(
                      valor: facturas.length.toString(),
                      etiqueta: 'Facturas emitidas',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FiltroChips<EstadoFactura?>(
                  opciones: const [
                    (null, 'Todas'),
                    (EstadoFactura.pendiente, 'Pendientes'),
                    (EstadoFactura.pagada, 'Pagadas'),
                    (EstadoFactura.vencida, 'Vencidas'),
                  ],
                  seleccion: _filtro,
                  onChanged: (valor) => setState(() => _filtro = valor),
                ),
                const SizedBox(height: 16),
                if (filtradas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No hay facturas en este filtro.')),
                  )
                else
                  ...filtradas.map(
                    (factura) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HairlineCard(
                        onTap: () => context.go('/facturas/${factura.id}/editar'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${factura.numero} · ${factura.clienteNombre ?? 'Cliente'}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                                  tooltip: 'Ver PDF',
                                  onPressed: () => _verPdf(factura),
                                ),
                                EstadoChip(
                                  label: factura.estado.name,
                                  tono: _tono(factura.estado),
                                ),
                              ],
                            ),
                            if (factura.concepto != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${factura.concepto} · '
                                '${DateFormat('MMMM', 'es_ES').format(factura.fecha)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${factura.importe.toStringAsFixed(2)} €',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  '${factura.fecha.day}/${factura.fecha.month}/${factura.fecha.year}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.go('/facturas/nuevo'),
                  child: const Text('Nueva factura'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
