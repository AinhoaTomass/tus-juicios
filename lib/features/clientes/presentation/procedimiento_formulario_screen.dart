import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/formulario_sucio_provider.dart';
import '../../../core/widgets/confirmar_salida_dialog.dart';
import '../domain/cliente.dart';
import 'documentos_providers.dart';
import 'procedimientos_providers.dart';
import 'widgets/seccion_documentos.dart';

/// Formulario de alta (procedimientoId nulo) o edición de un procedimiento
/// dentro de la ficha de un cliente.
class ProcedimientoFormularioScreen extends ConsumerStatefulWidget {
  const ProcedimientoFormularioScreen({
    super.key,
    required this.clienteId,
    this.procedimientoId,
  });

  final String clienteId;
  final String? procedimientoId;

  @override
  ConsumerState<ProcedimientoFormularioScreen> createState() =>
      _ProcedimientoFormularioScreenState();
}

class _ProcedimientoFormularioScreenState extends ConsumerState<ProcedimientoFormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  EstadoProcedimiento _estado = EstadoProcedimiento.activo;
  DateTime? _fechaMeta;
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
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _rellenarSiEsEdicion(Procedimiento procedimiento) {
    if (_cargado) return;
    _nombreCtrl.text = procedimiento.nombre;
    _estado = procedimiento.estado;
    _fechaMeta = procedimiento.fechaMeta;
    _cargado = true;
  }

  Future<void> _seleccionarFechaMeta() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaMeta ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() => _fechaMeta = fecha);
      _marcarSucio();
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(procedimientoRepositoryProvider);
    final procedimiento = Procedimiento(
      id: widget.procedimientoId ?? '',
      clienteId: widget.clienteId,
      nombre: _nombreCtrl.text.trim(),
      estado: _estado,
      fechaMeta: _fechaMeta,
    );

    if (widget.procedimientoId == null) {
      await repo.crearProcedimiento(procedimiento);
    } else {
      await repo.actualizarProcedimiento(procedimiento);
    }

    ref.invalidate(procedimientosDeClienteProvider(widget.clienteId));
    ref.invalidate(procedimientosListaProvider);
    ref.read(formularioSucioProvider.notifier).limpiar();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.procedimientoId != null;

    if (esEdicion) {
      final procedimientoAsync = ref.watch(
        procedimientoPorIdProvider(widget.clienteId, widget.procedimientoId!),
      );
      return procedimientoAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
        data: (procedimiento) {
          _rellenarSiEsEdicion(procedimiento);
          return _buildForm(context, esEdicion);
        },
      );
    }

    return _buildForm(context, esEdicion);
  }

  Widget _buildForm(BuildContext context, bool esEdicion) {
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
        appBar: AppBar(title: Text(esEdicion ? 'Editar procedimiento' : 'Nuevo procedimiento')),
        body: Form(
          key: _formKey,
          onChanged: _marcarSucio,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => (value == null || value.isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              SegmentedButton<EstadoProcedimiento>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: EstadoProcedimiento.activo, label: Text('Activo')),
                  ButtonSegment(value: EstadoProcedimiento.pendiente, label: Text('Pendiente')),
                  ButtonSegment(value: EstadoProcedimiento.cerrado, label: Text('Cerrado')),
                ],
                selected: {_estado},
                onSelectionChanged: (seleccion) {
                  setState(() => _estado = seleccion.first);
                  _marcarSucio();
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha meta'),
                subtitle: Text(
                  _fechaMeta == null
                      ? 'Sin fecha'
                      : '${_fechaMeta!.day}/${_fechaMeta!.month}/${_fechaMeta!.year}',
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: _seleccionarFechaMeta,
                    ),
                    if (_fechaMeta != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _fechaMeta = null);
                          _marcarSucio();
                        },
                      ),
                  ],
                ),
              ),
              if (esEdicion) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final documentosAsync = ref.watch(
                      documentosDeProcedimientoProvider(widget.procedimientoId!),
                    );
                    return documentosAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Text('Error al cargar documentos: $error'),
                      data: (documentos) => SeccionDocumentos(
                        documentos: documentos,
                        clienteId: widget.clienteId,
                        procedimientoId: widget.procedimientoId,
                        onCambio: (_) {
                          ref.invalidate(documentosDeProcedimientoProvider(widget.procedimientoId!));
                          ref.invalidate(documentosDeClienteProvider(widget.clienteId));
                        },
                      ),
                    );
                  },
                ),
              ],
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
