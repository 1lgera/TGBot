import 'package:ai_telegram_agent_front/pages/chats/data/repository/group_repository_impl.dart';
import 'package:ai_telegram_agent_front/pages/chats/domain/models/group.dart';
import 'package:ai_telegram_agent_front/pages/chats/domain/repository/group_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_controller.g.dart';

@riverpod
class GroupController extends _$GroupController {
  final GroupRepository _repository = GroupRepositoryImpl();

  @override
  Future<List<Group>> build() async {
    return await _repository.getGroups();
  }

  Future<void> refreshGroups() async {
    try {
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _repository.getGroups());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}