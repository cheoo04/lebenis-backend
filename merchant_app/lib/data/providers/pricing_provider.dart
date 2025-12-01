import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/pricing_repository.dart';
import '../models/pricing_estimate.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

// Provider pour Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.baseUrl = ApiConstants.baseUrl;
  // Ajoute ici les headers, interceptors, etc. si besoin
  return dio;
});

// Provider pour DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  final dio = ref.watch(dioProvider);
  return DioClient(dio);
});

// Provider pour PricingRepository
final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PricingRepository(dioClient);
});

final pricingEstimateProvider = FutureProvider.family<PricingEstimateModel, Map<String, dynamic>>((ref, data) async {
  final repo = ref.watch(pricingRepositoryProvider);
  return repo.estimatePrice(data);
});
