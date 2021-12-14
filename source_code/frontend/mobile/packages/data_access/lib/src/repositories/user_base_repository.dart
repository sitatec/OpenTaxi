import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';
import '../type_alias.dart';

class UserBaseRepository extends BaseRepository {
  UserBaseRepository(String entityName, {HttpClient? httpClient})
      : super(entityName, httpClient: httpClient);

  Future<dynamic> getData(JsonObject filter, String accessToken) async {
    final response = await httpClient.get(
      getPathWithQueryParams(filter, "$entityPath/data"),
      headers: getHeaders(accessToken),
    );
    return response.data;
  }
}
