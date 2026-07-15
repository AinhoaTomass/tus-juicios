import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/nota.dart';
import 'notas_providers.dart';

/// Formulario de alta (notaId nulo) o edición de una nota.
class NotaFormularioScreen extends ConsumerStatefulWidget {
  const NotaFormularioScreen({super.key, this.notaId});

  final String? notaId;

  @override
  ConsumerState<NotaFormularioScreen> createState() => _NotaFormularioScreenState();
}

class _NotaFormularioScreenState extends ConsumerState<NotaFormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  bool _cargado = false;

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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(notaRepositoryProvider);
    final nota = Nota(
      id: widget.notaId ?? '',
      titulo: _tituloCtrl.text.trim(),
      fecha: _fecha,
      contenido: _contenidoCtrl.text.trim().isEmpty ? null : _contenidoCtrl.text.trim(),
    );

    if (widget.notaId == null) {
      await repo.crearNota(nota);
    } else {
      await repo.actualizarNota(nota);
    }

    ref.invalidate(notasListaProvider);
    if (mounted) context.pop();
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
    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar nota' : 'Nueva nota')),
      body: Form(
        key: _formKey,
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
            ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
