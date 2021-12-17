import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';
import '../type_alias.dart';

class ReviewRepository extends BaseRepository {
  ReviewRepository([HttpClient? httpClient])
      : super("/review", httpClient: httpClient);

  Future<dynamic> getRating(JsonObject filter, String accessToken) async {
    final response = await httpClient.get(
      getPathWithQueryParams(filter, "$entityPath/rating"),
      headers: getHeaders(accessToken),
    );
    return response.data;
  }
}
