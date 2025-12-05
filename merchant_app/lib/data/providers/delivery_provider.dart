import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/delivery_repository.dart';
import '../models/delivery_model.dart';
import '../../core/providers.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DeliveryRepository(dioClient);
});

final deliveriesProvider = FutureProvider<List<DeliveryModel>>((ref) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getDeliveries();
});

// Provider pour liste avec filtre de statut
final deliveryListProvider = FutureProvider.family<List<DeliveryModel>, String?>((ref, status) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getDeliveries(status: status);
});

final deliveryDetailProvider = FutureProvider.family<DeliveryModel, String>((ref, id) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getDeliveryDetail(id);
});

final createDeliveryProvider = FutureProvider.family<DeliveryModel, Map<String, dynamic>>((ref, data) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.createDelivery(data);
});

final deleteDeliveryProvider = FutureProvider.family<bool, String>((ref, id) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.deleteDelivery(id);
});
