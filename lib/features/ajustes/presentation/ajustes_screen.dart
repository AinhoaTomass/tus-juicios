import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/datos_despacho.dart';
import '../domain/recordatorios_config.dart';
import 'ajustes_providers.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  static const _opcionesDias = [0, 1, 2, 3, 4, 5, 7];

  String _etiquetaDias(int dias) => dias == 0 ? 'El mismo día' : '$dias día(s) antes';

  String _etiquetaHora(int hora) => '${hora.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(recordatoriosConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar ajustes: $error')),
        data: (config) {
          Future<void> actualizar(RecordatoriosConfig nuevo) =>
              ref.read(recordatoriosConfigProvider.notifier).actualizar(nuevo);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Recordatorios', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Avisos locales en este dispositivo. No se envían por email ni SMS.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Citas de agenda'),
                value: config.citasActivo,
                onChanged: (valor) => actualizar(config.copyWith(citasActivo: valor)),
              ),
              if (config.citasActivo) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: config.citasDiasAntes,
                        decoration: const InputDecoration(labelText: 'Avisar'),
                        items: _opcionesDias
                            .map(
                              (dias) =>
                                  DropdownMenuItem(value: dias, child: Text(_etiquetaDias(dias))),
                            )
                            .toList(),
                        onChanged: (dias) {
                          if (dias != null) actualizar(config.copyWith(citasDiasAntes: dias));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: config.citasHora,
                        decoration: const InputDecoration(labelText: 'A las'),
                        items: List.generate(24, (hora) => hora)
                            .map(
                              (hora) =>
                                  DropdownMenuItem(value: hora, child: Text(_etiquetaHora(hora))),
                            )
                            .toList(),
                        onChanged: (hora) {
                          if (hora != null) actualizar(config.copyWith(citasHora: hora));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Procedimientos por vencer'),
                value: config.procedimientosActivo,
                onChanged: (valor) => actualizar(config.copyWith(procedimientosActivo: valor)),
              ),
              if (config.procedimientosActivo)
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: config.procedimientosDiasAntes,
                        decoration: const InputDecoration(labelText: 'Avisar'),
                        items: _opcionesDias
                            .where((dias) => dias > 0)
                            .map(
                              (dias) =>
                                  DropdownMenuItem(value: dias, child: Text(_etiquetaDias(dias))),
                            )
                            .toList(),
                        onChanged: (dias) {
                          if (dias != null) {
                            actualizar(config.copyWith(procedimientosDiasAntes: dias));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: config.procedimientosHora,
                        decoration: const InputDecoration(labelText: 'A las'),
                        items: List.generate(24, (hora) => hora)
                            .map(
                              (hora) =>
                                  DropdownMenuItem(value: hora, child: Text(_etiquetaHora(hora))),
                            )
                            .toList(),
                        onChanged: (hora) {
                          if (hora != null) {
                            actualizar(config.copyWith(procedimientosHora: hora));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const _SeccionDatosDespacho(),
            ],
          );
        },
      ),
    );
  }
}

/// Nombre, NIF/CIF y dirección del despacho: aparecen como emisor en el PDF
/// de las facturas. Se guardan solo al pulsar "Guardar" (no en cada tecla).
class _SeccionDatosDespacho extends ConsumerStatefulWidget {
  const _SeccionDatosDespacho();

  @override
  ConsumerState<_SeccionDatosDespacho> createState() => _SeccionDatosDespachoState();
}

class _SeccionDatosDespachoState extends ConsumerState<_SeccionDatosDespacho> {
  final _nombreCtrl = TextEditingController();
  final _nifCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  bool _cargado = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nifCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  void _rellenarSiHaceFalta(DatosDespacho datos) {
    if (_cargado) return;
    _nombreCtrl.text = datos.nombre;
    _nifCtrl.text = datos.nifCif;
    _direccionCtrl.text = datos.direccion;
    _cargado = true;
  }

  Future<void> _guardar() async {
    await ref.read(datosDespachoProvider.notifier).actualizar(
          DatosDespacho(
            nombre: _nombreCtrl.text.trim(),
            nifCif: _nifCtrl.text.trim(),
            direccion: _direccionCtrl.text.trim(),
          ),
        );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Datos del despacho guardados')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final datosAsync = ref.watch(datosDespachoProvider);

    return datosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error al cargar los datos del despacho: $error'),
      data: (datos) {
        _rellenarSiHaceFalta(datos);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datos del despacho', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Aparecen como emisor en el PDF de las facturas.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del despacho'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nifCtrl,
              decoration: const InputDecoration(labelText: 'NIF / CIF'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionCtrl,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _guardar, child: const Text('Guardar datos del despacho')),
          ],
        );
      },
    );
  }
}
