import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class ReviewRepository extends BaseRepository{
  ReviewRepository(HttpClient httpClient) : super("/review", httpClient);
}
