import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDay = DateTime(date.year, date.month, date.day);

    final timeString = DateFormat('h:mm a').format(date);

    if (transactionDay == today) {
      return 'Today, $timeString';
    } else if (transactionDay == yesterday) {
      return 'Yesterday, $timeString';
    } else if (now.year == date.year) {
      return '${DateFormat('MMM d').format(date)}, $timeString';
    } else {
      return '${DateFormat('MMM d, yyyy').format(date)}, $timeString';
    }
  }

  static String formatDateGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDay = DateTime(date.year, date.month, date.day);

    if (targetDay == today) {
      return 'Today';
    } else if (targetDay == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    }
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
