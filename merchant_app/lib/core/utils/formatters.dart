import 'package:intl/intl.dart';

class Formatters {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatAmount(num amount, {String currency = 'FCFA'}) {
    return '${amount.toStringAsFixed(0)} $currency';
  }
}
