import 'package:http_client/http_client.dart';
import 'type_alias.dart';

abstract class BaseRepository {
  final String entityPath;
  final HttpClient httpClient;

  BaseRepository(this.entityPath, this.httpClient);

  Future<void> create(JsonObject account) =>
      httpClient.post(entityPath, data: account);

  Future<JsonObject> get(String accountId, {JsonObject? filter}) async {
    final response = await httpClient.get(_getPathWithQueryParams(filter));
    return response.data;
  }

  Future<void> update(JsonObject data, {JsonObject? filter}) =>
      httpClient.patch(_getPathWithQueryParams(filter), data);

  Future<void> delete({JsonObject? filter}) =>
      httpClient.delete(_getPathWithQueryParams(filter));

  String _getPathWithQueryParams(JsonObject? queryParams) {
    if (queryParams == null) return entityPath;
    String path = "?";
    queryParams
        .forEach((paramName, paramValue) => path += "$paramName=$paramValue");
    return path;
  }
}
