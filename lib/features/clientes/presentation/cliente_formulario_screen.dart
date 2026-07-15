import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/cliente.dart';
import 'clientes_providers.dart';

/// Formulario de alta (clienteId nulo) o edición (clienteId presente).
class ClienteFormularioScreen extends ConsumerStatefulWidget {
  const ClienteFormularioScreen({super.key, this.clienteId});

  final String? clienteId;

  @override
  ConsumerState<ClienteFormularioScreen> createState() => _ClienteFormularioScreenState();
}

class _ClienteFormularioScreenState extends ConsumerState<ClienteFormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _nifCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _resumenCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  TipoCliente _tipo = TipoCliente.fisica;
  EstadoCliente _estado = EstadoCliente.activo;
  DateTime? _fechaVencimiento;
  bool _cargado = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nifCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _direccionCtrl.dispose();
    _resumenCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _rellenarSiEsEdicion(Cliente cliente) {
    if (_cargado) return;
    _nombreCtrl.text = cliente.nombre;
    _nifCtrl.text = cliente.nifCif;
    _telefonoCtrl.text = cliente.telefono ?? '';
    _emailCtrl.text = cliente.email ?? '';
    _direccionCtrl.text = cliente.direccion ?? '';
    _resumenCtrl.text = cliente.resumen ?? '';
    _notasCtrl.text = cliente.notas ?? '';
    _tipo = cliente.tipo;
    _estado = cliente.estado;
    _fechaVencimiento = cliente.fechaVencimiento;
    _cargado = true;
  }

  Future<void> _seleccionarFechaVencimiento() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) setState(() => _fechaVencimiento = fecha);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(clienteRepositoryProvider);
    final cliente = Cliente(
      id: widget.clienteId ?? '',
      nombre: _nombreCtrl.text.trim(),
      nifCif: _nifCtrl.text.trim(),
      tipo: _tipo,
      estado: _estado,
      telefono: _telefonoCtrl.text.trim().isEmpty ? null : _telefonoCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim().isEmpty ? null : _direccionCtrl.text.trim(),
      resumen: _resumenCtrl.text.trim().isEmpty ? null : _resumenCtrl.text.trim(),
      fechaVencimiento: _fechaVencimiento,
      notas: _notasCtrl.text.trim().isEmpty ? null : _notasCtrl.text.trim(),
    );

    if (widget.clienteId == null) {
      await repo.crearCliente(cliente);
    } else {
      await repo.actualizarCliente(cliente);
    }

    ref.invalidate(clientesListaProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.clienteId != null;

    if (esEdicion) {
      final clienteAsync = ref.watch(clientePorIdProvider(widget.clienteId!));
      return clienteAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
        data: (cliente) {
          _rellenarSiEsEdicion(cliente);
          return _buildForm(context, esEdicion);
        },
      );
    }

    return _buildForm(context, esEdicion);
  }

  Widget _buildForm(BuildContext context, bool esEdicion) {
    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar cliente' : 'Nuevo cliente')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => (value == null || value.isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nifCtrl,
              decoration: const InputDecoration(labelText: 'NIF / CIF'),
              validator: (value) => (value == null || value.isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 16),
            SegmentedButton<TipoCliente>(
              segments: const [
                ButtonSegment(value: TipoCliente.fisica, label: Text('Física')),
                ButtonSegment(value: TipoCliente.juridica, label: Text('Jurídica')),
              ],
              selected: {_tipo},
              onSelectionChanged: (seleccion) => setState(() => _tipo = seleccion.first),
            ),
            const SizedBox(height: 16),
            SegmentedButton<EstadoCliente>(
              segments: const [
                ButtonSegment(value: EstadoCliente.activo, label: Text('Activo')),
                ButtonSegment(value: EstadoCliente.pendiente, label: Text('Pendiente')),
                ButtonSegment(value: EstadoCliente.cerrado, label: Text('Cerrado')),
              ],
              selected: {_estado},
              onSelectionChanged: (seleccion) => setState(() => _estado = seleccion.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _direccionCtrl,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _resumenCtrl,
              decoration: const InputDecoration(labelText: 'Resumen'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notasCtrl,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de vencimiento'),
              subtitle: Text(
                _fechaVencimiento == null
                    ? 'Sin fecha'
                    : '${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}',
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: _seleccionarFechaVencimiento,
                  ),
                  if (_fechaVencimiento != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _fechaVencimiento = null),
                    ),
                ],
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
