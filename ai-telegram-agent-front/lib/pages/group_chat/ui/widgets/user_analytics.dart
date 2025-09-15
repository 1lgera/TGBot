import 'package:ai_telegram_agent_front/pages/group_chat/ui/widgets/dashboard.dart';
import 'package:ai_telegram_agent_front/shared_widgets/navigation/side_navigation_bar.dart';
import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserAnalytics extends ConsumerWidget {
  final String username;
  final String chatName;

  const UserAnalytics({
    super.key,
    required this.username,
    required this.chatName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideNavigationBar(currentRoute: currentRoute),
          Expanded(
            child: Center(
              child: DashboardContent(
                username: username,
                chatName: chatName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}