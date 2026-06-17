import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) const SizedBox(width: 40),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF2980B9) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 4 : 16),
                  bottomRight: Radius.circular(isMe ? 16 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                // المحتوى حسب النوع
                _buildContent(),

                const SizedBox(height: 4),

                // الوقت + حالة القراءة
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    DateFormat('hh:mm a', 'ar')
                        .format(message.createdAt.toLocal()),
                    style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white60 : Colors.grey[400]),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead
                          ? Colors.lightBlueAccent
                          : Colors.white54,
                    ),
                  ],
                ]),
              ]),
            ),
          ),
          if (!isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (message.msgType) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.fileUrl ?? '',
            width: 200,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, color: Colors.grey, size: 48),
          ),
        );

      case 'voice':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.play_circle_fill,
              color: isMe ? Colors.white : const Color(0xFF2980B9), size: 32),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 100,
                height: 3,
                decoration: BoxDecoration(
                    color: isMe ? Colors.white30 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 4),
            Text('رسالة صوتية',
                style: TextStyle(
                    fontSize: 12, color: isMe ? Colors.white70 : Colors.grey)),
          ]),
        ]);

      case 'file':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.attach_file,
              color: isMe ? Colors.white : const Color(0xFF2980B9)),
          const SizedBox(width: 6),
          Flexible(
              child: Text(
            message.fileUrl?.split('/').last ?? 'ملف مرفق',
            style: TextStyle(
                color: isMe ? Colors.white : Colors.black87, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          )),
        ]);

      default: // text
        return Text(
          message.content ?? '',
          style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.4),
        );
    }
  }
}
