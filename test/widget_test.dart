import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tusjuicios/main.dart';

void main() {
  testWidgets('La app arranca en Inicio y muestra la barra de navegación', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TusJuiciosApp()));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Clientes'), findsOneWidget);
  });
}
