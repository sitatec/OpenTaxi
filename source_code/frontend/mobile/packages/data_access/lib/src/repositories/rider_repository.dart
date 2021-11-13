import 'package:data_access/src/repositories/base_repository.dart';
import 'package:http_client/http_client.dart';

class RiderRepository extends BaseRepository {
  RiderRepository([HttpClient? httpClient])
      : super("/rider", httpClient: httpClient);
}
