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
}
