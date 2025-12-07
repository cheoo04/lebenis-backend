import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/individual_model.dart';

class IndividualRepository {
  final DioClient dioClient;

  IndividualRepository(this.dioClient);

  /// Récupérer le profil du particulier connecté
  Future<IndividualModel> getProfile() async {
    try {
      final response = await dioClient.get('/api/v1/individuals/profile/');
      
      // Backend peut retourner une liste ou un objet direct
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return IndividualModel.fromJson(data[0]);
      } else if (data is Map<String, dynamic>) {
        // Si le backend retourne un objet avec 'results'
        if (data.containsKey('results') && data['results'] is List) {
          return IndividualModel.fromJson(data['results'][0]);
        }
        return IndividualModel.fromJson(data);
      }
      
      throw Exception('Format de réponse invalide');
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour le profil du particulier
  Future<IndividualModel> updateProfile({
    String? individualId,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;

      // L'endpoint backend est /api/v1/individuals/profile/ (PATCH sans ID)
      final response = await dioClient.patch(
        '/api/v1/individuals/profile/',
        data: data,
      );

      return IndividualModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Créer un profil particulier (si nécessaire après inscription)
  Future<IndividualModel> createProfile({
    String? phone,
    String? address,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;

      final response = await dioClient.post(
        '/api/v1/individuals/profile/',
        data: data,
      );

      return IndividualModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Vérifier si le profil particulier existe
  Future<bool> profileExists() async {
    try {
      await getProfile();
      return true;
    } catch (e) {
      return false;
    }
  }
}
