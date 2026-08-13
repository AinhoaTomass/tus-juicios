import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/hairline_card.dart';
import '../../domain/documento.dart';
import '../documentos_providers.dart';

/// Sección de documentos adjuntos (subir/abrir/eliminar), reutilizada en la
/// ficha de cliente (todos los documentos, agrupados por procedimiento) y en
/// el formulario de procedimiento (solo los suyos).
class SeccionDocumentos extends ConsumerStatefulWidget {
  const SeccionDocumentos({
    super.key,
    required this.documentos,
    required this.clienteId,
    required this.onCambio,
    this.procedimientoId,
    this.agruparPorProcedimiento = false,
  });

  final List<Documento> documentos;
  final String clienteId;

  /// Si se indica, los documentos que se suban quedan enlazados a este
  /// procedimiento en vez de quedar como generales del cliente.
  final String? procedimientoId;

  /// Agrupa el listado por procedimiento (para la vista a nivel de cliente).
  final bool agruparPorProcedimiento;

  /// Se llama tras subir o eliminar un documento, con el procedimiento al
  /// que estaba (o está) enlazado — para que quien use este widget pueda
  /// invalidar también la lista de ese procedimiento si no es la suya propia.
  final void Function(String? procedimientoId) onCambio;

  @override
  ConsumerState<SeccionDocumentos> createState() => _SeccionDocumentosState();
}

class _SeccionDocumentosState extends ConsumerState<SeccionDocumentos> {
  bool _subiendo = false;

  Future<void> _subirDocumento() async {
    final resultado = await FilePicker.pickFiles(withData: true);
    final archivo = resultado?.files.single;
    if (archivo == null || archivo.bytes == null) return;

    setState(() => _subiendo = true);
    try {
      await ref.read(documentoRepositoryProvider).subirDocumento(
            clienteId: widget.clienteId,
            procedimientoId: widget.procedimientoId,
            nombreArchivo: archivo.name,
            bytes: archivo.bytes!,
          );
      widget.onCambio(widget.procedimientoId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir el documento: $e')));
      }
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  Future<void> _abrirDocumento(Documento documento) async {
    try {
      final url = await ref.read(documentoRepositoryProvider).obtenerUrlDescarga(documento);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo abrir el documento: $e')));
      }
    }
  }

  Future<void> _eliminarDocumento(Documento documento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar documento'),
        content: Text('¿Seguro que quieres eliminar "${documento.nombreArchivo}"?'),
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
    if (confirmar != true) return;

    await ref.read(documentoRepositoryProvider).eliminarDocumento(documento);
    widget.onCambio(documento.procedimientoId);
  }

  Widget _tarjetaDocumento(Documento documento) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HairlineCard(
        padding: const EdgeInsets.all(12),
        onTap: () => _abrirDocumento(documento),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documento.nombreArchivo,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${documento.fechaSubida.day}/${documento.fechaSubida.month}/${documento.fechaSubida.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Eliminar',
              onPressed: () => _eliminarDocumento(documento),
            ),
          ],
        ),
      ),
    );
  }

  /// 'General' primero, luego un grupo por cada procedimiento con documentos.
  List<(String, List<Documento>)> _agrupados() {
    final generales = widget.documentos.where((d) => d.procedimientoId == null).toList();
    final porProcedimiento = <String, List<Documento>>{};
    for (final documento in widget.documentos.where((d) => d.procedimientoId != null)) {
      porProcedimiento
          .putIfAbsent(documento.procedimientoNombre ?? 'Procedimiento', () => [])
          .add(documento);
    }
    return [
      if (generales.isNotEmpty) ('General', generales),
      ...porProcedimiento.entries.map((entrada) => (entrada.key, entrada.value)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Documentos', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: _subiendo
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_outlined),
              tooltip: 'Añadir documento',
              onPressed: _subiendo ? null : _subirDocumento,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.documentos.isEmpty)
          const Text('Sin documentos adjuntos.')
        else if (!widget.agruparPorProcedimiento)
          ...widget.documentos.map(_tarjetaDocumento)
        else
          for (final grupo in _agrupados()) ...[
            Text(grupo.$1, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            ...grupo.$2.map(_tarjetaDocumento),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}
