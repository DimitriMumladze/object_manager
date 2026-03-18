import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  String? _apiKey;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  void setApiKey(String? apiKey) {
    _apiKey = apiKey;
  }

  Map<String, dynamic> _buildHeaders() {
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      return {'x-api-key': _apiKey!};
    }
    return {};
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(headers: _buildHeaders()),
    );
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(
      path,
      data: data,
      options: Options(headers: _buildHeaders()),
    );
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(
      path,
      data: data,
      options: Options(headers: _buildHeaders()),
    );
  }

  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(
      path,
      data: data,
      options: Options(headers: _buildHeaders()),
    );
  }

  Future<Response> delete(String path) {
    return _dio.delete(
      path,
      options: Options(headers: _buildHeaders()),
    );
  }
}
