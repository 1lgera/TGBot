import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BotListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const BotListTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 380,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.appMainColor, width: 1.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/images/bot.png', width: 36, height: 38),
            SizedBox(width: 5),
            Text(title, style: TextStyle(color: AppColors.appLightGrey)),
          ],
        ),
      ),
    );
  }
}
