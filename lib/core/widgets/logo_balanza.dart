import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// La balanza del icono de la app (`assets/icon/icon.svg`) dibujada en
/// código, sin el fondo crema del icono: así toma el dorado del tema activo
/// y se ve bien también en modo oscuro.
class LogoBalanza extends StatelessWidget {
  const LogoBalanza({super.key, this.alto = 64});

  final double alto;

  // Recorte del lienzo de 1024 del SVG alrededor del dibujo.
  static const _x0 = 200.0, _y0 = 180.0, _ancho = 624.0, _alto = 650.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'TusJuicios',
      image: true,
      child: CustomPaint(
        size: Size(alto * _ancho / _alto, alto),
        painter: _BalanzaPainter(AppTheme.of(context).accent),
      ),
    );
  }
}

class _BalanzaPainter extends CustomPainter {
  _BalanzaPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / LogoBalanza._ancho, size.height / LogoBalanza._alto);
    canvas.translate(-LogoBalanza._x0, -LogoBalanza._y0);

    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final relleno = Paint()..color = color;

    void linea(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), trazo);

    linea(512, 248, 512, 785); // mástil
    linea(290, 335, 734, 335); // brazo
    linea(410, 795, 614, 795); // base
    linea(290, 335, 238, 468); // cuerdas izquierda
    linea(290, 335, 342, 468);
    linea(734, 335, 682, 468); // cuerdas derecha
    linea(734, 335, 786, 468);

    canvas.drawCircle(const Offset(512, 220), 28, relleno);

    // Platillos: media elipse por debajo de la línea de las cuerdas.
    for (final centro in const [290.0, 734.0]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(centro, 468), width: 104, height: 52),
        0,
        math.pi,
        true,
        relleno,
      );
    }
  }

  @override
  bool shouldRepaint(_BalanzaPainter oldDelegate) => oldDelegate.color != color;
}
