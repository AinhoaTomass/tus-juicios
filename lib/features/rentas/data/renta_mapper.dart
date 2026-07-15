import '../domain/renta.dart';

extension EstadoRentaValor on EstadoRenta {
  String get valor => switch (this) {
        EstadoRenta.enCurso => 'en_curso',
        EstadoRenta.presentada => 'presentada',
        EstadoRenta.pendienteDatos => 'pendiente_datos',
      };

  String get etiqueta => switch (this) {
        EstadoRenta.enCurso => 'En curso',
        EstadoRenta.presentada => 'Presentada',
        EstadoRenta.pendienteDatos => 'Pendiente datos',
      };
}

EstadoRenta _estadoRentaDesde(String valor) => switch (valor) {
      'en_curso' => EstadoRenta.enCurso,
      'presentada' => EstadoRenta.presentada,
      'pendiente_datos' => EstadoRenta.pendienteDatos,
      _ => throw ArgumentError('Estado de renta desconocido: $valor'),
    };

extension RentaMapper on Map<String, dynamic> {
  Renta toRenta() => Renta(
        id: this['id'] as String,
        clienteId: this['cliente_id'] as String,
        ejercicio: this['ejercicio'] as int,
        estado: _estadoRentaDesde(this['estado'] as String),
        resultado: this['resultado'] as String?,
        fecha: this['fecha'] == null ? null : DateTime.parse(this['fecha'] as String),
        clienteNombre: (this['clientes'] as Map<String, dynamic>?)?['nombre'] as String?,
      );
}

extension RentaToRow on Renta {
  Map<String, dynamic> toRow() => {
        'cliente_id': clienteId,
        'ejercicio': ejercicio,
        'estado': estado.valor,
        'resultado': resultado,
        'fecha': fecha?.toIso8601String(),
      };
}
