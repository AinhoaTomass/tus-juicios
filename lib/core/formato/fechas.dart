/// Conversión de fechas entre la app y Supabase.
///
/// Hay dos tipos de columna y cada uno se trata distinto:
/// - `date` (fecha de una cita, vencimiento, factura...): un día del
///   calendario, sin hora ni zona. Se envía como `2026-10-13`.
/// - `timestamptz` (fecha de una nota, subida de un documento, envío a la
///   papelera): un instante. Se envía en UTC (`...Z`) y se lee en hora
///   local. Sin la `Z`, Postgres tomaba la hora local como si fuera UTC y
///   el instante quedaba desplazado 1-2 horas.
library;

String _dosCifras(int n) => n.toString().padLeft(2, '0');

/// Día del calendario para una columna `date`: `2026-10-13`.
String fechaParaBd(DateTime fecha) =>
    '${fecha.year.toString().padLeft(4, '0')}-${_dosCifras(fecha.month)}-${_dosCifras(fecha.day)}';

/// Lee una columna `date` como medianoche local de ese día.
DateTime leerFecha(String valor) {
  final dia = DateTime.parse(valor);
  return DateTime(dia.year, dia.month, dia.day);
}

/// Instante para una columna `timestamptz`, en UTC.
String instanteParaBd(DateTime instante) => instante.toUtc().toIso8601String();

/// Lee una columna `timestamptz` en hora local.
DateTime leerInstante(String valor) => DateTime.parse(valor).toLocal();
