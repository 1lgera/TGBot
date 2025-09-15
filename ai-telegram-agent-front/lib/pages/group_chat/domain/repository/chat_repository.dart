import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/chat.dart';

abstract interface class ChatRepository {
  Future<ChatData?> fetchChatData(String chatName);
}