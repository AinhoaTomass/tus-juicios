import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/estado_chip.dart';
import '../../../core/widgets/filtro_chips.dart';
import '../../../core/widgets/hairline_card.dart';
import '../domain/cliente.dart';
import 'clientes_providers.dart';
import 'procedimientos_providers.dart';

class ClientesListaScreen extends ConsumerStatefulWidget {
  const ClientesListaScreen({super.key});

  @override
  ConsumerState<ClientesListaScreen> createState() => _ClientesListaScreenState();
}

class _ClientesListaScreenState extends ConsumerState<ClientesListaScreen> {
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';
  TipoCliente? _filtroTipo;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesListaProvider);
    final procedimientos = ref.watch(procedimientosListaProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Papelera',
            onPressed: () => context.push('/clientes/papelera'),
          ),
        ],
      ),
      body: clientesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error al cargar clientes: $error')),
        data: (todos) {
          final filtrados = todos.where((c) {
            final coincideTipo = _filtroTipo == null || c.tipo == _filtroTipo;
            final texto = _busqueda.trim().toLowerCase();
            final coincideBusqueda = texto.isEmpty ||
                c.nombre.toLowerCase().contains(texto) ||
                (c.nifCif?.toLowerCase().contains(texto) ?? false) ||
                procedimientos.any(
                  (p) => p.clienteId == c.id && p.nombre.toLowerCase().contains(texto),
                );
            return coincideTipo && coincideBusqueda;
          }).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(clientesListaProvider.notifier).refrescar(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _busquedaCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Buscar cliente, NIF o procedimiento…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _busqueda = value),
                ),
                const SizedBox(height: 12),
                FiltroChips<TipoCliente?>(
                  opciones: const [
                    (null, 'Todos'),
                    (TipoCliente.fisica, 'Física'),
                    (TipoCliente.juridica, 'Jurídica'),
                  ],
                  seleccion: _filtroTipo,
                  onChanged: (valor) => setState(() => _filtroTipo = valor),
                ),
                const SizedBox(height: 12),
                Text(
                  '${filtrados.length} cliente(s)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                if (filtrados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No se han encontrado clientes.')),
                  )
                else
                  ...filtrados.map(
                    (cliente) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ClienteCard(cliente: cliente),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/clientes/nuevo'),
                  child: const Text('Nuevo cliente'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  const _ClienteCard({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return HairlineCard(
      onTap: () => context.go('/clientes/${cliente.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(cliente.nombre, style: textTheme.titleMedium)),
              if (cliente.datosIncompletos) ...[
                Tooltip(
                  message: 'Faltan datos por completar',
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: AppTheme.of(context).accent,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (cliente.esUrgente)
                const EstadoChip(label: 'Urgente', tono: EstadoTono.urgente),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (cliente.nifCif != null) cliente.nifCif!,
              cliente.tipo == TipoCliente.fisica ? 'FÍSICA' : 'JURÍDICA',
            ].join(' · '),
            style: textTheme.labelMedium?.copyWith(color: AppTheme.of(context).accent),
          ),
          if (cliente.resumen != null) ...[
            const SizedBox(height: 6),
            Text(cliente.resumen!, style: textTheme.bodyMedium),
          ],
          if (cliente.fechaVencimiento != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.event_outlined, size: 16, color: AppTheme.of(context).mutedInk),
                const SizedBox(width: 6),
                Text(
                  'Vence ${cliente.fechaVencimiento!.day}/${cliente.fechaVencimiento!.month}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
