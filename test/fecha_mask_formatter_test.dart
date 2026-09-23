import 'package:flutter_test/flutter_test.dart';
import 'package:central_boxing/core/fecha_mask_formatter.dart';

String mask(String input) {
  final f = FechaMaskFormatter();
  return f
      .formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: input),
      )
      .text;
}

void main() {
  test('agrega diagonales al escribir', () {
    expect(mask('0'), '0');
    expect(mask('01'), '01');
    expect(mask('010'), '01/0');
    expect(mask('0101'), '01/01');
    expect(mask('01012'), '01/01/2');
    expect(mask('01012000'), '01/01/2000');
  });
  test('limita a 8 dígitos', () {
    expect(mask('01012000123'), '01/01/2000');
  });
  test('ignora caracteres no numéricos', () {
    expect(mask('01-01-2000'), '01/01/2000');
  });
  test('parseFecha válido e inválidos', () {
    expect(parseFecha('01/01/2000'), DateTime(2000, 1, 1));
    expect(parseFecha('29/02/2024'), DateTime(2024, 2, 29));
    expect(parseFecha('31/02/2026'), isNull);
    expect(parseFecha('1/1/2000'), isNull);
    expect(parseFecha(''), isNull);
    expect(parseFecha('13/13/2000'), isNull);
  });
}
