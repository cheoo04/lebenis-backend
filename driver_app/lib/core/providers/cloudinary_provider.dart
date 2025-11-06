import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cloudinary_service.dart';
import '../../data/providers/auth_provider.dart';

/// Provider pour le service Cloudinary
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CloudinaryService(dioClient: dioClient);
});
