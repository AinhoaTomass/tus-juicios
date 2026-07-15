import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/formulario_sucio_provider.dart';
import '../../../core/widgets/confirmar_salida_dialog.dart';
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
  String? _clienteError;
  TipoEvento _tipo = TipoEvento.juicio;
  DateTime _fecha = DateTime.now();
  TimeOfDay? _hora;
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(formularioSucioProvider.notifier).limpiar(),
    );
  }

  void _marcarSucio() => ref.read(formularioSucioProvider.notifier).marcar();

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
    if (fecha != null) {
      setState(() => _fecha = fecha);
      _marcarSucio();
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(context: context, initialTime: _hora ?? TimeOfDay.now());
    if (hora != null) {
      setState(() => _hora = hora);
      _marcarSucio();
    }
  }

  Future<void> _guardar() async {
    setState(() => _clienteError = _clienteId == null ? 'Obligatorio' : null);
    if (!_formKey.currentState!.validate() || _clienteId == null) return;

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
    ref.read(formularioSucioProvider.notifier).limpiar();
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
    final sucio = ref.watch(formularioSucioProvider);

    return PopScope(
      canPop: !sucio,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final salir = await confirmarSalirSinGuardar(context);
        if (salir && context.mounted) {
          ref.read(formularioSucioProvider.notifier).limpiar();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(esEdicion ? 'Editar evento' : 'Nuevo evento')),
        body: Form(
          key: _formKey,
          onChanged: _marcarSucio,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              clientesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Error al cargar clientes: $error'),
                data: (clientes) => DropdownMenu<String>(
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: _clienteId,
                  label: const Text('Cliente'),
                  errorText: _clienteError,
                  dropdownMenuEntries: clientes
                      .map((c) => DropdownMenuEntry(value: c.id, label: c.nombre))
                      .toList(),
                  onSelected: (value) {
                    setState(() {
                      _clienteId = value;
                      _clienteError = null;
                    });
                    _marcarSucio();
                  },
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<TipoEvento>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: TipoEvento.juicio, label: Text('Juicio')),
                  ButtonSegment(value: TipoEvento.smac, label: Text('SMAC')),
                  ButtonSegment(value: TipoEvento.conciliacion, label: Text('Conciliación')),
                ],
                selected: {_tipo},
                onSelectionChanged: (seleccion) {
                  setState(() => _tipo = seleccion.first);
                  _marcarSucio();
                },
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
