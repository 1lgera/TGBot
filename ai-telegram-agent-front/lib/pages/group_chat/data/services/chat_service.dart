import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/chat.dart';

abstract interface class ChatService {
  Future<ChatData> getChatData(String chatName);
}
