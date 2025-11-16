import '../network/dio_client.dart';

class ApiService {
  final DioClient dioClient;

  ApiService(this.dioClient);

  Future<dynamic> fetch(String path, {Map<String, dynamic>? params}) async {
    final response = await dioClient.get(path, queryParameters: params);
    return response.data;
  }

  // Ajoutez d'autres méthodes génériques si besoin
}
