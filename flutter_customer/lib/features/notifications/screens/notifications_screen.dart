// notifications_screen.dart - Notifications list screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.read(notificationProvider.notifier).loadNotifications(),
          ),
        ],
      ),
      body: state.isLoading && state.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.notifications.isEmpty
              ? Center(
                  child: Text(state.error!,
                      style: const TextStyle(color: Colors.red)))
              : state.notifications.isEmpty
                  ? const Center(child: Text('لا توجد إشعارات حالياً'))
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(notificationProvider.notifier)
                          .loadNotifications(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final n = state.notifications[i];
                          final bool isRead = n['is_read'] ?? false;

                          // Mapping icons based on data/type
                          IconData getIcon() {
                            final type = n['data']?['type'];
                            if (type == 'order_update')
                              return Icons.delivery_dining;
                            if (type == 'tendering_update') return Icons.gavel;
                            return Icons.notifications_active;
                          }

                          return InkWell(
                            onTap: () {
                              if (!isRead) {
                                ref
                                    .read(notificationProvider.notifier)
                                    .markAsRead(n['id']);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.white
                                    : AppTheme.primaryLight.withOpacity(0.05),
                                borderRadius: AppTheme.radiusMd,
                                border: Border.all(
                                    color: isRead
                                        ? AppTheme.borderColor
                                        : AppTheme.primaryLight
                                            .withOpacity(0.3)),
                                boxShadow: AppTheme.shadowSm,
                              ),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                          color: AppTheme.primaryLight
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle),
                                      child: Icon(getIcon(),
                                          color: AppTheme.primaryLight,
                                          size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Row(children: [
                                            Expanded(
                                                child: Text(
                                                    n['title'] ?? 'تنبيه',
                                                    style: TextStyle(
                                                        fontWeight: isRead
                                                            ? FontWeight.w600
                                                            : FontWeight.w800,
                                                        fontSize: 14))),
                                            if (!isRead)
                                              Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppTheme
                                                              .primaryLight,
                                                          shape:
                                                              BoxShape.circle)),
                                          ]),
                                          const SizedBox(height: 4),
                                          Text(n['body'] ?? '',
                                              style: AppTheme.bodyMd,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 6),
                                          Text(
                                              n['sent_at'] != null
                                                  ? timeago.format(
                                                      DateTime.parse(
                                                          n['sent_at']),
                                                      locale: 'ar')
                                                  : '',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.textMuted)),
                                        ])),
                                  ]),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
