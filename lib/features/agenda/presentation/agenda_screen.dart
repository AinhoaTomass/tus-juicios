import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import '../domain/evento.dart';
import 'eventos_providers.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  String _etiquetaTipo(TipoEvento tipo) => switch (tipo) {
        TipoEvento.juicio => 'Juicio',
        TipoEvento.smac => 'SMAC',
        TipoEvento.conciliacion => 'Conciliación',
      };

  EstadoTono _tonoTipo(TipoEvento tipo) => switch (tipo) {
        TipoEvento.juicio => EstadoTono.urgente,
        TipoEvento.smac => EstadoTono.aviso,
        TipoEvento.conciliacion => EstadoTono.neutro,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(eventosListaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/agenda/nuevo'),
        child: const Icon(Icons.add),
      ),
      body: eventosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar la agenda: $error')),
        data: (eventos) {
          if (eventos.isEmpty) {
            return const Center(child: Text('Todavía no hay eventos.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(eventosListaProvider.notifier).refrescar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: eventos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final evento = eventos[index];
                return HairlineCard(
                  onTap: () => context.go('/agenda/${evento.id}/editar'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              evento.clienteNombre ?? 'Cliente',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${evento.fecha.day}/${evento.fecha.month}/${evento.fecha.year}'
                              '${evento.hora != null ? ' · ${evento.hora}' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (evento.descripcion != null) ...[
                              const SizedBox(height: 4),
                              Text(evento.descripcion!, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ],
                        ),
                      ),
                      EstadoChip(label: _etiquetaTipo(evento.tipo), tono: _tonoTipo(evento.tipo)),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
