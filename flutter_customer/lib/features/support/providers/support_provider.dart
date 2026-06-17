import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class SupportMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  SupportMessage(
      {required this.content, required this.isUser, required this.timestamp});

  Map<String, dynamic> toJson() =>
      {'role': isUser ? 'user' : 'model', 'content': content};
}

class SupportState {
  final List<SupportMessage> messages;
  final bool isLoading;
  final String? error;

  SupportState({this.messages = const [], this.isLoading = false, this.error});

  SupportState copyWith(
      {List<SupportMessage>? messages, bool? isLoading, String? error}) {
    return SupportState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SupportNotifier extends StateNotifier<SupportState> {
  SupportNotifier()
      : super(SupportState(messages: [
          SupportMessage(
              content:
                  "مرحباً بك! أنا مساعد 'كيف نخدمك' الذكي. كيف بقدر أساعدك الليلة؟ 🇸🇩",
              isUser: false,
              timestamp: DateTime.now()),
        ]));

  Future<void> sendMessage(String text) async {
    final userMsg =
        SupportMessage(content: text, isUser: true, timestamp: DateTime.now());
    state =
        state.copyWith(messages: [...state.messages, userMsg], isLoading: true);

    try {
      final history = state.messages
          .sublist(0, state.messages.length - 1)
          .map((m) => m.toJson())
          .toList();
      final res = await ApiService.instance.sendSupportMessage(text, history);

      final botMsg = SupportMessage(
          content: res['data']['reply'],
          isUser: false,
          timestamp: DateTime.parse(res['data']['timestamp']));

      state = state
          .copyWith(messages: [...state.messages, botMsg], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearChat() {
    state = SupportState(messages: [
      SupportMessage(
          content: "تم مسح المحادثة. كيف أساعدك؟",
          isUser: false,
          timestamp: DateTime.now()),
    ]);
  }
}

final supportProvider = StateNotifierProvider<SupportNotifier, SupportState>(
    (ref) => SupportNotifier());
