/// Comparaciones por día del calendario, ignorando la hora. Las fechas de
/// citas, vencimientos y facturas son días (medianoche), así que compararlas
/// con `DateTime.now()` daba lo de hoy por pasado.
library;

DateTime soloDia(DateTime fecha) => DateTime(fecha.year, fecha.month, fecha.day);

/// `true` si [fecha] es hoy o un día posterior a [hoy].
bool esHoyOPosterior(DateTime fecha, DateTime hoy) => !soloDia(fecha).isBefore(soloDia(hoy));

/// `true` si [fecha] cae entre hoy y dentro de [dias] días, ambos incluidos.
bool estaEnLosProximosDias(DateTime fecha, DateTime hoy, int dias) {
  final dia = soloDia(fecha);
  final desde = soloDia(hoy);
  final hasta = DateTime(desde.year, desde.month, desde.day + dias);
  return !dia.isBefore(desde) && !dia.isAfter(hasta);
}

/// Días de calendario desde [hoy] hasta [fecha] (negativo si ya pasó).
/// Se calcula en UTC para que un cambio de hora (días de 23 o 25 horas) no
/// reste un día.
int diasHasta(DateTime fecha, DateTime hoy) => DateTime.utc(fecha.year, fecha.month, fecha.day)
    .difference(DateTime.utc(hoy.year, hoy.month, hoy.day))
    .inDays;
