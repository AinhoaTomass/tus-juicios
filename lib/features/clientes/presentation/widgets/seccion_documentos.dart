import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/hairline_card.dart';
import '../../domain/documento.dart';
import '../documentos_providers.dart';

/// Sección de documentos adjuntos (subir/abrir/eliminar), reutilizada en la
/// ficha de cliente (solo los generales, sin procedimiento) y en el
/// formulario de procedimiento (solo los suyos, como línea de tiempo).
class SeccionDocumentos extends ConsumerStatefulWidget {
  const SeccionDocumentos({
    super.key,
    required this.documentos,
    required this.clienteId,
    required this.onCambio,
    this.procedimientoId,
    this.estiloLinea = false,
  });

  final List<Documento> documentos;
  final String clienteId;

  /// Si se indica, los documentos que se suban quedan enlazados a este
  /// procedimiento en vez de quedar como generales del cliente.
  final String? procedimientoId;

  /// Los pinta como una línea de tiempo vertical (más antiguos arriba) en
  /// vez de tarjetas sueltas — para seguir la evolución de un procedimiento.
  final bool estiloLinea;

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
    if (!mounted) return;

    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Fecha del documento',
    );
    if (fecha == null) return;

    setState(() => _subiendo = true);
    try {
      await ref.read(documentoRepositoryProvider).subirDocumento(
            clienteId: widget.clienteId,
            procedimientoId: widget.procedimientoId,
            nombreArchivo: archivo.name,
            bytes: archivo.bytes!,
            fecha: fecha,
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

  /// Documentos ya vienen ordenados por fecha ascendente desde el
  /// repositorio; aquí solo se dibuja la línea y los puntos.
  Widget _lineaTiempo() {
    final documentos = widget.documentos;
    return Column(
      children: [
        for (var i = 0; i < documentos.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.of(context).accent,
                      ),
                    ),
                    if (i != documentos.length - 1)
                      Expanded(
                        child: Container(width: 1.5, color: AppTheme.of(context).hairline),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i == documentos.length - 1 ? 0 : 16),
                    child: _tarjetaDocumento(documentos[i]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
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
        else if (widget.estiloLinea)
          _lineaTiempo()
        else
          ...widget.documentos.map(_tarjetaDocumento),
      ],
    );
  }
}
