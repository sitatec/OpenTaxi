import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class DriverRepository extends BaseRepository{
  DriverRepository(HttpClient httpClient) : super("/driver", httpClient);
}
