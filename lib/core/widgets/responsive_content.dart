import 'package:flutter/material.dart';

/// A partir de este ancho, [AppShell] pasa de barra de navegación inferior a
/// panel lateral. Las pantallas que muestran acciones propias del panel
/// lateral (ajustes, cerrar sesión) las ocultan a partir de aquí para no
/// duplicarlas.
const anchoPanelLateral = 700.0;

/// Ancho máximo de listados, Inicio y pantallas de consulta en pantallas
/// anchas: más allá, buscadores y tarjetas se estiran de borde a borde.
const anchoListado = 960.0;

/// Ancho máximo de los formularios: campos de un monitor entero de ancho
/// son incómodos de leer y rellenar.
const anchoFormulario = 640.0;

/// Centra el contenido y le pone un ancho máximo en pantallas anchas
/// (tablet/escritorio en la versión web), para que no se estire de borde a
/// borde en un monitor. En móvil no cambia nada: [maxWidth] no llega a
/// aplicarse porque la pantalla ya es más estrecha que eso.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = anchoListado,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
