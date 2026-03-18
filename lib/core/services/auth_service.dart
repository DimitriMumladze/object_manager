import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _apiKeyKey = 'api_key';
  static const _collectionNameKey = 'collection_name';

  String? _apiKey;
  String? _collectionName;

  String? get apiKey => _apiKey;
  String? get collectionName => _collectionName;
  bool get isAuthenticated =>
      _apiKey != null &&
      _apiKey!.isNotEmpty &&
      _collectionName != null &&
      _collectionName!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyKey);
    _collectionName = prefs.getString(_collectionNameKey);
  }

  Future<void> save({required String apiKey, required String collectionName}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
    await prefs.setString(_collectionNameKey, collectionName);
    _apiKey = apiKey;
    _collectionName = collectionName;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
    await prefs.remove(_collectionNameKey);
    _apiKey = null;
    _collectionName = null;
  }
}
