import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/support_provider.dart';
import '../../../core/theme/app_theme.dart';

class SupportChatScreen extends ConsumerStatefulWidget {
  const SupportChatScreen({super.key});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  void _send() {
    if (_msgCtrl.text.trim().isEmpty) return;
    final txt = _msgCtrl.text.trim();
    _msgCtrl.clear();
    ref.read(supportProvider.notifier).sendMessage(txt);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final supportState = ref.watch(supportProvider);

    // للتمرير للأسفل عند تلقي رسالة جديدة
    ref.listen(supportProvider, (prev, next) {
      if (next.messages.length > (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المساعد الذكي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('متصل الآن 🇸🇩',
                style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => ref.read(supportProvider.notifier).clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: supportState.messages.length,
              itemBuilder: (context, i) {
                final msg = supportState.messages[i];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          if (supportState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('جاري التفكير...',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isUser
                ? const Radius.circular(0)
                : const Radius.circular(16),
            bottomRight: msg.isUser
                ? const Radius.circular(16)
                : const Radius.circular(0),
          ),
        ),
        child: Text(
          msg.content,
          style: TextStyle(color: msg.isUser ? Colors.white : Colors.black87),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                decoration: InputDecoration(
                  hintText: 'اسألني أي شيء...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                  fillColor: Colors.grey[100],
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
