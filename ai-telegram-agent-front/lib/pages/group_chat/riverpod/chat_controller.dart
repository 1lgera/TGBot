import 'package:ai_telegram_agent_front/pages/group_chat/data/repository/chat_repository_impl.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/chat.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/domain/repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_controller.g.dart';

@riverpod
class ChatController extends _$ChatController {
  ChatRepository get _repository => ChatRepositoryImpl();
  String? _currentChatName;

  @override
  Future<ChatData> build() async {
    if (_currentChatName != null) {
      return await getMessages(_currentChatName!);
    }
    return ChatData(
      chatName: '',
      messages: [],
      users: [],
    );
  }

  Future<ChatData> getMessages(String chatName) async {
    _currentChatName = chatName;
    debugPrint(chatName);
    try {
      state = const AsyncValue.loading();
      final chatData = await _repository.fetchChatData(chatName);
      final result = chatData ??
          ChatData(
            chatName: chatName,
            messages: [],
            users: [],
          );
      state = AsyncValue.data(result);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}
