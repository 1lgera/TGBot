import 'package:ai_telegram_agent_front/pages/settings/ui/widgets/bot_list_tile.dart';
import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BotList extends StatelessWidget {
  const BotList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: 600,
      decoration: BoxDecoration(
        color: AppColors.appFieldColor,
        border: Border.all(color: AppColors.appMainColor),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          BotListTile(title: 'Bot1', onTap: () {}),
        ],
      ),
    );
  }
}
