import 'package:ai_telegram_agent_front/config/base_url.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/data/services/prompt_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class AnalyticsServiceImpl implements AnalyticsService {
  final Dio _dio = Dio();

  @override
  Future<Map<String, dynamic>> getAnalyticsData(
    String username,
    String chatName,
  ) async {
    try {
      final response = await _dio.get(
        'http://${BasedUrl.url}/messages',
        queryParameters: {'username': username, 'chat_name': chatName},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
        //   if (chatName == "BotTesting" && username == "ilgera") {
        //     return {
        //       "bert_classification": [
        //         "PositiveFeedback (2 messages)",
        //         "NegativeFeedback (2 messages)",
        //       ],
        //       "llm_response":
        //       "1) Эмоциональный тон: негативный, агрессивный. \n"
        //           "2) Уровень стресса/усталости: 8/10. \n"
        //           "3) Матные слова: 0%. \n"
        //           "4) Конфликты: Вступал. \n"
        //           "5) Уровень вежливости: 2/10.",
        //       "messages": [
        //         {"content": "Всем доброе утро!"},
        //         {"content": "Вы все козлы"},
        //         {"content": "Вы омерзительны"},
        //       ],
        //     };
        //   }
        //
        //   // Default response for other cases
        //   return {
        //     "bert_classification": [
        //       "PositiveFeedback (0 messages)",
        //       "NegativeFeedback (0 messages)",
        //     ],
        //     "llm_response":
        //     "1) Эмоциональный тон: нейтральный. \n"
        //         "2) Уровень стресса/усталости: 3/10. \n"
        //         "3) Матные слова: 0%. \n"
        //         "4) Конфликты: Не вступал. \n"
        //         "5) Уровень вежливости: 7/10.",
        //     "messages": [
        //       {"content": "Нет доступных сообщений для анализа"},
        //     ],
        //   };
        // }
      }
      throw Exception('Failed to load analytics data: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.message}');
      rethrow;
    }
  }
}
