import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../clientes/presentation/clientes_providers.dart';
import '../domain/factura.dart';
import 'facturas_providers.dart';

/// Formulario de alta (facturaId nulo) o edición de una factura.
class FacturaFormularioScreen extends ConsumerStatefulWidget {
  const FacturaFormularioScreen({super.key, this.facturaId});

  final String? facturaId;

  @override
  ConsumerState<FacturaFormularioScreen> createState() => _FacturaFormularioScreenState();
}

class _FacturaFormularioScreenState extends ConsumerState<FacturaFormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCtrl = TextEditingController();
  final _importeCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  String? _clienteId;
  EstadoFactura _estado = EstadoFactura.pendiente;
  DateTime _fecha = DateTime.now();
  bool _cargado = false;

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _importeCtrl.dispose();
    _conceptoCtrl.dispose();
    super.dispose();
  }

  void _rellenarSiEsEdicion(Factura factura) {
    if (_cargado) return;
    _numeroCtrl.text = factura.numero;
    _importeCtrl.text = factura.importe.toString();
    _conceptoCtrl.text = factura.concepto ?? '';
    _clienteId = factura.clienteId;
    _estado = factura.estado;
    _fecha = factura.fecha;
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

    final repo = ref.read(facturaRepositoryProvider);
    final factura = Factura(
      id: widget.facturaId ?? '',
      numero: _numeroCtrl.text.trim(),
      clienteId: _clienteId!,
      importe: double.parse(_importeCtrl.text.trim().replaceAll(',', '.')),
      estado: _estado,
      fecha: _fecha,
      concepto: _conceptoCtrl.text.trim().isEmpty ? null : _conceptoCtrl.text.trim(),
    );

    if (widget.facturaId == null) {
      await repo.crearFactura(factura);
    } else {
      await repo.actualizarFactura(factura);
    }

    ref.invalidate(facturasListaProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.facturaId != null;

    if (esEdicion) {
      final facturaAsync = ref.watch(facturaPorIdProvider(widget.facturaId!));
      return facturaAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
        data: (factura) {
          _rellenarSiEsEdicion(factura);
          return _buildForm(context, esEdicion);
        },
      );
    }

    return _buildForm(context, esEdicion);
  }

  Widget _buildForm(BuildContext context, bool esEdicion) {
    final clientesAsync = ref.watch(clientesListaProvider);

    return Scaffold(
      appBar: AppBar(title: Text(esEdicion ? 'Editar factura' : 'Nueva factura')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _numeroCtrl,
              decoration: const InputDecoration(labelText: 'Número'),
              validator: (value) => (value == null || value.isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 16),
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
            TextFormField(
              controller: _importeCtrl,
              decoration: const InputDecoration(labelText: 'Importe (€)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Obligatorio';
                return double.tryParse(value.replaceAll(',', '.')) == null
                    ? 'Debe ser un número'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _conceptoCtrl,
              decoration: const InputDecoration(labelText: 'Concepto'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SegmentedButton<EstadoFactura>(
              segments: const [
                ButtonSegment(value: EstadoFactura.pendiente, label: Text('Pendiente')),
                ButtonSegment(value: EstadoFactura.pagada, label: Text('Pagada')),
                ButtonSegment(value: EstadoFactura.vencida, label: Text('Vencida')),
              ],
              selected: {_estado},
              onSelectionChanged: (seleccion) => setState(() => _estado = seleccion.first),
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
