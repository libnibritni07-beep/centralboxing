import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:central_boxing/screens/alumno_form_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  testWidgets('GUARDAR esta fijo en la barra inferior (sobre botones/gestos)',
      (t) async {
    await t.pumpWidget(const MaterialApp(home: AlumnoFormScreen()));
    await t.pumpAndSettle();

    // La pantalla expone barra inferior con el boton.
    final scaffold = t.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.bottomNavigationBar, isNotNull);
    expect(find.text('GUARDAR'), findsOneWidget);

    // Protegido por SafeArea: reserva la barra de botones fisicos,
    // aporta 0 con gestos. Mismo codigo, ambos modos.
    expect(
      find.ancestor(
        of: find.text('GUARDAR'),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );

    // El boton NO esta dentro del contenido scrolleable (ahi lo tapaba
    // la barra del sistema).
    final scroll = find.byType(Scrollable);
    expect(
      find.descendant(of: scroll, matching: find.text('GUARDAR')),
      findsNothing,
    );
  });
}
