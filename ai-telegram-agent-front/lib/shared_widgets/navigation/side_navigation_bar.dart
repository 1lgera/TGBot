import 'package:ai_telegram_agent_front/shared_widgets/button.dart';
import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideNavigationBar extends StatelessWidget {
  final String currentRoute;

  const SideNavigationBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.appMainColor, width: 1.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Button(
            logo: 'assets/images/logo_little.png',
            width: 36,
            height: 36,
            onTap: () {
              context.go('/');
            },
            isSelected: currentRoute == '/',
          ),
          Button(
            logo: 'assets/images/chat.png',
            width: 26,
            height: 26,
            onTap: () {
              context.go('/chat');
            },
            isSelected: currentRoute == '/chat',
          ),
          Button(
            logo: 'assets/images/robot.png',
            width: 26,
            height: 26,
            onTap: () {
              context.go('/settings');
            },
            isSelected: currentRoute == '/settings',
          ),
        ],
      ),
    );
  }
}