import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/providers/delivery_provider.dart';
import '../../../../shared/widgets/modern_button.dart';
import 'tracking_screen.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  final int deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  ConsumerState<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  bool _isCancelling = false;

  Future<void> _callDriver(String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone non disponible')),
      );
      return;
    }

    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'appeler')),
        );
      }
    }
  }

  Future<void> _cancelDelivery() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la livraison'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette livraison ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    try {
      await ref.read(deliveryRepositoryProvider).cancelDelivery(widget.deliveryId);
      ref.invalidate(deliveryDetailProvider(widget.deliveryId));
      ref.invalidate(deliveriesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Livraison annulée'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryDetailProvider(widget.deliveryId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Détail de la livraison'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: deliveryState.when(
        data: (delivery) {
          if (delivery == null) {
            return const Center(child: Text('Livraison introuvable'));
          }

          final status = delivery.status ?? 'unknown';
          final statusInfo = _getStatusInfo(status);
          final canCancel = status == 'pending' || status == 'pending_assignment';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusInfo['color'], statusInfo['color'].withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: statusInfo['color'].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(statusInfo['icon'], size: 40, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Statut',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statusInfo['label'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Destinataire
                _buildSectionCard(
                  icon: Icons.person,
                  title: 'Destinataire',
                  children: [
                    _buildInfoRow('Nom', delivery.recipientName ?? 'N/A'),
                    _buildInfoRow('Téléphone', delivery.recipientPhone ?? 'N/A'),
                  ],
                ),

                const SizedBox(height: 16),

                // Adresses
                _buildSectionCard(
                  icon: Icons.location_on,
                  title: 'Itinéraire',
                  children: [
                    _buildAddressRow(
                      'Récupération',
                      delivery.pickupCommune ?? 'N/A',
                      delivery.pickupAddress ?? '',
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildAddressRow(
                      'Livraison',
                      delivery.deliveryCommune ?? 'N/A',
                      delivery.deliveryAddress ?? '',
                      Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Colis
                _buildSectionCard(
                  icon: Icons.inventory_2,
                  title: 'Informations colis',
                  children: [
                    _buildInfoRow('Description', delivery.packageDescription ?? 'N/A'),
                    _buildInfoRow('Poids', '${delivery.packageWeightKg ?? 0} kg'),
                    if (delivery.price != null)
                      _buildInfoRow('Prix', '${delivery.price!.toStringAsFixed(0)} FCFA'),
                  ],
                ),

                const SizedBox(height: 16),

                // Paiement
                _buildSectionCard(
                  icon: Icons.payment,
                  title: 'Paiement',
                  children: [
                    _buildInfoRow(
                      'Méthode',
                      delivery.paymentMethod == 'cod' ? 'Cash on Delivery' : 'Prépayé',
                    ),
                    if (delivery.paymentMethod == 'cod' && delivery.codAmount != null)
                      _buildInfoRow('Montant COD', '${delivery.codAmount!.toStringAsFixed(0)} FCFA'),
                  ],
                ),

                if (delivery.driver != null) ...[
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    icon: Icons.local_shipping,
                    title: 'Livreur assigné',
                    children: [
                      _buildInfoRow('Nom', delivery.driver!.firstName ?? 'N/A'),
                      _buildInfoRow('Téléphone', delivery.driver!.phoneNumber ?? 'N/A'),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // Actions
                if (delivery.driver != null)
                  ModernButton(
                    text: 'Appeler le livreur',
                    icon: Icons.phone,
                    onPressed: () => _callDriver(delivery.driver!.phoneNumber),
                    backgroundColor: Colors.green,
                  ),

                if (delivery.driver != null) const SizedBox(height: 12),

                if (status == 'in_transit' || status == 'assigned' || status == 'pickup_confirmed')
                  ModernButton(
                    text: 'Suivre la livraison en temps réel',
                    icon: Icons.map,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TrackingScreen(deliveryId: widget.deliveryId),
                        ),
                      );
                    },
                    backgroundColor: AppTheme.accentColor,
                  ),

                if ((status == 'in_transit' || status == 'assigned' || status == 'pickup_confirmed')) 
                  const SizedBox(height: 12),

                if (canCancel)
                  ModernButton(
                    text: 'Annuler la livraison',
                    icon: Icons.cancel,
                    onPressed: _cancelDelivery,
                    isLoading: _isCancelling,
                    backgroundColor: Colors.red,
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String commune, String address, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                commune,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_assignment':
        return {
          'label': 'En attente d\'assignation',
          'color': Colors.orange,
          'icon': Icons.schedule,
        };
      case 'assigned':
        return {
          'label': 'Livreur assigné',
          'color': Colors.blue,
          'icon': Icons.person_pin_circle,
        };
      case 'pickup_confirmed':
        return {
          'label': 'Colis récupéré',
          'color': Colors.indigo,
          'icon': Icons.check_box,
        };
      case 'in_transit':
        return {
          'label': 'En cours de livraison',
          'color': Colors.purple,
          'icon': Icons.local_shipping,
        };
      case 'delivered':
        return {
          'label': 'Livré avec succès',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'cancelled':
        return {
          'label': 'Annulée',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      default:
        return {
          'label': status,
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
    }
  }
}
