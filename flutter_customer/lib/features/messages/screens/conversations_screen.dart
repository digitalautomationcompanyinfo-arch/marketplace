// conversations_screen.dart - Chat conversations list
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  final _conversations = const [
    {
      'name': 'مطعم البيت السعودي',
      'last': 'شكراً لطلبك، سيصل خلال 25 دقيقة',
      'time': '2:30 م',
      'unread': 2
    },
    {
      'name': 'صيدلية الحياة',
      'last': 'دواؤك جاهز للاستلام',
      'time': 'أمس',
      'unread': 0
    },
    {
      'name': 'تقنية الوادي',
      'last': 'تم استلام طلبك',
      'time': 'أمس',
      'unread': 1
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: _conversations.isEmpty
          ? const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 60, color: AppTheme.textMuted),
                  SizedBox(height: 16),
                  Text('لا توجد محادثات بعد',
                      style:
                          TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                ]))
          : ListView.separated(
              itemCount: _conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = _conversations[i];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primaryLight,
                    child: Text((c['name'] as String)[0],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ),
                  title: Text(c['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(c['last'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.textMuted)),
                  trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(c['time'] as String,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMuted)),
                        if ((c['unread'] as int) > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                                color: AppTheme.primaryLight,
                                shape: BoxShape.circle),
                            child: Center(
                                child: Text('${c['unread']}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700))),
                          ),
                        ],
                      ]),
                  onTap: () => context.push('/chat/1', extra: c['name']),
                );
              },
            ),
    );
  }
}
