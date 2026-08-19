import 'package:flutter/material.dart';

/// A partir de este ancho, [AppShell] pasa de barra de navegación inferior a
/// panel lateral. Las pantallas que muestran acciones propias del panel
/// lateral (ajustes, cerrar sesión) las ocultan a partir de aquí para no
/// duplicarlas.
const anchoPanelLateral = 700.0;

/// Centra el contenido y le pone un ancho máximo en pantallas anchas
/// (tablet/escritorio en la versión web), para que no se estire de borde a
/// borde en un monitor. En móvil no cambia nada: [maxWidth] no llega a
/// aplicarse porque la pantalla ya es más estrecha que eso.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1400,
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
