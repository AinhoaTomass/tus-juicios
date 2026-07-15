import '../domain/nota.dart';

extension NotaMapper on Map<String, dynamic> {
  Nota toNota() => Nota(
        id: this['id'] as String,
        titulo: this['titulo'] as String,
        fecha: DateTime.parse(this['fecha'] as String),
        contenido: this['contenido'] as String?,
      );
}

extension NotaToRow on Nota {
  Map<String, dynamic> toRow() => {
        'titulo': titulo,
        'fecha': fecha.toIso8601String(),
        'contenido': contenido,
      };
}
