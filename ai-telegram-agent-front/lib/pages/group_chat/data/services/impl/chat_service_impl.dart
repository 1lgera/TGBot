import 'package:ai_telegram_agent_front/config/base_url.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/data/services/chat_service.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/chat.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ChatServiceImpl implements ChatService {
  final Dio _dio = Dio();

  @override
  Future<ChatData> getChatData(String chatName) async {
    try {
      final response = await _dio.get(
        'http://${BasedUrl.url}/chat/data?chat_name=$chatName',
      );
      debugPrint('API response: ${response.data}');
      if (response.statusCode == 200) {
        return ChatData.fromJson(response.data);
      }
      throw Exception('Failed to load chat data: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.message}');
      rethrow;
    }
  }
}
