import 'package:ai_telegram_agent_front/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.logo,
    required this.height,
    required this.width,
    required this.onTap,
    this.isSelected = false,
    this.isNavBar = true
  });

  final String logo;
  final double height;
  final double width;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isNavBar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      enableFeedback: false,
      onTap: () {
        onTap();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectColor : Colors.transparent,
          border: isNavBar == true ? Border(
            bottom: BorderSide(color: AppColors.appMainColor, width: 1.0),
          ) : Border(
            left: BorderSide(color: AppColors.appMainColor, width: 1.0),
          ),
        ),
        child: Center(child: Image.asset(logo, height: height, width: width)),
      ),
    );
  }
}