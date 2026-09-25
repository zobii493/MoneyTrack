import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationProvider>(context);
    final notifications = notifProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => notifProvider.markAllAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              description: "You're all caught up! Important budget alerts and report updates will appear here.",
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];

                IconData icon;
                Color iconColor;

                switch (notif.type) {
                  case 'budget':
                    icon = Icons.warning_amber_rounded;
                    iconColor = AppColors.warning;
                    break;
                  case 'report':
                    icon = Icons.assessment_outlined;
                    iconColor = AppColors.info;
                    break;
                  case 'goal':
                    icon = Icons.stars_rounded;
                    iconColor = AppColors.income;
                    break;
                  default:
                    icon = Icons.notifications_active_outlined;
                    iconColor = AppColors.primary;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif.message),
                        const SizedBox(height: 6),
                        Text(
                          DateUtilsHelper.formatTransactionDate(notif.date),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    onTap: () => notifProvider.markAsRead(notif.id),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => notifProvider.deleteNotification(notif.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
