import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class TripRepository extends BaseRepository{
  TripRepository(HttpClient httpClient) : super("/trip", httpClient);
}
