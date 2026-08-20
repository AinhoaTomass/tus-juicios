import '../domain/evento.dart';

extension TipoEventoValor on TipoEvento {
  String get valor => switch (this) {
        TipoEvento.juicio => 'Juicio',
        TipoEvento.smac => 'SMAC',
        TipoEvento.conciliacion => 'Conciliacion',
        TipoEvento.otro => 'Otro',
      };
}

TipoEvento _tipoEventoDesde(String valor) => switch (valor) {
      'Juicio' => TipoEvento.juicio,
      'SMAC' => TipoEvento.smac,
      'Conciliacion' => TipoEvento.conciliacion,
      'Otro' => TipoEvento.otro,
      _ => throw ArgumentError('Tipo de evento desconocido: $valor'),
    };

extension CategoriaEventoValor on CategoriaEvento {
  String get valor => switch (this) {
        CategoriaEvento.despacho => 'Despacho',
        CategoriaEvento.personal => 'Personal',
      };
}

CategoriaEvento _categoriaEventoDesde(String valor) => switch (valor) {
      'Despacho' => CategoriaEvento.despacho,
      'Personal' => CategoriaEvento.personal,
      _ => throw ArgumentError('Categoría de evento desconocida: $valor'),
    };

extension EventoMapper on Map<String, dynamic> {
  Evento toEvento() => Evento(
        id: this['id'] as String,
        clienteId: this['cliente_id'] as String?,
        categoria: _categoriaEventoDesde(this['categoria'] as String),
        tipo: _tipoEventoDesde(this['tipo'] as String),
        fecha: DateTime.parse(this['fecha'] as String),
        hora: this['hora'] as String?,
        descripcion: this['descripcion'] as String?,
        clienteNombre: (this['clientes'] as Map<String, dynamic>?)?['nombre'] as String?,
      );
}

extension EventoToRow on Evento {
  Map<String, dynamic> toRow() => {
        'cliente_id': clienteId,
        'categoria': categoria.valor,
        'tipo': tipo.valor,
        'fecha': fecha.toIso8601String(),
        'hora': hora,
        'descripcion': descripcion,
      };
}
