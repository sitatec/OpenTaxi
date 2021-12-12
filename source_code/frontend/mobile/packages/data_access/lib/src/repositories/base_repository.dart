import 'package:data_access/src/constants.dart';
import 'package:http_client/http_client.dart';
import '../type_alias.dart';
import 'package:meta/meta.dart';

abstract class BaseRepository {
  final String entityPath;
  final HttpClient httpClient;

  BaseRepository(this.entityPath, {HttpClient? httpClient})
      : httpClient = httpClient ?? HttpClient(dataAccessBaseUrl);

  Future<void> create(JsonObject account, String accessToken) => httpClient
      .post(entityPath, data: account, headers: _getHeaders(accessToken));

  Future<dynamic> get(JsonObject filter, String accessToken) async {
    final response = await httpClient.get(
      _getPathWithQueryParams(filter),
      headers: _getHeaders(accessToken),
    );
    return response.data;
  }

  Future<void> update(String id, JsonObject data, String accessToken) =>
      httpClient.patch(
        "$entityPath/$id",
        data,
        headers: _getHeaders(accessToken),
      );

  Future<void> delete(String id, String accessToken) =>
      httpClient.delete("$entityPath/$id", headers: _getHeaders(accessToken));

  String _getPathWithQueryParams(JsonObject queryParams) {
    String path = "$entityPath?";
    queryParams
        .forEach((paramName, paramValue) => path += "$paramName=$paramValue");
    return path;
  }

  Map<String, String> _getHeaders(String accessToken) {
    return {"Authorization": "Bearer $accessToken"}..addAll(ContentType.json);
  }
}
