import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Small circular icon button used for compact action buttons (phone, nav...)
class SmallCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;

  const SmallCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.iconColor = Colors.white,
    this.size = 40.0,
    this.iconSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: iconSize,
          splashRadius: size * 0.6,
          color: iconColor,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      ),
    );
  }
}
