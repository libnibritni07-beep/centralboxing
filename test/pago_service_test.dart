import 'package:flutter_test/flutter_test.dart';
import 'package:central_boxing/services/pago_service.dart';

void main() {
  test(
    '31/01/2026 -> 28/02/2026',
    () => expect(
      PagoService.siguienteVencimiento(DateTime(2026, 1, 31)),
      DateTime(2026, 2, 28),
    ),
  );
  test(
    '31/01/2024 bisiesto -> 29/02',
    () => expect(
      PagoService.siguienteVencimiento(DateTime(2024, 1, 31)),
      DateTime(2024, 2, 29),
    ),
  );
  test(
    '31/03 -> 30/04',
    () => expect(
      PagoService.siguienteVencimiento(DateTime(2026, 3, 31)),
      DateTime(2026, 4, 30),
    ),
  );
  test(
    '28/02 -> 28/03',
    () => expect(
      PagoService.siguienteVencimiento(DateTime(2026, 2, 28)),
      DateTime(2026, 3, 28),
    ),
  );
  test(
    'recalcular 0 restantes: insc 10/01 -> 10/02',
    () => expect(
      PagoService.recalcularVencimiento(DateTime(2026, 1, 10), 0),
      DateTime(2026, 2, 10),
    ),
  );
  test(
    'recalcular 1 restante: insc 10/01 -> 10/03',
    () => expect(
      PagoService.recalcularVencimiento(DateTime(2026, 1, 10), 1),
      DateTime(2026, 3, 10),
    ),
  );
  test(
    'recalcular 0 restantes fin de mes: 31/01 -> 28/02',
    () => expect(
      PagoService.recalcularVencimiento(DateTime(2026, 1, 31), 0),
      DateTime(2026, 2, 28),
    ),
  );
  test(
    'recalcular bisiesto: 31/01/2024 +0 -> 29/02, +1 -> 29/03',
    () {
      expect(
        PagoService.recalcularVencimiento(DateTime(2024, 1, 31), 0),
        DateTime(2024, 2, 29),
      );
      expect(
        PagoService.recalcularVencimiento(DateTime(2024, 1, 31), 1),
        DateTime(2024, 3, 29),
      );
    },
  );
  test(
    'recalcular cambio de año: insc 15/12 +0 -> 15/01/2026',
    () => expect(
      PagoService.recalcularVencimiento(DateTime(2025, 12, 15), 0),
      DateTime(2026, 1, 15),
    ),
  );
}
