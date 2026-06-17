import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../../messages/widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.userName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatProvider(widget.conversationId).notifier)
        ..connect()
        ..loadMessages()
        ..markAsRead();
    });

    _controller.addListener(_onTypingChanged);
  }

  void _onTypingChanged() {
    final isTyping = _controller.text.isNotEmpty;
    if (isTyping != _isTyping) {
      setState(() => _isTyping = isTyping);
      final notifier = ref.read(chatProvider(widget.conversationId).notifier);
      isTyping ? notifier.sendTyping() : notifier.stopTyping();
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(chatProvider(widget.conversationId).notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    // We don't disconnect here because family providers handle disposal,
    // but the ChatNotifier.dispose calls disconnect().
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(widget.conversationId));

    // Scroll to bottom when new messages arrive
    ref.listen(chatProvider(widget.conversationId), (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (chatState.isOtherTyping)
              const Text('يكتب...',
                  style: TextStyle(fontSize: 12, color: Colors.green)),
            if (!chatState.isConnected)
              const Text('جاري الاتصال...',
                  style: TextStyle(fontSize: 10, color: Colors.orange)),
          ],
        ),
      ),
      body: Column(
        children: [
          if (chatState.error != null)
            Container(
              width: double.infinity,
              color: Colors.red[100],
              padding: const EdgeInsets.all(8),
              child: Text(chatState.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ),

          Expanded(
            child: chatState.isLoading && chatState.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: chatState.messages.length,
                    itemBuilder: (_, i) => MessageBubble(
                      message: chatState.messages[i],
                    ),
                  ),
          ),

          // شريط الإدخال
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textDirection: TextDirection.rtl,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة للعميل...',
                      hintTextDirection: TextDirection.rtl,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isTyping ? Icons.send : Icons.mic_none),
                  color: _isTyping ? const Color(0xFF2980B9) : Colors.grey,
                  onPressed: _isTyping ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
