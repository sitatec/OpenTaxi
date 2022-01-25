import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class FavoritePlaceRepository extends BaseRepository {
  FavoritePlaceRepository([HttpClient? httpClient])
      : super("/rider/favorite_places", httpClient: httpClient);
}
