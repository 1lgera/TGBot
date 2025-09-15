import 'package:ai_telegram_agent_front/pages/chats/domain/models/message.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/user.dart';

class ChatData {
  final String chatName;
  final List<Message> messages;
  final List<User> users;

  ChatData({
    required this.chatName,
    required this.messages,
    required this.users,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      chatName: json['chat_name'],
      messages: (json['messages'] as List)
          .map((message) => Message.fromJson(message))
          .toList(),
      users: (json['users'] as List)
          .map((user) => User.fromJson(user))
          .toList(),
    );
  }
}