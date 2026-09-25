import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';
import '../utils/sample_data.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('notifications');
    if (raw != null) {
      try {
        final List list = jsonDecode(raw) as List;
        _notifications = list.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _notifications = SampleData.defaultNotifications;
      }
    } else {
      _notifications = SampleData.defaultNotifications;
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', jsonEncode(_notifications.map((e) => e.toJson()).toList()));
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _save();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _save();
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _save();
    notifyListeners();
  }

  void addNotification(String title, String message, {String type = 'system'}) {
    final newItem = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      date: DateTime.now(),
      isRead: false,
      type: type,
    );
    _notifications.insert(0, newItem);
    _save();
    notifyListeners();
  }
}
