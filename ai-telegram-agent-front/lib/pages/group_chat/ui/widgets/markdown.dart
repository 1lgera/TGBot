import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownContentWidget extends StatelessWidget {
  final String content;

  const MarkdownContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(20),
      decoration: _buildContainerDecoration(),
      child: MarkdownBody(
        data: content,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.appWhite,
          ),
          listBullet: TextStyle(
            color: AppColors.appWhite, // For bullet points
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      border: Border.all(color: AppColors.appLightGrey, width: 0.7),
      color: AppColors.appFieldColor,
      borderRadius: BorderRadius.circular(4),
    );
  }
}