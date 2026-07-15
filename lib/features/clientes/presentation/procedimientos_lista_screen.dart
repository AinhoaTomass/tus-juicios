import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import '../domain/cliente.dart';
import 'procedimientos_providers.dart';

class ProcedimientosListaScreen extends ConsumerStatefulWidget {
  const ProcedimientosListaScreen({super.key});

  @override
  ConsumerState<ProcedimientosListaScreen> createState() => _ProcedimientosListaScreenState();
}

class _ProcedimientosListaScreenState extends ConsumerState<ProcedimientosListaScreen> {
  EstadoProcedimiento? _filtro;

  EstadoTono _tono(EstadoProcedimiento estado) => switch (estado) {
        EstadoProcedimiento.activo => EstadoTono.exito,
        EstadoProcedimiento.pendiente => EstadoTono.aviso,
        EstadoProcedimiento.cerrado => EstadoTono.neutro,
      };

  @override
  Widget build(BuildContext context) {
    final procedimientosAsync = ref.watch(procedimientosListaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Procedimientos')),
      body: procedimientosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar procedimientos: $error')),
        data: (procedimientos) {
          final filtrados = _filtro == null
              ? procedimientos
              : procedimientos.where((p) => p.estado == _filtro).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SegmentedButton<EstadoProcedimiento?>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: null, label: Text('Todos')),
                    ButtonSegment(value: EstadoProcedimiento.activo, label: Text('Activo')),
                    ButtonSegment(value: EstadoProcedimiento.pendiente, label: Text('Pendiente')),
                    ButtonSegment(value: EstadoProcedimiento.cerrado, label: Text('Cerrado')),
                  ],
                  selected: {_filtro},
                  onSelectionChanged: (seleccion) => setState(() => _filtro = seleccion.first),
                ),
              ),
              Expanded(
                child: filtrados.isEmpty
                    ? const Center(child: Text('No hay procedimientos.'))
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(procedimientosListaProvider.notifier).refrescar(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtrados.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final procedimiento = filtrados[index];
                            return HairlineCard(
                              onTap: () => context.go(
                                '/clientes/${procedimiento.clienteId}/procedimientos/${procedimiento.id}/editar',
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          procedimiento.nombre,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        Text(
                                          procedimiento.clienteNombre ?? 'Cliente',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  EstadoChip(
                                    label: procedimiento.estado.name,
                                    tono: _tono(procedimiento.estado),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
