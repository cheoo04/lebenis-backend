import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/widgets/modern_info_card.dart';
import '../../../deliveries/presentation/screens/create_delivery_screen.dart';
import '../../../deliveries/presentation/screens/delivery_list_screen.dart';
import '../../../profile/presentation/screens/edit_profile_screen.dart';
import '../../../../data/providers/merchant_provider.dart';

class ActionCardsGrid extends ConsumerWidget {
  const ActionCardsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3,
        children: [
          ModernInfoCard(
            icon: Icons.person,
            title: 'Mon profil',
            subtitle: 'Voir et modifier',
            iconColor: AppTheme.primaryColor,
            onTap: () async {
              final result = await Navigator.push<bool?>(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
              if (result == true) {
                try {
                  await ref.read(merchantProfileProvider.notifier).refresh();
                } catch (_) {}
                try {
                  await ref.read(merchantStatsProvider.notifier).refresh();
                } catch (_) {}
              }
            },
          ),
          ModernInfoCard(
            icon: Icons.local_shipping,
            title: 'Mes livraisons',
            subtitle: 'Voir l\'historique',
            iconColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeliveryListScreen(),
                ),
              );
            },
          ),
          ModernInfoCard(
            icon: Icons.bar_chart,
            title: 'Statistiques',
            subtitle: 'Performances du commerce',
            iconColor: Colors.teal,
            onTap: () {},
          ),
          ModernInfoCard(
            icon: Icons.settings,
            title: 'Paramètres',
            subtitle: 'Préférences',
            iconColor: Colors.grey,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
