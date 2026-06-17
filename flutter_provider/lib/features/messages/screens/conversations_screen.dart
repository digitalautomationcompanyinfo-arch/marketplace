import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/conversations_provider.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(conversationsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المحادثات')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(conversationsProvider.notifier).load(),
        child: state.isLoading && state.list.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.list.isEmpty
                ? const Center(child: Text('لا توجد محادثات نشطة حالياً'))
                : ListView.separated(
                    itemCount: state.list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = state.list[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: c.profileImage != null
                              ? NetworkImage(c.profileImage!)
                              : null,
                          child: c.profileImage == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(c.userName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(c.lastMessage,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                '${c.lastMessageAt.hour}:${c.lastMessageAt.minute}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            if (c.unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                                child: Text('${c.unreadCount}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10)),
                              ),
                          ],
                        ),
                        onTap: () =>
                            context.push('/chat/${c.id}', extra: c.userName),
                      );
                    },
                  ),
      ),
    );
  }
}
