import 'package:ai_telegram_agent_front/pages/chats/domain/models/message.dart';

class Group {
  String name;
  List<String> users;
  Message? lastMessage;

  Group({
    required this.name,
    required this.users,
    this.lastMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'users': users,
      'last_message': lastMessage?.toJson(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'] as String,
      users: List<String>.from(json['users'] as List),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'])
          : null,
    );
  }
}