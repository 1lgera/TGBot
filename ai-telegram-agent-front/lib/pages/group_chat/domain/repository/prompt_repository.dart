import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/analytics.dart';

abstract interface class AnalyticsRepository {
  Future<AnalyticsData> fetchAnalyticsData(String username, String chatName);
}