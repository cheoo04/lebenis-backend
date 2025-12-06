import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final Widget? badge;
  final bool centerAlign;

  const DashboardHeader({
    super.key,
    this.greeting = 'Bienvenue,',
    required this.name,
    this.badge,
    this.centerAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, centerAlign ? 50 : 40),
      child: Column(
        crossAxisAlignment: centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: centerAlign ? 28 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: centerAlign ? TextAlign.center : TextAlign.start,
          ),
          if (badge != null) ...[
            SizedBox(height: centerAlign ? 16 : 12),
            if (centerAlign)
              badge!
            else
              Align(
                alignment: Alignment.centerLeft,
                child: badge!,
              ),
          ],
        ],
      ),
    );
  }
}
