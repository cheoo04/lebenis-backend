import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final void Function()? onCreateDelivery;
  final void Function()? onViewDeliveries;
  final void Function()? onProfile;
  const QuickActions({this.onCreateDelivery, this.onViewDeliveries, this.onProfile, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.add_box,
          label: 'Nouvelle livraison',
          onTap: onCreateDelivery,
        ),
        _ActionButton(
          icon: Icons.list_alt,
          label: 'Mes livraisons',
          onTap: onViewDeliveries,
        ),
        _ActionButton(
          icon: Icons.person,
          label: 'Profil',
          onTap: onProfile,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function()? onTap;
  const _ActionButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
