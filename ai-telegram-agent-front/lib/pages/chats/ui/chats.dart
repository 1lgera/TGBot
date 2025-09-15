import 'package:ai_telegram_agent_front/pages/chats/riverpod/group_controller.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/riverpod/chat_controller.dart';
import 'package:ai_telegram_agent_front/pages/chats/ui/widgets/group_tile.dart';
import 'package:ai_telegram_agent_front/pages/chats/ui/widgets/header.dart';
import 'package:ai_telegram_agent_front/shared_widgets/navigation/side_navigation_bar.dart';
import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Chats extends ConsumerWidget {
  const Chats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupControllerProvider);
    final currentRoute = GoRouterState.of(context).matchedLocation;

    void refreshGroups() {
      ref.read(groupControllerProvider.notifier).refreshGroups();
    }

    void navigateToGroupChat(String groupName) async {
      await ref.read(chatControllerProvider.notifier).getMessages(groupName);
      if (context.mounted) {
        context.push('/group-chat', extra: groupName);
      }
    }

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
                const Align(alignment: Alignment.topCenter, child: Header()),
                Expanded(
                  child: groupsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.appWhite,
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: $error'),
                          ElevatedButton(
                            onPressed: refreshGroups,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (groups) => RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(groupControllerProvider.future),
                      child: ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 60.0,
                              vertical: 10,
                            ),
                            child: GroupTile(
                              lastMessageTime: group.lastMessage?.sendTime,
                              groupTitle: group.name,
                              lastMessage:
                                  group.lastMessage?.content ?? 'No messages',
                              onTap: () => navigateToGroupChat(group.name),
                            ),
                          );
                        },
                      ),
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
