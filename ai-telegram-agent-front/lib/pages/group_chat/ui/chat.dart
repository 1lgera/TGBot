import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/user.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/riverpod/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_telegram_agent_front/pages/group_chat/ui/widgets/header.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/ui/widgets/message_tile.dart';
import 'package:ai_telegram_agent_front/shared_widgets/navigation/side_navigation_bar.dart';
import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';

class Chat extends ConsumerStatefulWidget {
  final String title;

  const Chat({super.key, required this.title});

  @override
  ConsumerState<Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<Chat> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatControllerProvider.notifier).getMessages(widget.title);
    });
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideNavigationBar(currentRoute: currentRoute),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Header(
                    chatName: widget.title,
                    users: chatState.maybeWhen(
                      data: (chatData) => chatData.users,
                      orElse: () => [],
                    ),
                  ),
                ),
                Expanded(
                  child: chatState.when(
                    data: (chatData) {
                      if (chatData.messages.isEmpty) {
                        return const Center(
                            child: Text('No messages available'));
                      }

                      return ListView.builder(
                        itemCount: chatData.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatData.messages[index];
                          final user = chatData.users.firstWhere(
                            (u) => u.username == message.username,
                            orElse: () =>
                                User(name: 'Unknown', username: 'unknown'),
                          );

                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: MessageTile(
                                message: message.content,
                                user: user.name,
                                messageTime: _formatDateTime(message.sendTime),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) => Center(
                      child: Text('Error loading messages: $error'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
