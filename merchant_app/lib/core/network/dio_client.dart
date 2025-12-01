import 'package:dio/dio.dart';
import 'api_exception.dart';

class DioClient {
  final Dio dio;

  DioClient(this.dio);

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Erreur réseau',
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Erreur réseau',
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await dio.patch(path, data: data);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Erreur réseau',
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Erreur réseau',
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }

  Future<Response> upload(String path, {required FormData data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Erreur réseau',
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }
}
