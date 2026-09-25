import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ToastType { success, warning, error, info }

class ToastNotification {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
  }) {
    Color bg;
    IconData icon;

    switch (type) {
      case ToastType.success:
        bg = AppColors.income;
        icon = Icons.check_circle_outline;
        break;
      case ToastType.warning:
        bg = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case ToastType.error:
        bg = AppColors.expense;
        icon = Icons.error_outline;
        break;
      case ToastType.info:
        bg = AppColors.info;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
