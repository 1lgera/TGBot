import 'package:ai_telegram_agent_front/pages/group_chat/domain/models/user.dart';
import 'package:ai_telegram_agent_front/shared_widgets/button.dart';
import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.chatName, required this.users,});

  final String chatName;
  final List<User> users;


  void _showModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: AppColors.appBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: 700,
            maxWidth: 600
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Users (${users.length})',
                    style: TextStyle(
                      color: AppColors.appWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.appWhite),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: Icon(Icons.person, color: AppColors.appWhite),
                      title: Text(
                        user.name,
                        style: TextStyle(color: AppColors.appWhite),
                      ),
                      subtitle: Text(
                        '@${user.username}',
                        style: TextStyle(color: AppColors.appLightGrey),
                      ),
                      onTap: () {
                        // Close the modal first
                        Navigator.pop(context);
                        // Then navigate to UserAnalytics
                        context.push(
                          '/analytics',
                          extra: {
                            'username': user.username,
                            'chatName': chatName,
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).matchedLocation;
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.appBackgroundColor,
        border: Border(bottom: BorderSide(color: AppColors.appMainColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 26),
          Text(
            chatName,
            style: TextStyle(
              color: AppColors.appWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Button(
            logo: 'assets/images/users.png',
            width: 26,
            height: 26,
            onTap: () {
              _showModal(context);
            },
            isSelected: false,
            isNavBar: false,
          ),
        ],
      ),
    );
  }
}
