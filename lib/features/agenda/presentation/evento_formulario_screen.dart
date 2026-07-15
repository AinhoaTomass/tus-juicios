import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../clientes/presentation/clientes_providers.dart';
import '../domain/evento.dart';
import 'eventos_providers.dart';

/// Formulario de alta (eventoId nulo) o edición de un evento de agenda.
class EventoFormularioScreen extends ConsumerStatefulWidget {
  const EventoFormularioScreen({super.key, this.eventoId});

  final String? eventoId;

  @override
  ConsumerState<EventoFormularioScreen> createState() => _EventoFormularioScreenState();
}

class _EventoFormularioScreenState extends ConsumerState<EventoFormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  String? _clienteId;
  TipoEvento _tipo = TipoEvento.juicio;
  DateTime _fecha = DateTime.now();
  TimeOfDay? _hora;
  bool _cargado = false;

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  void _rellenarSiEsEdicion(Evento evento) {
    if (_cargado) return;
    _clienteId = evento.clienteId;
    _tipo = evento.tipo;
    _fecha = evento.fecha;
    _descripcionCtrl.text = evento.descripcion ?? '';
    if (evento.hora != null) {
      final partes = evento.hora!.split(':');
      _hora = TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
    }
    _cargado = true;
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) setState(() => _fecha = fecha);
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(context: context, initialTime: _hora ?? TimeOfDay.now());
    if (hora != null) setState(() => _hora = hora);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(eventoRepositoryProvider);
    final evento = Evento(
      id: widget.eventoId ?? '',
      clienteId: _clienteId!,
      tipo: _tipo,
      fecha: _fecha,
      hora: _hora == null
          ? null
          : '${_hora!.hour.toString().padLeft(2, '0')}:${_hora!.minute.toString().padLeft(2, '0')}',
      descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
    );

    if (widget.eventoId == null) {
      await repo.crearEvento(evento);
    } else {
      await repo.actualizarEvento(evento);
    }

    ref.invalidate(eventosListaProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.eventoId != null;

    if (esEdicion) {
      final eventoAsync = ref.watch(eventoPorIdProvider(widget.eventoId!));
      return eventoAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
        data: (evento) {
          _rellenarSiEsEdicion(evento);
          return _buildForm(context, esEdicion);
        },
      );
    }

    return _buildForm(context, esEdicion);
  }

  Widget _buildForm(BuildContext context, bool esEdicion) {
    final clientesAsync = ref.watch(clientesListaProvider);

    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar evento' : 'Nuevo evento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            clientesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Error al cargar clientes: $error'),
              data: (clientes) => DropdownButtonFormField<String>(
                initialValue: _clienteId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: clientes
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre)))
                    .toList(),
                onChanged: (value) => setState(() => _clienteId = value),
                validator: (value) => value == null ? 'Obligatorio' : null,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TipoEvento>(
              segments: const [
                ButtonSegment(value: TipoEvento.juicio, label: Text('Juicio')),
                ButtonSegment(value: TipoEvento.smac, label: Text('SMAC')),
                ButtonSegment(value: TipoEvento.conciliacion, label: Text('Conciliación')),
              ],
              selected: {_tipo},
              onSelectionChanged: (seleccion) => setState(() => _tipo = seleccion.first),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha'),
              subtitle: Text('${_fecha.day}/${_fecha.month}/${_fecha.year}'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: _seleccionarFecha,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hora'),
              subtitle: Text(_hora == null ? 'Sin hora' : _hora!.format(context)),
              trailing: IconButton(
                icon: const Icon(Icons.access_time_outlined),
                onPressed: _seleccionarHora,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
