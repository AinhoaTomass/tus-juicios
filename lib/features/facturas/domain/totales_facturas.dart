import 'factura.dart';

/// Totales de facturación para Inicio y Facturas. Viven aquí (y no en las
/// pantallas) para que ambas muestren las mismas cifras y se puedan probar.

/// Importe cobrado (facturas pagadas) con fecha en el mes de [mes].
double cobradoEnMes(Iterable<Factura> facturas, DateTime mes) => facturas
    .where(
      (f) =>
          f.estado == EstadoFactura.pagada &&
          f.fecha.year == mes.year &&
          f.fecha.month == mes.month,
    )
    .fold(0, (suma, f) => suma + f.importe);

/// Importe aún no cobrado: pendientes y vencidas.
double pendienteDeCobro(Iterable<Factura> facturas) => facturas
    .where((f) => f.estado != EstadoFactura.pagada)
    .fold(0, (suma, f) => suma + f.importe);

/// Importe facturado (cualquier estado) con fecha en el año [anio].
double facturadoEnAnio(Iterable<Factura> facturas, int anio) => facturas
    .where((f) => f.fecha.year == anio)
    .fold(0, (suma, f) => suma + f.importe);
