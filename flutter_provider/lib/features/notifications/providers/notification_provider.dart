import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

class NotificationState {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiService.instance.getNotifications();
      if (res['success'] == true) {
        state = state.copyWith(
          notifications:
              List<Map<String, dynamic>>.from(res['data']['notifications']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: res['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final res = await ApiService.instance.markNotificationRead(id);
      if (res['success'] == true) {
        final updated = state.notifications.map((n) {
          if (n['id'] == id) return {...n, 'is_read': true};
          return n;
        }).toList();
        state = state.copyWith(notifications: updated);
      }
    } catch (_) {}
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
