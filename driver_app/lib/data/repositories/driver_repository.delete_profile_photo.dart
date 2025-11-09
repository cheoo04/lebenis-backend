import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

class DriverRepository {
  final DioClient _dioClient;

  DriverRepository(this._dioClient);

  // ...existing methods...

  /// Supprimer la photo de profil du driver
  Future<void> deleteProfilePhoto() async {
    await _dioClient.delete(ApiConstants.deleteProfilePhoto);
  }
}
