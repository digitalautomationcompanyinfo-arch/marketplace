import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

class Conversation {
  final int id;
  final String uuid, userName, lastMessage;
  final String? profileImage;
  final int unreadCount;
  final DateTime lastMessageAt;

  Conversation(
      {required this.id,
      required this.uuid,
      required this.userName,
      required this.lastMessage,
      this.profileImage,
      required this.unreadCount,
      required this.lastMessageAt});

  factory Conversation.fromJson(Map j) => Conversation(
        id: j['id'] as int,
        uuid: j['uuid'] as String,
        userName: j['full_name'] as String? ?? 'عميل',
        lastMessage: j['last_message'] as String? ?? '',
        profileImage: j['profile_image'] as String?,
        unreadCount: j['unread_count'] as int? ?? 0,
        lastMessageAt: DateTime.parse(j['last_message_at'] as String),
      );
}

class ConversationsState {
  final List<Conversation> list;
  final bool isLoading;
  final String? error;

  const ConversationsState(
      {this.list = const [], this.isLoading = false, this.error});

  ConversationsState copyWith(
          {List<Conversation>? list, bool? isLoading, String? error}) =>
      ConversationsState(
          list: list ?? this.list,
          isLoading: isLoading ?? this.isLoading,
          error: error);
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  ConversationsNotifier() : super(const ConversationsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res =
          await ApiService.instance.get('/messages/provider/conversations');
      final list = (res['data'] as List? ?? [])
          .map((c) => Conversation.fromJson(c as Map))
          .toList();
      state = state.copyWith(list: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>(
  (ref) => ConversationsNotifier(),
);
