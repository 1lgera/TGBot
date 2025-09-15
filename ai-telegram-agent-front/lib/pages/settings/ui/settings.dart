import 'package:ai_telegram_agent_front/pages/settings/ui/widgets/bot_list.dart';
import 'package:ai_telegram_agent_front/shared_widgets/navigation/side_navigation_bar.dart';
import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideNavigationBar(currentRoute: currentRoute,),
          Expanded(child: Center(child: BotList())),
        ],
      ),
    );
  }
}
