class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.restful-api.dev';

  // Public endpoints
  static const String objects = '/objects';
  static String objectById(String id) => '/objects/$id';

  // Authenticated collection endpoints
  static String collectionObjects(String collection) =>
      '/collections/$collection/objects';
  static String collectionObjectById(String collection, String id) =>
      '/collections/$collection/objects/$id';
}
