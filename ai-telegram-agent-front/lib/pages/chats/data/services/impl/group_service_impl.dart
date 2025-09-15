import 'package:ai_telegram_agent_front/config/base_url.dart';
import 'package:ai_telegram_agent_front/pages/chats/data/services/group_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class GroupServiceImpl implements GroupService {
  final Dio _dio = Dio();

  @override
  Future<List<dynamic>> fetchGroups() async {
    try {
      final response = await _dio.get('http://${BasedUrl.url}/chats');

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> fetchTestGroups() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      {
        "last_message": {
          "content": "Где можно купить кофе?",
          "send_time": "2025-03-13 16:14:29",
          "username": "ilgera"
        },
        "name": "BotTesting",
        "users": ["Vladi 🍆", "1lgera"]
      },
      {
        "last_message": {
          "content": "это проверка",
          "send_time": "2025-03-26 20:23:22",
          "username": "ilgera"
        },
        "name": "Testing2",
        "users": ["Кирилл", "Vladi 🍆", "1lgera"]
      }
    ];
  }
}