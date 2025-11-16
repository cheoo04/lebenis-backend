import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/pricing_repository.dart';
import '../models/pricing_estimate.dart';

final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  throw UnimplementedError(); // À injecter dans main.dart
});

final pricingEstimateProvider = FutureProvider.family<PricingEstimateModel, Map<String, dynamic>>((ref, data) async {
  final repo = ref.watch(pricingRepositoryProvider);
  return repo.estimatePrice(data);
});
