import 'package:ai_telegram_agent_front/pages/group_chat/riverpod/prompt_controller.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/ui/widgets/feedback_chart.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/ui/widgets/markdown.dart';
import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardContent extends ConsumerStatefulWidget {
  final String username;
  final String chatName;

  const DashboardContent({
    super.key,
    required this.username,
    required this.chatName,
  });

  @override
  ConsumerState<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<DashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(promptControllerProvider.notifier)
          .getAnalytics(widget.username, widget.chatName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(promptControllerProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          analyticsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text(
              'Error: ${error.toString()}',
              style: TextStyle(color: AppColors.appWhite),
            ),
            data: (analytics) => Column(
              children: [
                Text(
                  'Chat: ${analytics.chatName.isNotEmpty ? analytics.chatName : widget.chatName}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.appWhite,
                      ),
                ),
                Text(
                  'User: ${widget.username}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.appWhite,
                      ),
                ),
                const SizedBox(height: 20),
                FeedbackChart(feedbackData: analytics.feedbackData),
                const SizedBox(height: 20),
                MarkdownContentWidget(content: analytics.markdownContent),
                const SizedBox(height: 20),
                Container(
                  width: 500,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.appLightGrey,
                      width: 0.7,
                    ),
                    color: AppColors.appFieldColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Messages:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.appWhite,
                                ),
                      ),
                      const SizedBox(height: 10),
                      ...analytics.messages.map(
                        (message) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '- ${message['content']}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.appWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
