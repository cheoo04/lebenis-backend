import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/delivery_repository.dart';
import '../models/delivery_model.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  throw UnimplementedError(); // À injecter dans main.dart
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

final deliveryDetailProvider = FutureProvider.family<DeliveryModel, int>((ref, id) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.getDeliveryDetail(id);
});

final createDeliveryProvider = FutureProvider.family<DeliveryModel, Map<String, dynamic>>((ref, data) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.createDelivery(data);
});

final deleteDeliveryProvider = FutureProvider.family<bool, int>((ref, id) async {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.deleteDelivery(id);
});
