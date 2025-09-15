import 'package:ai_telegram_agent_front/pages/group_chat/data/services/chat_service.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/data/services/impl/chat_service_impl.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/chat.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService _service = ChatServiceImpl();


  @override
  Future<ChatData?> fetchChatData(String chatName) async {
    // final Map<String, dynamic> demoData = {
    //   "chat_name": "Testing2",
    //   "messages": [
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "fdsfjsdfljsajfsajnmfjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjdsfsdfjEFbnwefoewIFNEEWIOHGBnweogo",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //
    //     // ... rest of your messages data
    //   ],
    //   "users": [
    //     {"name": "Кирилл", "username": "HammerRo"},
    //     {"name": "Vladi 🍆", "username": "sakaevvlad"},
    //     {"name": "1lgera", "username": "ilgera"},
    //   ],
    // };
    // final Map<String, dynamic> demoData1 = {
    //   "chat_name": "BotTesting",
    //   "messages": [
    //     {
    //       "content": "Проверка",
    //       "send_time": "2025-03-19 10:30:23",
    //       "username": "ilgera",
    //     },
    //   ],
    //   "users": [
    //     {"name": "Кирилл", "username": "HammerRo"},
    //     {"name": "Vladi 🍆", "username": "sakaevvlad"},
    //     {"name": "1lgera", "username": "ilgera"},
    //     {"name": "Кирилл", "username": "HammerRo"},
    //     {"name": "Vladi 🍆", "username": "sakaevvlad"},
    //     {"name": "1lgera", "username": "ilgera"},
    //     {"name": "Кирилл", "username": "HammerRo"},
    //     {"name": "Vladi 🍆", "username": "sakaevvlad"},
    //     {"name": "1lgera", "username": "ilgera"},
    //     {"name": "Кирилл", "username": "HammerRo"},
    //     {"name": "Vladi 🍆", "username": "sakaevvlad"},
    //     {"name": "1lgera", "username": "ilgera"},
    //     {"name": "Кирилл", "username": "HammerRo"},
    //     {"name": "Vladi 🍆", "username": "sakaevvlad"},
    //     {"name": "1lgera", "username": "ilgera"},
    //   ],
    // };
    return await _service.getChatData(chatName);
  }
}