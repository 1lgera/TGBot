// group_repository_impl.dart
import 'package:ai_telegram_agent_front/pages/chats/data/services/group_service.dart';
import 'package:ai_telegram_agent_front/pages/chats/data/services/impl/group_service_impl.dart';
import 'package:ai_telegram_agent_front/pages/chats/domain/models/group.dart';
import 'package:ai_telegram_agent_front/pages/chats/domain/repository/group_repository.dart';
import 'package:flutter/material.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupService _service = GroupServiceImpl();

  @override
  Future<List<Group>> getGroups() async {
    try {
      final data = await _service.fetchGroups();

      return data.map((groupJson) => Group.fromJson(groupJson)).toList();
    } catch (e) {
      debugPrint('Error in GroupRepository: $e');
      return [];
    }
  }
}