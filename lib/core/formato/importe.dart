import 'package:intl/intl.dart';

final _conDecimales = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);
final _sinDecimales = NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 0);

/// Importe en formato español: `1.234,50 €`. Con [decimales] a `false`
/// redondea a euros (`1.235 €`), para totales en tarjetas de resumen.
String formatearImporte(double importe, {bool decimales = true}) =>
    (decimales ? _conDecimales : _sinDecimales).format(importe);
