import 'package:flutter/services.dart';

/// Digits only (max 9), shown as `XX-XXXXXXX`. Show a fixed `03` prefix in [InputDecoration.prefixText].
class PakistanMobileSuffixFormatter extends TextInputFormatter {
  static const int maxDigitsAfterPrefix = 9;

  static String digitsOnly(String s) =>
      s.replaceAll(RegExp(r'\D'), '');

  /// Full display form: `0340-8432739`.
  static String toFullPakNumber(String formattedSuffix) {
    final digits = normalizeSuffixDigits(formattedSuffix);
    if (digits.length != maxDigitsAfterPrefix) {
      return digits.isEmpty ? '' : '03$digits';
    }
    return '03${digits.substring(0, 2)}-${digits.substring(2)}';
  }

  static String formatDigits(String clipped) {
    if (clipped.isEmpty) return '';
    if (clipped.length <= 2) return clipped;
    return '${clipped.substring(0, 2)}-${clipped.substring(2)}';
  }

  /// Drops non-digits, strips pasted leading national prefix `03`, keeps up to nine digits for the suffix field.
  static String normalizeSuffixDigits(String raw) {
    var d = digitsOnly(raw);
    if (d.startsWith('03') && d.length > 2) {
      d = d.substring(2);
    }
    if (d.length > maxDigitsAfterPrefix) {
      d = d.substring(0, maxDigitsAfterPrefix);
    }
    return d;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newDigits = normalizeSuffixDigits(newValue.text);

    final formatted = formatDigits(newDigits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}
