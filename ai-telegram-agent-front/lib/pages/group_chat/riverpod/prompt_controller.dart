import 'package:ai_telegram_agent_front/pages/group_chat/data/repository/prompt_repository_impl.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/analytics.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/repository/prompt_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'prompt_controller.g.dart';

@riverpod
class PromptController extends _$PromptController {
  AnalyticsRepository get _repository => AnalyticsRepositoryImpl();
  String? _currentUsername;
  String? _currentChatName;
  bool _isLoading = false;

  @override
  Future<AnalyticsData> build() async {
    return AnalyticsData.empty();
  }

  Future<AnalyticsData> getAnalytics(String username, String chatName) async {
    if (_isLoading) return state.value ?? AnalyticsData.empty();

    _isLoading = true;
    _currentUsername = username;
    _currentChatName = chatName;

    try {
      state = const AsyncValue.loading();
      final analyticsData =
          await _repository.fetchAnalyticsData(username, chatName);
      final result = analyticsData ?? AnalyticsData.empty();
      state = AsyncValue.data(result);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
}
