import 'package:data_access/src/constants.dart';
import 'package:http_client/http_client.dart';
import '../type_alias.dart';

abstract class BaseRepository {
  final String entityPath;
  final HttpClient httpClient;

  BaseRepository(this.entityPath, {HttpClient? httpClient})
      : httpClient = httpClient ?? HttpClient(dataAccessBaseUrl);

  Future<void> create(JsonObject account, String accessToken) => httpClient
      .post(entityPath, data: account, headers: getHeaders(accessToken));

  Future<dynamic> get(JsonObject filter, String accessToken) async {
    final response = await httpClient.get(
      getPathWithQueryParams(filter),
      headers: getHeaders(accessToken),
    );
    return response.data;
  }

  Future<void> update(String id, JsonObject data, String accessToken) =>
      httpClient.patch(
        "$entityPath/$id",
        data,
        headers: getHeaders(accessToken),
      );

  Future<void> delete(String id, String accessToken) =>
      httpClient.delete("$entityPath/$id", headers: getHeaders(accessToken));

  String getPathWithQueryParams(JsonObject queryParams, [String? path]) {
    String query = (path ?? entityPath) + "?";
    queryParams
        .forEach((paramName, paramValue) => query += "$paramName=$paramValue");
    return query;
  }

  Map<String, String> getHeaders(String accessToken) {
    return {"Authorization": "Bearer $accessToken"}..addAll(ContentType.json);
  }
}
