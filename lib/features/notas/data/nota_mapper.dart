import '../../../core/formato/fechas.dart';
import '../domain/nota.dart';

extension NotaMapper on Map<String, dynamic> {
  Nota toNota() => Nota(
        id: this['id'] as String,
        titulo: this['titulo'] as String,
        fecha: leerInstante(this['fecha'] as String),
        contenido: this['contenido'] as String?,
        clienteId: this['cliente_id'] as String?,
        clienteNombre: (this['clientes'] as Map<String, dynamic>?)?['nombre'] as String?,
      );
}

extension NotaToRow on Nota {
  Map<String, dynamic> toRow() => {
        'titulo': titulo,
        'fecha': instanteParaBd(fecha),
        'contenido': contenido,
        'cliente_id': clienteId,
      };
}
