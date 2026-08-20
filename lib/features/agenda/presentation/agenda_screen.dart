import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/hairline_card.dart';
import '../domain/evento.dart';
import 'eventos_providers.dart';

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  DateTime _mesEnfocado = DateTime.now();
  DateTime _diaSeleccionado = DateTime.now();

  bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
  Widget build(BuildContext context) {
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
          List<Evento> eventosDelDia(DateTime dia) =>
              eventos.where((e) => _mismoDia(e.fecha, dia)).toList();

          final eventosSeleccionados = eventosDelDia(_diaSeleccionado);

          return Column(
            children: [
              TableCalendar<Evento>(
                locale: 'es_ES',
                startingDayOfWeek: StartingDayOfWeek.monday,
                firstDay: DateTime.utc(2000),
                lastDay: DateTime.utc(2100),
                focusedDay: _mesEnfocado,
                selectedDayPredicate: (day) => _mismoDia(day, _diaSeleccionado),
                eventLoader: eventosDelDia,
                onDaySelected: (seleccionado, enfocado) {
                  setState(() {
                    _diaSeleccionado = seleccionado;
                    _mesEnfocado = enfocado;
                  });
                },
                onPageChanged: (enfocado) => _mesEnfocado = enfocado,
                calendarStyle: const CalendarStyle(outsideDaysVisible: false),
                headerStyle: const HeaderStyle(formatButtonVisible: false),
              ),
              const Divider(height: 1),
              Expanded(
                child: eventosSeleccionados.isEmpty
                    ? const Center(child: Text('Sin eventos este día.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: eventosSeleccionados.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final evento = eventosSeleccionados[index];
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
                                      if (evento.descripcion != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          evento.descripcion!,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                      if (evento.hora != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          evento.hora!,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                EstadoChip(
                                  label: _etiquetaTipo(evento.tipo),
                                  tono: _tonoTipo(evento.tipo),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
