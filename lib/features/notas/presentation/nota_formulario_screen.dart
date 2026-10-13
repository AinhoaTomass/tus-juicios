import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/formulario_sucio_provider.dart';
import '../../../core/widgets/confirmar_salida_dialog.dart';
import '../../../core/widgets/mostrar_error.dart';
import '../../../core/widgets/responsive_content.dart';
import '../domain/nota.dart';
import 'notas_providers.dart';

/// Formulario de alta (notaId nulo) o edición de una nota. Si [clienteId] se
/// indica al crear, la nota queda ligada a ese cliente; si se abre para
/// editar, el vínculo con el cliente lo trae la propia nota.
class NotaFormularioScreen extends ConsumerStatefulWidget {
  const NotaFormularioScreen({super.key, this.notaId, this.clienteId});

  final String? notaId;
  final String? clienteId;

  @override
  ConsumerState<NotaFormularioScreen> createState() => _NotaFormularioScreenState();
}

class _NotaFormularioScreenState extends ConsumerState<NotaFormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  late String? _clienteId = widget.clienteId;
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
    _tituloCtrl.dispose();
    _contenidoCtrl.dispose();
    super.dispose();
  }

  void _rellenarSiEsEdicion(Nota nota) {
    if (_cargado) return;
    _tituloCtrl.text = nota.titulo;
    _contenidoCtrl.text = nota.contenido ?? '';
    _fecha = nota.fecha;
    _clienteId = nota.clienteId;
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(notaRepositoryProvider);
    final nota = Nota(
      id: widget.notaId ?? '',
      titulo: _tituloCtrl.text.trim(),
      fecha: _fecha,
      contenido: _contenidoCtrl.text.trim().isEmpty ? null : _contenidoCtrl.text.trim(),
      clienteId: _clienteId,
    );

    try {
      if (widget.notaId == null) {
        await repo.crearNota(nota);
      } else {
        await repo.actualizarNota(nota);
      }
    } catch (error) {
      if (mounted) mostrarError(context, 'No se pudo guardar la nota', error);
      return;
    }

    ref.invalidate(notasListaProvider);
    if (_clienteId != null) ref.invalidate(notasDeClienteProvider(_clienteId!));
    ref.read(formularioSucioProvider.notifier).limpiar();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota guardada')),
      );
      context.pop();
    }
  }

  Future<void> _eliminar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text(
          '¿Seguro que quieres eliminar "${_tituloCtrl.text.trim()}"? '
          'No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    try {
      await ref.read(notaRepositoryProvider).eliminarNota(widget.notaId!);
    } catch (error) {
      if (mounted) mostrarError(context, 'No se pudo eliminar la nota', error);
      return;
    }
    if (!mounted) return;

    ref.read(formularioSucioProvider.notifier).limpiar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nota eliminada')),
    );
    // Primero salir y luego refrescar, para que esta pantalla no intente
    // volver a cargar una nota que ya no existe.
    context.pop();
    ref.invalidate(notasListaProvider);
    if (_clienteId != null) ref.invalidate(notasDeClienteProvider(_clienteId!));
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.notaId != null;

    if (esEdicion) {
      final notaAsync = ref.watch(notaPorIdProvider(widget.notaId!));
      return notaAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
        data: (nota) {
          _rellenarSiEsEdicion(nota);
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
        appBar: AppBar(
          title: Text(esEdicion ? 'Editar nota' : 'Nueva nota'),
          actions: [
            if (esEdicion)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar nota',
                onPressed: _eliminar,
              ),
          ],
        ),
        body: ResponsiveContent(
          maxWidth: anchoFormulario,
          child: Form(
            key: _formKey,
            onChanged: _marcarSucio,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contenidoCtrl,
                  decoration: const InputDecoration(labelText: 'Contenido'),
                  maxLines: 6,
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
      ),
    );
  }
}
