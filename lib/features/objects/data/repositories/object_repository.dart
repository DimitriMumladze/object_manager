import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/auth_service.dart';
import '../models/api_object_model.dart';

class ObjectRepository {
  final ApiClient _apiClient;
  final AuthService _authService;

  ObjectRepository({
    ApiClient? apiClient,
    required AuthService authService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _authService = authService {
    _apiClient.setApiKey(_authService.apiKey);
  }

  bool get isAuthenticated => _authService.isAuthenticated;
  String? get collectionName => _authService.collectionName;

  void refreshAuth() {
    _apiClient.setApiKey(_authService.apiKey);
  }

  // Resolves the correct endpoint path based on auth state
  String _objectsPath() {
    if (isAuthenticated) {
      return ApiEndpoints.collectionObjects(collectionName!);
    }
    return ApiEndpoints.objects;
  }

  String _objectByIdPath(String id) {
    if (isAuthenticated) {
      return ApiEndpoints.collectionObjectById(collectionName!, id);
    }
    return ApiEndpoints.objectById(id);
  }

  // GET all objects
  Future<List<ApiObject>> getObjects() async {
    final response = await _apiClient.get(_objectsPath());
    final List<dynamic> data = response.data;
    return data.map((json) => ApiObject.fromJson(json)).toList();
  }

  // GET single object by ID
  Future<ApiObject> getObjectById(String id) async {
    final response = await _apiClient.get(_objectByIdPath(id));
    return ApiObject.fromJson(response.data);
  }

  // POST create object
  Future<ApiObject> createObject({
    required String name,
    Map<String, dynamic>? data,
  }) async {
    final response = await _apiClient.post(
      _objectsPath(),
      data: {'name': name, if (data != null && data.isNotEmpty) 'data': data},
    );
    return ApiObject.fromJson(response.data);
  }

  // PUT full update
  Future<ApiObject> updateObject({
    required String id,
    required String name,
    Map<String, dynamic>? data,
  }) async {
    final response = await _apiClient.put(
      _objectByIdPath(id),
      data: {'name': name, if (data != null) 'data': data},
    );
    return ApiObject.fromJson(response.data);
  }

  // PATCH partial update
  Future<ApiObject> patchObject({
    required String id,
    String? name,
    Map<String, dynamic>? data,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (data != null) body['data'] = data;

    final response = await _apiClient.patch(
      _objectByIdPath(id),
      data: body,
    );
    return ApiObject.fromJson(response.data);
  }

  // DELETE object
  Future<void> deleteObject(String id) async {
    await _apiClient.delete(_objectByIdPath(id));
  }
}
