import 'package:ai_telegram_agent_front/pages/group_chat/data/services/impl/prompt_service_impl.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/data/services/prompt_service.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/analytics.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/repository/prompt_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsService _service;

  AnalyticsRepositoryImpl({AnalyticsService? service})
    : _service = service ?? AnalyticsServiceImpl();

  @override
  Future<AnalyticsData> fetchAnalyticsData(
    String username,
    String chatName,
  ) async {
    final data = await _service.getAnalyticsData(username, chatName);
    return AnalyticsData.fromJson(data);
  }
}
