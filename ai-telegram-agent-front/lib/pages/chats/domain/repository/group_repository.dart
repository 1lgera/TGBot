import 'package:ai_telegram_agent_front/pages/chats/domain/models/group.dart';

abstract interface class GroupRepository {
  Future<List<Group>> getGroups();
}