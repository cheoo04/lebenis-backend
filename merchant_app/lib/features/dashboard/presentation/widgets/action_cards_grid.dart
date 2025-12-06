import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/models/merchant_model.dart';
import '../../../../data/models/individual_model.dart';
import '../../../deliveries/presentation/screens/create_delivery_screen.dart';
import '../../../deliveries/presentation/screens/delivery_list_screen.dart';
import '../../../profile/presentation/screens/edit_profile_screen.dart';
import '../../../profile/presentation/screens/edit_individual_profile_screen.dart';
import 'action_card.dart';

class ActionCardsGrid extends StatelessWidget {
  final dynamic profile; // MerchantModel ou IndividualModel
  
  const ActionCardsGrid({required this.profile, super.key});

  void _navigateToEditProfile(BuildContext context) {
    if (profile is MerchantModel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        ),
      );
    } else if (profile is IndividualModel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditIndividualProfileScreen(individual: profile),
        ),
      );
    } else if (profile is Map) {
      // Fallback pour Map
      final individual = IndividualModel(
        id: profile['id'] ?? '',
        userId: profile['user'] ?? '',
        firstName: profile['first_name'] ?? '',
        lastName: profile['last_name'] ?? '',
        email: profile['email'] ?? '',
        phone: profile['phone'],
        address: profile['address'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditIndividualProfileScreen(individual: individual),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        ActionCard(
          icon: Icons.add_circle_outline,
          title: 'Créer une\nlivraison',
          iconColor: AppTheme.primaryColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateDeliveryScreen(),
              ),
            );
          },
        ),
        ActionCard(
          icon: Icons.local_shipping_outlined,
          title: 'Mes\nlivraisons',
          iconColor: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DeliveryListScreen(),
              ),
            );
          },
        ),
        ActionCard(
          icon: Icons.person_outline,
          title: 'Mon\nprofil',
          iconColor: Colors.purple,
          onTap: () => _navigateToEditProfile(context),
        ),
        ActionCard(
          icon: Icons.notifications,
          title: 'Notifications',
          iconColor: Colors.orange,
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
      ],
    );
  }
}
