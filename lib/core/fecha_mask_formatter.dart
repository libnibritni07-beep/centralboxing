import 'package:flutter/services.dart';

/// Inserta `/` automáticamente al escribir: `01012000` → `01/01/2000`.
class FechaMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// `dd/MM/yyyy` → DateTime, o null si formato o fecha inválida
/// (rechaza 31/02, acepta 29/02/2024).
DateTime? parseFecha(String v) {
  final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(v.trim());
  if (m == null) return null;
  final d = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final y = int.parse(m.group(3)!);
  if (mo < 1 || mo > 12 || d < 1 || d > 31) return null;
  try {
    final dt = DateTime(y, mo, d);
    if (dt.day != d || dt.month != mo || dt.year != y) return null;
    return dt;
  } catch (_) {
    return null;
  }
}
