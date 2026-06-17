import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/network/api_service.dart';

// ─── Message Model ────────────────────────────────────────
class Message {
  final int id;
  final String senderType;
  final int senderId;
  final String? content;
  final String msgType;
  final String? fileUrl;
  final bool isRead;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.senderType,
    required this.senderId,
    this.content,
    required this.msgType,
    this.fileUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map j) => Message(
        id: j['id'] as int,
        senderType: j['sender_type'] as String,
        senderId: j['sender_id'] as int,
        content: j['content'] as String?,
        msgType: j['msg_type'] as String? ?? 'text',
        fileUrl: j['file_url'] as String?,
        isRead: j['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  bool get isMe => senderType == 'provider';
}

// ─── Chat State ───────────────────────────────────────────
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final bool isConnected;
  final bool isOtherTyping;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.isOtherTyping = false,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isConnected,
    bool? isOtherTyping,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isConnected: isConnected ?? this.isConnected,
        isOtherTyping: isOtherTyping ?? this.isOtherTyping,
        error: error,
      );
}

// ─── Chat Notifier ────────────────────────────────────────
class ChatNotifier extends StateNotifier<ChatState> {
  final String conversationId;
  IO.Socket? _socket;

  ChatNotifier(this.conversationId) : super(const ChatState());

  Future<void> connect() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token') ?? '';
    final socketUrl = dotenv.env['SOCKET_URL'] ?? 'https://api.marketplace.com';

    _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build());

    _socket!.onConnect((_) {
      state = state.copyWith(isConnected: true);
      _socket!.emit('join_conversation', int.tryParse(conversationId));
    });

    _socket!.onDisconnect((_) => state = state.copyWith(isConnected: false));

    // FIX H1: Deduplication logic to prevent double-rendering
    _socket!.on('new_message', (data) {
      final msg = Message.fromJson(data as Map);
      if (state.messages.any((m) => m.id == msg.id)) return;
      state = state.copyWith(messages: [...state.messages, msg]);
    });

    _socket!
        .on('user_typing', (_) => state = state.copyWith(isOtherTyping: true));
    _socket!.on('user_stop_typing',
        (_) => state = state.copyWith(isOtherTyping: false));

    _socket!.on('messages_read', (_) {
      final updated = state.messages
          .map((m) => Message(
                id: m.id,
                senderType: m.senderType,
                senderId: m.senderId,
                content: m.content,
                msgType: m.msgType,
                fileUrl: m.fileUrl,
                isRead: true,
                createdAt: m.createdAt,
              ))
          .toList();
      state = state.copyWith(messages: updated);
    });

    // FIX: Listen for server errors
    _socket!
        .on('error', (err) => state = state.copyWith(error: err.toString()));
    _socket!.on('send_message_error',
        (err) => state = state.copyWith(error: err['message']));
  }

  Future<void> loadMessages({String? before}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ApiService.instance.get('/messages/$conversationId',
          params: before != null ? {'before': before} : null);
      final msgs = (res['data'] as List? ?? [])
          .map((m) => Message.fromJson(m as Map))
          .toList();
      state = state.copyWith(messages: msgs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void sendMessage(String content) {
    if (_socket == null || content.trim().isEmpty) return;
    _socket!.emit('send_message', {
      'conversation_id': int.tryParse(conversationId),
      'content': content.trim(),
      'msg_type': 'text',
    });
  }

  void markAsRead() {
    _socket?.emit('mark_read', int.tryParse(conversationId));
  }

  void sendTyping() => _socket?.emit('typing', int.tryParse(conversationId));
  void stopTyping() =>
      _socket?.emit('stop_typing', int.tryParse(conversationId));

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, conversationId) => ChatNotifier(conversationId),
);
