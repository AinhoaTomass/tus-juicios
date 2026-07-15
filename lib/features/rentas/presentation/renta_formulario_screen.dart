import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/formulario_sucio_provider.dart';
import '../../../core/widgets/confirmar_salida_dialog.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../domain/renta.dart';
import 'rentas_providers.dart';

/// Formulario de alta (rentaId nulo) o edición de una renta.
class RentaFormularioScreen extends ConsumerStatefulWidget {
  const RentaFormularioScreen({super.key, this.rentaId});

  final String? rentaId;

  @override
  ConsumerState<RentaFormularioScreen> createState() => _RentaFormularioScreenState();
}

class _RentaFormularioScreenState extends ConsumerState<RentaFormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ejercicioCtrl = TextEditingController(text: DateTime.now().year.toString());
  final _resultadoCtrl = TextEditingController();
  String? _clienteId;
  String? _clienteError;
  EstadoRenta _estado = EstadoRenta.enCurso;
  DateTime? _fecha;
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
    _ejercicioCtrl.dispose();
    _resultadoCtrl.dispose();
    super.dispose();
  }

  void _rellenarSiEsEdicion(Renta renta) {
    if (_cargado) return;
    _clienteId = renta.clienteId;
    _ejercicioCtrl.text = renta.ejercicio.toString();
    _resultadoCtrl.text = renta.resultado ?? '';
    _estado = renta.estado;
    _fecha = renta.fecha;
    _cargado = true;
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() => _fecha = fecha);
      _marcarSucio();
    }
  }

  Future<void> _guardar() async {
    setState(() => _clienteError = _clienteId == null ? 'Obligatorio' : null);
    if (!_formKey.currentState!.validate() || _clienteId == null) return;

    final repo = ref.read(rentaRepositoryProvider);
    final renta = Renta(
      id: widget.rentaId ?? '',
      clienteId: _clienteId!,
      ejercicio: int.parse(_ejercicioCtrl.text.trim()),
      estado: _estado,
      resultado: _resultadoCtrl.text.trim().isEmpty ? null : _resultadoCtrl.text.trim(),
      fecha: _fecha,
    );

    if (widget.rentaId == null) {
      await repo.crearRenta(renta);
    } else {
      await repo.actualizarRenta(renta);
    }

    ref.invalidate(rentasListaProvider);
    ref.read(formularioSucioProvider.notifier).limpiar();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.rentaId != null;

    if (esEdicion) {
      final rentaAsync = ref.watch(rentaPorIdProvider(widget.rentaId!));
      return rentaAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
        data: (renta) {
          _rellenarSiEsEdicion(renta);
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
        appBar: AppBar(title: Text(esEdicion ? 'Editar renta' : 'Nueva renta')),
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
              TextFormField(
                controller: _ejercicioCtrl,
                decoration: const InputDecoration(labelText: 'Ejercicio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obligatorio';
                  return int.tryParse(value) == null ? 'Debe ser un número' : null;
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<EstadoRenta>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: EstadoRenta.enCurso, label: Text('En curso')),
                  ButtonSegment(value: EstadoRenta.presentada, label: Text('Presentada')),
                  ButtonSegment(value: EstadoRenta.pendienteDatos, label: Text('Pend. datos')),
                ],
                selected: {_estado},
                onSelectionChanged: (seleccion) {
                  setState(() => _estado = seleccion.first);
                  _marcarSucio();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _resultadoCtrl,
                decoration: const InputDecoration(labelText: 'Resultado'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha'),
                subtitle: Text(
                  _fecha == null ? 'Sin fecha' : '${_fecha!.day}/${_fecha!.month}/${_fecha!.year}',
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: _seleccionarFecha,
                    ),
                    if (_fecha != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _fecha = null);
                          _marcarSucio();
                        },
                      ),
                  ],
                ),
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
