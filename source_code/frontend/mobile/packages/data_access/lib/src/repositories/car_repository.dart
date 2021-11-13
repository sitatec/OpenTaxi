import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class CarRepository extends BaseRepository {
  CarRepository([HttpClient? httpClient])
      : super("/car", httpClient: httpClient);
}
