import 'package:data_access/src/constants.dart';
import 'package:http_client/http_client.dart';
import '../type_alias.dart';
import 'package:meta/meta.dart';

@internal
abstract class BaseRepository {
  final String entityPath;
  final HttpClient httpClient;

  BaseRepository(this.entityPath, {HttpClient? httpClient})
      : httpClient = httpClient ?? HttpClient(dataAccessBaseUrl);

  Future<void> create(JsonObject account) =>
      httpClient.post(entityPath, data: account);

  Future<List<JsonObject>> get(JsonObject filter) async {
    final response = await httpClient.get(_getPathWithQueryParams(filter));
    return response.data;
  }

  Future<void> update(String id, JsonObject data) =>
      httpClient.patch("$entityPath/$id", data);

  Future<void> delete(String id) => httpClient.delete("$entityPath/$id");

  String _getPathWithQueryParams(JsonObject queryParams) {
    String path = "$entityPath?";
    queryParams
        .forEach((paramName, paramValue) => path += "$paramName=$paramValue");
    return path;
  }
}
