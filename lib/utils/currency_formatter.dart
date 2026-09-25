import 'package:intl/intl.dart';

class CurrencyUtils {
  static String getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'PKR':
        return 'Rs. ';
      case 'INR':
        return '₹';
      case 'AED':
        return 'AED ';
      case 'SAR':
        return 'SAR ';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      case 'JPY':
        return '¥';
      default:
        return '\$';
    }
  }

  static String format(double amount, {String currencyCode = 'USD', bool showSign = false}) {
    final symbol = getSymbol(currencyCode);
    final formatter = NumberFormat('#,##0.00');
    final formattedNumber = formatter.format(amount.abs());
    
    final sign = showSign ? (amount > 0 ? '+' : (amount < 0 ? '-' : '')) : (amount < 0 ? '-' : '');
    return '$sign$symbol$formattedNumber';
  }

  static String formatCompact(double amount, {String currencyCode = 'USD'}) {
    final symbol = getSymbol(currencyCode);
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}
