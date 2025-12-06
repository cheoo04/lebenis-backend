import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/providers/delivery_provider.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../core/providers.dart';
import 'tracking_screen.dart';
import '../../../chat/screens/chat_screen.dart';
import '../../../chat/providers/chat_provider.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  final String deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  ConsumerState<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  bool _isCancelling = false;
  bool _isDownloadingPDF = false;
  double _downloadProgress = 0.0;

  Future<void> _openChat(String driverId, String deliveryRef) async {
    try {
      final chatRoom = await ref.read(chatRoomsProvider.notifier).createOrGetChatRoom(
        driverId: driverId,
        deliveryId: deliveryRef,
      );

      if (chatRoom != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(chatRoom: chatRoom),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

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

  Future<void> _downloadPDF() async {
    setState(() {
      _isDownloadingPDF = true;
      _downloadProgress = 0.0;
    });

    try {
      final pdfService = ref.read(pdfReportServiceProvider);
      final filePath = await pdfService.downloadDeliveryPDF(
        deliveryId: widget.deliveryId,
        onProgress: (progress) {
          setState(() => _downloadProgress = progress);
        },
      );

      if (mounted) {
        // Show success and ask to open/share
        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ PDF téléchargé'),
            content: const Text('Que voulez-vous faire ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'close'),
                child: const Text('Fermer'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'share'),
                child: const Text('Partager'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'open'),
                child: const Text('Ouvrir'),
              ),
            ],
          ),
        );

        if (action == 'share') {
          await pdfService.sharePDF(filePath);
        } else if (action == 'open') {
          await pdfService.openPDF(filePath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingPDF = false;
          _downloadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _showRatingDialog(String deliveryId, String driverName) async {
    double rating = 5.0;
    double punctuality = 5.0;
    double professionalism = 5.0;
    double care = 5.0;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Noter $driverName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Note globale', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setState(() => rating = index + 1.0),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                _buildRatingSlider('Ponctualité', punctuality, (val) => setState(() => punctuality = val)),
                _buildRatingSlider('Professionnalisme', professionalism, (val) => setState(() => professionalism = val)),
                _buildRatingSlider('Soin du colis', care, (val) => setState(() => care = val)),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire (optionnel)',
                    border: OutlineInputBorder(),
                    hintText: 'Partagez votre expérience...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _submitRating(
                  deliveryId: deliveryId,
                  rating: rating,
                  comment: commentController.text,
                  punctualityRating: punctuality,
                  professionalismRating: professionalism,
                  careRating: care,
                );
              },
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text('${value.toStringAsFixed(1)} / 5.0', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: 1.0,
          max: 5.0,
          divisions: 8,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _submitRating({
    required String deliveryId,
    required double rating,
    String? comment,
    double? punctualityRating,
    double? professionalismRating,
    double? careRating,
  }) async {
    try {
      final repository = ref.read(deliveryRepositoryProvider);
      await repository.rateDriver(
        deliveryId: deliveryId,
        rating: rating,
        comment: comment,
        punctualityRating: punctualityRating,
        professionalismRating: professionalismRating,
        careRating: careRating,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⭐ Merci pour votre évaluation !'),
            backgroundColor: Colors.green,
          ),
        );
        // Recharger les détails
        ref.invalidate(deliveryDetailProvider(deliveryId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
          final canCancel = status == 'pending';

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
                // Download PDF Button (always visible)
                ModernButton(
                  text: _isDownloadingPDF 
                    ? 'Téléchargement... ${(_downloadProgress * 100).toInt()}%'
                    : 'Télécharger le PDF',
                  icon: Icons.picture_as_pdf,
                  onPressed: _isDownloadingPDF ? null : _downloadPDF,
                  isLoading: _isDownloadingPDF,
                  backgroundColor: Colors.deepPurple,
                ),

                const SizedBox(height: 12),

                if (delivery.driver != null)
                  ModernButton(
                    text: 'Appeler le livreur',
                    icon: Icons.phone,
                    onPressed: () => _callDriver(delivery.driver!.phoneNumber),
                    backgroundColor: Colors.green,
                  ),

                if (delivery.driver != null) const SizedBox(height: 12),

                if (delivery.driver != null)
                  ModernButton(
                    text: 'Contacter le livreur',
                    icon: Icons.chat,
                    onPressed: () => _openChat(
                      delivery.driver!.id,
                      delivery.trackingNumber,
                    ),
                    backgroundColor: Colors.blue,
                  ),

                if (delivery.driver != null) const SizedBox(height: 12),

                // Bouton Noter le livreur (seulement si livraison terminée)
                if (status == 'delivered' && delivery.driver != null)
                  ModernButton(
                    text: 'Noter le livreur',
                    icon: Icons.star,
                    onPressed: () => _showRatingDialog(
                      delivery.id,
                      delivery.driver!.firstName ?? 'le livreur',
                    ),
                    backgroundColor: Colors.amber,
                  ),

                if (status == 'delivered' && delivery.driver != null) const SizedBox(height: 12),

                // Bouton de suivi pour les livraisons en cours (statuts actifs)
                if (status == 'in_transit' || 
                    status == 'assigned' || 
                    status == 'pickup_confirmed' ||
                    status == 'picked_up' ||
                    status == 'pickup_in_progress')
                  ModernButton(
                    text: 'Suivre la livraison sur la carte',
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

                if (status == 'in_transit' || 
                    status == 'assigned' || 
                    status == 'pickup_confirmed' ||
                    status == 'picked_up' ||
                    status == 'pickup_in_progress') 
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
        return {
          'label': 'En attente',
          'color': Colors.orange,
          'icon': Icons.schedule,
        };
      case 'in_progress':
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
